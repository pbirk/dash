//
//  DRTabBarController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/30/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRTabBarController.h"
#import "DRCentralManager.h"

@interface DRTabBarController ()
- (IBAction)didTapDisconnect:(id)sender;
@end

@implementation DRTabBarController

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.navigationItem.hidesBackButton = YES;
//    [UISegmentedControl appearance] [setTitleTextAttributes: forState:UIControlStateNormal]
    
    self.viewController = @[
                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRJoystickViewController"],
                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRMotionViewController"],
                            [self.storyboard instantiateViewControllerWithIdentifier:@"DRConfigViewController"]
                            ];
    if (IS_IPAD) {
        [self.viewController[0] setTitle:@"MANUAL DRIVE"];
        [self.viewController[1] setTitle:@"AUTOMATIC MODES"];
        [self.viewController[2] setTitle:@"CONFIGURE"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:[@"Disconnect" uppercaseString] style:UIBarButtonItemStyleBordered target:self action:@selector(didTapDisconnect:)];
    } else {
        [self.viewController[0] setTitle:@"DRIVE"];
        [self.viewController[1] setTitle:@"AUTO"];
        [self.viewController[2] setTitle:@"CONFIG"];
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(didTapDisconnect:)];
    }
    
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
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
