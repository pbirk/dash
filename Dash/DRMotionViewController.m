//
//  DRMotionViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/1/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRMotionViewController.h"
#import <CoreMotion/CoreMotion.h>

@interface DRMotionViewController ()
@property (weak, nonatomic) IBOutlet UISlider *throttleSlider;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong, nonatomic) CMMotionManager *motionManager;
- (IBAction)sliderValueChanged:(id)sender;
@end

@implementation DRMotionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.05;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.motionManager.isDeviceMotionAvailable) {
        __weak typeof(self) weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesToQueue:[NSOperationQueue mainQueue]
                                                withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                    if (!error && weakSelf)
                                                        [weakSelf updateThrottle:weakSelf.throttleSlider.value
                                                                       direction:[weakSelf getDirection:motion]];
                                                }];
    }
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.motionManager stopDeviceMotionUpdates];
}

- (void)updateThrottle:(CGFloat)throttle direction:(CGFloat)direction {
    
    CGFloat leftMotor = CLAMP(throttle * (1.0 + direction), -1.0, 1.0) * 255.0;
    CGFloat rightMotor = CLAMP(throttle * (1.0 - direction), -1.0, 1.0) * 255.0;
    
    self.debugLabel.text = [NSString stringWithFormat:@"%.0f, %.0f", roundf(leftMotor), roundf(rightMotor)];
    if (!rightMotor) self.debugLabel.text = [self.debugLabel.text stringByReplacingOccurrencesOfString:@"-0" withString:@"0"];
}

- (CGFloat)getDirection:(CMDeviceMotion *)motion {
    CGFloat val = -CLAMP(motion.attitude.yaw/M_PI, -1.0, 1.0);
    
//    NSLog(@"attitude %f", val);
    return val;
}

- (IBAction)sliderValueChanged:(id)sender {
    [self updateThrottle:self.throttleSlider.value direction:[self getDirection:self.motionManager.deviceMotion]];
}

@end
