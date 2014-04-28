//
//  DRTabBarController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/30/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRTabBarController.h"
#import "DRCentralManager.h"
#import "DRRobotProperties.h"
#import "DRConfigViewController.h"

@interface DRTabBarController ()
- (IBAction)didTapDisconnect:(id)sender;
@end

@implementation DRTabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIStoryboard *iPadStoryboard = [UIStoryboard storyboardWithName:@"Main~iPad" bundle:nil];
    self.viewController = @[
                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRJoystickViewController"],
                            [(IS_IPAD ? iPadStoryboard : self.storyboard) instantiateViewControllerWithIdentifier:@"DRAutoModesViewController"],
//                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRMotionViewController"],
                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRConfigViewController"]
                            ];
    if (IS_IPAD) {
        [self.viewController[0] setTitle:@"MANUAL DRIVE"];
        [self.viewController[1] setTitle:@"AUTOMATIC MODES"];
        [self.viewController[2] setTitle:@"CONFIGURE"];
        self.animationStyle = RMMultipleViewsControllerAnimationNone;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[@"Disconnect" uppercaseString] style:UIBarButtonItemStyleBordered target:self action:@selector(didTapDisconnect:)];
    } else {
        [self.viewController[0] setTitle:@"DRIVE"];
        [self.viewController[1] setTitle:@"AUTO"];
        [self.viewController[2] setTitle:@"CONFIG"];
        self.animationStyle = RMMultipleViewsControllerAnimationSlideIn;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(didTapDisconnect:)];
    }
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
}

- (void)configureWithProperties:(DRRobotProperties *)properties
{
    if (properties) {
        self.title = properties.name;
    } else {
        self.title = @"Robot";
        DRConfigViewController *cvc = self.viewController.lastObject;
        if (cvc) {
            [self showViewController:cvc animated:NO];
        }
    }

}

- (IBAction)didTapDisconnect:(id)sender
{
    [[DRCentralManager sharedInstance] disconnectPeripheral];
    [self.navigationController popToRootViewControllerAnimated:YES];
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

- (void)dealloc
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

@end
