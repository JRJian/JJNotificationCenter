//
//  JJNSNotificationCenter.m
//  NotificationCenter
//
//  Created by Jian on 2017/6/12.
//  Copyright © 2017年 jian. All rights reserved.
//

#import "JJNSNotificationCenter.h"

@interface JJNotificationModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, strong) id observer;
@property (nonatomic, strong) id object;
@property (nonatomic, assign) SEL aSelector;
@property (nonatomic, strong) NSOperationQueue *queue;
@property (nonatomic, copy) void (^block)(NSNotification *);
@end

@implementation JJNotificationModel
@end

@interface JJNSNotificationCenter()
@property (nonatomic, strong) NSMutableDictionary *observers;
@property (nonatomic, strong) NSConditionLock *lock;
@end

@implementation JJNSNotificationCenter

#pragma mark - Init
- (instancetype)init {
    self = [super init];
    if (self) {
        _lock = [[NSConditionLock alloc] init];
    }
    return self;
}

+ (instancetype)defaultCenter {
    static JJNSNotificationCenter *_instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[JJNSNotificationCenter alloc] init];
    });
    return _instance;
}

#pragma mark - Private Actions
- (void)_postNotification:(NSNotification *)notification name:(NSNotificationName)aName {
    
    void (^block)(JJNotificationModel *obj) = ^(JJNotificationModel *obj) {
        id observer = obj.observer;
        SEL sel = obj.aSelector;
        if (!obj.queue) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [observer performSelector:sel withObject:notification];
#pragma clang diagnostic pop
        } else {
            __weak typeof(obj)weakObj = obj;
            NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
                weakObj.block(notification);
            }];
            [obj.queue addOperation:op];
        }
    };
    
    if (aName) {// 推送注册了通知名的通知
        [_lock lock];
        NSMutableArray *models = [self observerModelsWithNotificationName:aName];
        [_lock unlock];
        [models enumerateObjectsUsingBlock:^(JJNotificationModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            block(obj);
        }];
    } else {// 群体推送
        [_lock lock];
        [self.observers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *models, BOOL * _Nonnull stop) {
            [models enumerateObjectsUsingBlock:^(JJNotificationModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                block(obj);
            }];
        }];
        [_lock unlock];
    }
}

#pragma mark - Public Actions
- (void)addObserver:(id)observer selector:(SEL)aSelector name:(NSNotificationName)aName object:(id)anObject {
    JJNotificationModel *model = [JJNotificationModel new];
    model.observer = observer;
    model.name = aName;
    model.object = anObject;
    model.aSelector = aSelector;
    [self setObserversWithNotificationName:aName model:model];
}

- (void)addObserverForName:(NSNotificationName)name object:(id)obj queue:(NSOperationQueue *)queue usingBlock:(void (^)(NSNotification * _Nullable))block {
    JJNotificationModel *model = [JJNotificationModel new];
    model.name = name;
    model.object = obj;
    model.queue = queue;
    model.block = block;
    [self setObserversWithNotificationName:name model:model];
}

- (void)postNotification:(NSNotification *)notification {
    [self _postNotification:notification name:nil];
}

- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject {
    NSNotification *ntf = [[NSNotification alloc] initWithName:aName object:anObject userInfo:nil];
    [self _postNotification:ntf name:aName];
}

- (void)postNotificationName:(NSNotificationName)aName object:(id)anObject userInfo:(NSDictionary *)aUserInfo {
    NSNotification *ntf = [[NSNotification alloc] initWithName:aName object:anObject userInfo:aUserInfo];
    [self _postNotification:ntf name:aName];
}

- (void)removeObserver:(id)observer {
    [_lock lock];
    [self.observers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *obj, BOOL * _Nonnull stop) {
        if (obj.count) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"observer =%@", observer];
            NSArray *matchs = [obj filteredArrayUsingPredicate:predicate];
            [obj removeObjectsInArray:matchs];
        }
    }];
    [_lock unlock];
}

- (void)removeObserver:(id)observer name:(NSNotificationName)aName object:(id)anObject {
    [_lock lock];
    [self.observers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, NSMutableArray *obj, BOOL * _Nonnull stop) {
        if (obj.count) {
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"observer =%@ AND name=%@ AND object=%@", observer, aName, anObject];
            NSArray *matchs = [obj filteredArrayUsingPredicate:predicate];
            [obj removeObjectsInArray:matchs];
        }
    }];
    [_lock unlock];
}

#pragma mark - Getter & Setter
- (NSMutableDictionary *)observers {
    if (!_observers) {
        _observers = [NSMutableDictionary dictionary];
    }
    return _observers;
}

- (NSMutableArray *)observerModelsWithNotificationName:(NSNotificationName)name {
    if (!name) {return nil;}
    NSMutableArray *array = self.observers[name];
    return array;
}

- (void)setObserversWithNotificationName:(NSNotificationName)name model:(JJNotificationModel *)model {
    if (!name||!model) {return;}
    [_lock lock];
    NSMutableArray *models = [self observerModelsWithNotificationName:name];
    if (!models) {
        models = [NSMutableArray array];
    }
    [models addObject:model];
    [self.observers setObject:models forKey:name];
    [_lock unlock];
}

@end
