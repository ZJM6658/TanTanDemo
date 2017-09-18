//
//  AppDelegate.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "AppDelegate.h"
#import "VC_RootTable.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:[[VC_RootTable alloc] init]];
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = rootNav;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
