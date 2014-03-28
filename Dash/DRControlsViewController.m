//
//  DRControlsViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRControlsViewController.h"
#import "DRCentralManager.h"
#import "DRRobotLeService.h"

@interface DRControlsViewController () {
}

@end

@implementation DRControlsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bleService = [[DRCentralManager sharedInstance] connectedService];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.bleService.delegate = self;
}

- (void)dealloc {
    if (self.bleService.delegate == self) {
        self.bleService.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
//    [super tabBar:tabBar didSelectItem:item];
//    NSUInteger index = [self.tabBar.items indexOfObject:item];
//    UIViewController *vc = (UIViewController *)[self.viewControllers objectAtIndex:index];
//    if (vc respondsToSelector:@selector()) {
//        
//    }
//}

#pragma mark - DRRobotLeServiceDelegate

- (void)serviceDidChangeStatus:(DRRobotLeService *)service {
    
}

@end
