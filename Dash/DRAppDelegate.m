//
//  DRAppDelegate.m
//  Dash
//
//  Created by Adam Overholtzer on 3/1/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRAppDelegate.h"
#import <HockeySDK/HockeySDK.h>
#import "DRCentralManager.h"
#import "DRRobotLeService.h"
#import "DRWebViewController.h"

@implementation DRAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[BITHockeyManager sharedHockeyManager] configureWithIdentifier:@"bbaef82dd4b40fb821a70c63b6855007"];
    [[BITHockeyManager sharedHockeyManager] startManager];
    [[BITHockeyManager sharedHockeyManager].authenticator authenticateInstallation];
//    [[BITHockeyManager sharedHockeyManager] testIdentifier];
    
    UIStoryboard *storyboard = IS_IPAD ? [UIStoryboard storyboardWithName:@"Main~iPad" bundle:nil]
                                        : [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = [storyboard instantiateInitialViewController];
    [self.window makeKeyAndVisible];

    [self configureStyling];
    
    return YES;
}

- (void)configureStyling
{
    [[UINavigationBar appearance] setTitleTextAttributes:@{
//                                                           NSForegroundColorAttributeName: [UIColor blackColor],
                                                           NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Medium" size:19],
                                                           }];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
//NSForegroundColorAttributeName: [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
                                                           NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:17],
                                                           } forState:UIControlStateNormal];
    [[UITabBarItem appearance] setTitleTextAttributes:@{
                                                        NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:10],
                                                        } forState:UIControlStateNormal];
    
    [[UISegmentedControl appearance] setTitleTextAttributes:@{
                                                              NSFontAttributeName: [UIFont fontWithName:@"AvenirNextCondensed-Medium" size:14],
                                                              } forState:UIControlStateNormal];
    NSUInteger yOffset = IS_RETINA ? 2 : 1;
    [[UISegmentedControl appearance] setContentPositionAdjustment:UIOffsetMake(0, yOffset) forSegmentType:UISegmentedControlSegmentAny barMetrics:UIBarMetricsDefault];
    
    self.window.tintColor = [UIColor blackColor];
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [[[DRCentralManager sharedInstance] connectedService] reset];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    [[DRCentralManager sharedInstance] disconnectPeripheral];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if ([self.window.rootViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (UINavigationController *)self.window.rootViewController;
        if (![nav.visibleViewController isKindOfClass:[DRWebViewController class]]) {
            [nav popToRootViewControllerAnimated:NO];
        }
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[DRCentralManager sharedInstance] disconnectPeripheral];
    [[DRCentralManager sharedInstance] stopScanning];
}

@end
