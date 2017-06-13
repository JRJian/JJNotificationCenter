//
//  JJNSNotificationCenter.h
//  NotificationCenter
//
//  Created by Jian on 2017/6/12.
//  Copyright © 2017年 jian. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JJNSNotificationCenter : NSObject

+ (instancetype _Nullable )defaultCenter;

- (void)addObserver:(id _Nullable)observer selector:(SEL _Nullable)aSelector name:(nullable NSNotificationName)aName object:(nullable id)anObject;
- (void)addObserverForName:(nullable NSNotificationName)name object:(nullable id)obj queue:(nullable NSOperationQueue *)queue usingBlock:(void (^_Nullable)(NSNotification * _Nullable note))block;

- (void)postNotification:(NSNotification *_Nullable)notification;
- (void)postNotificationName:(NSNotificationName _Nullable)aName object:(nullable id)anObject;
- (void)postNotificationName:(NSNotificationName _Nullable)aName object:(nullable id)anObject userInfo:(nullable NSDictionary *)aUserInfo;

- (void)removeObserver:(id _Nullable)observer;
- (void)removeObserver:(id _Nullable)observer name:(nullable NSNotificationName)aName object:(nullable id)anObject;

@end
