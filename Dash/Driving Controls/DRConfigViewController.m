//
//  DRConfigViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 4/18/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRConfigViewController.h"

@interface DRConfigViewController ()
- (IBAction)didToggleGyroDrive:(UISwitch *)sender;
@end

@implementation DRConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didToggleGyroDrive:(UISwitch *)sender {
    self.bleService.useGyroDrive = sender.on;
}

@end
