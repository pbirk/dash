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
- (IBAction)didTapDisconnect;
@end

@implementation DRTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIBarButtonItem *disconnect = [[UIBarButtonItem alloc] initWithTitle:@"Disconnect" style:UIBarButtonItemStyleBordered target:self action:@selector(didTapDisconnect)];
    self.navigationItem.leftBarButtonItem = disconnect;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.titleView = nil;
    
    if (RunningOnPad) {
        self.viewControllers = @[self.viewControllers[0], self.viewControllers[2]];
    }
}

- (IBAction)didTapDisconnect
{
    [[DRCentralManager sharedInstance] disconnectPeripheral];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//- (void)setSelectedViewController:(UIViewController *)selectedViewController {
//    [super setSelectedViewController:selectedViewController];
////    self.title = self.tabBar.selectedItem.title;
//    self.title = selectedViewController.title;
//}


@end
