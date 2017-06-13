//
//  ViewController.m
//  NotificationImpDemo
//
//  Created by Jian on 2017/6/13.
//  Copyright © 2017年 jian. All rights reserved.
//

#import "ViewController.h"
#import "JJNSNotificationCenter.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)testNtf:(NSNotification *)ntf {
    NSLog(@"%@", ntf.name);
}

- (IBAction)testAction:(id)sender {
    NSString *name = @"notificationTestName";
    [[JJNSNotificationCenter defaultCenter] removeObserver:self];
    [[JJNSNotificationCenter defaultCenter] addObserver:self selector:@selector(testNtf:) name:name object:nil];
    [[JJNSNotificationCenter defaultCenter] postNotificationName:name object:nil];
}

@end
