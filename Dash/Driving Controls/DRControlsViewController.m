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
    self.bleService = [[DRCentralManager sharedInstance] connectedService];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.bleService.delegate = self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)dealloc {
    if (self.bleService.delegate == self) {
        self.bleService.delegate = nil;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - DRRobotLeServiceDelegate

- (void)receivedNotifyWithData:(NSData *)data
{
}

- (void)receivedNotifyWithSignals:(DRSignalPacket *)signals
{
}

@end
