//
//  AppDelegate.m
//  MAMapOfTracking
//
//  Created by 叶志强 on 2017/6/17.
//  Copyright © 2017年 CancerQ. All rights reserved.
//

#import "AppDelegate.h"
#import "RouteDrawViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self configAMapServices];
    
    RouteDrawViewController *VC = [[RouteDrawViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)configAMapServices{
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    [AMapServices sharedServices].apiKey = MAMapServicesKey;
}
@end
