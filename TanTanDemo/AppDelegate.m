//
//  AppDelegate.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "AppDelegate.h"
#import "VC_Root.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:[[VC_Root alloc] init]];
    rootNav.navigationBar.tintColor = [UIColor whiteColor];
    rootNav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
    rootNav.navigationBar.barTintColor = [UIColor colorWithRed:220.0/255.0 green:100.0/255.0 blue:50.0/255.0 alpha:1];
    rootNav.navigationBar.translucent = NO;
    self.window.rootViewController = rootNav;
    [self.window makeKeyAndVisible];
    return YES;
}


@end
