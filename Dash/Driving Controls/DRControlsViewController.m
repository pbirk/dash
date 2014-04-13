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

@interface DRControlsViewController ()

@end

@implementation DRControlsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIButton *disconnect = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 10, 10)];
//    [disconnect setTitle:@"Disconnect" forState:UIControlStateNormal];
//    [disconnect sizeToFit];
//    disconnect.tintColor = self.view.tintColor;
//    disconnect.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:17];
//    disconnect.bounds = CGRectMake(0, 0, CGRectGetWidth(disconnect.bounds)+20, 44);
//    [disconnect addTarget:self action:@selector(didTapDisconnect) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:disconnect];
//    self.disconnectButton = disconnect;
    
    self.bleService = [[DRCentralManager sharedInstance] connectedService];
}

- (void) didTapDisconnect
{
    [[DRCentralManager sharedInstance] disconnectPeripheral];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleService.delegate = self;
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
//    if (animated)[self.navigationController setNavigationBarHidden:NO animated:animated];
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

#pragma mark - DRRobotLeServiceDelegate

- (void)receivedNotifyWithData:(NSData *)data
{
    
}

@end
