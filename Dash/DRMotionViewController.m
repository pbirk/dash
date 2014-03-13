//
//  DRMotionViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/1/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRMotionViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "LeDiscovery.h"

static CGFloat MAX_JOYSTICK_TRAVEL = 100;

@interface DRMotionViewController () {
    BOOL _touchDown;
    CGPoint _touchOffset;
    CGFloat _sliderPosition;
    __weak DRRobotLeService *_bleService;
}
@property (weak, nonatomic) IBOutlet UIView *sliderTouchArea;
@property (weak, nonatomic) IBOutlet UIImageView *sliderHead;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (strong, nonatomic) CMMotionManager *motionManager;
@end

@implementation DRMotionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.motionManager = [[CMMotionManager alloc] init];
    self.motionManager.deviceMotionUpdateInterval = 0.05;
    
    _sliderPosition = 0;
    [self updateThrottle:0 direction:0];
    self.sliderHead.layer.cornerRadius = CGRectGetHeight(self.sliderHead.bounds) / 2;
    
    self.debugLabel.transform = CGAffineTransformMakeRotation(M_PI_2);
    
    _bleService = [[[LeDiscovery sharedInstance] connectedServices] firstObject];
}

- (void)viewDidLayoutSubviews {
    self.sliderHead.center = self.sliderTouchArea.center;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    _bleService.delegate = self;
    if (self.motionManager.isDeviceMotionAvailable) {
        __weak typeof(self) weakSelf = self;
        [self.motionManager startDeviceMotionUpdatesUsingReferenceFrame:CMAttitudeReferenceFrameXArbitraryCorrectedZVertical
                                                                toQueue:[NSOperationQueue mainQueue]
                                                            withHandler:^(CMDeviceMotion *motion, NSError *error) {
                                                                if (!error && weakSelf)
                                                                    [weakSelf updateThrottle:_sliderPosition
                                                                                   direction:[weakSelf getDirection:motion]];
                                                            }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.motionManager stopDeviceMotionUpdates];
    self.motionManager = nil;
    [super viewDidDisappear:animated];
}

- (void)updateThrottle:(CGFloat)throttle direction:(CGFloat)direction
{
    throttle = -throttle;
    
    CGFloat leftMotor = CLAMP(throttle * (1.0 + direction), -1.0, 1.0) * 255.0;
    CGFloat rightMotor = CLAMP(throttle * (1.0 - direction), -1.0, 1.0) * 255.0;
    
    self.debugLabel.text = [NSString stringWithFormat:@"%.0f, %.0f", roundf(leftMotor), roundf(rightMotor)];
    if (!rightMotor) self.debugLabel.text = [self.debugLabel.text stringByReplacingOccurrencesOfString:@"-0" withString:@"0"];
    
    if (_bleService) {
        _bleService.motor = CGPointMake(leftMotor, rightMotor);
    }
}

- (CGFloat)getDirection:(CMDeviceMotion *)motion
{
    return -CLAMP(motion.attitude.yaw/M_PI, -1.0, 1.0);
}

//- (IBAction)sliderValueChanged:(id)sender
//{
//    [self updateThrottle:self.throttleSlider.value direction:[self getDirection:self.motionManager.deviceMotion]];
//}

- (void)resetJoystick
{
    _touchDown = NO;
    _sliderPosition = 0;
    [self updateThrottle:_sliderPosition
               direction:[self getDirection:self.motionManager.deviceMotion]];
    
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.sliderHead.center = self.sliderTouchArea.center;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - DRRobotLeServiceDelegate

- (void)serviceDidChangeStatus:(DRRobotLeService *)service {
    
}

#pragma mark - Touch Events

#define CGPointMakeX(x) CGPointMake(x, self.sliderHead.center.y)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.view];
    if (CGRectContainsPoint(self.sliderTouchArea.frame, touch)) {
        _touchDown = YES;
        if (!CGRectContainsPoint(self.sliderHead.frame, touch)) {
//            self.joystickNub.center = CGPointMakeX(touch.x);
            _touchOffset = CGPointZero;
            [self touchesMoved:touches withEvent:event];
        } else {
            _touchOffset = CGPointMakeX(touch.x - self.sliderHead.center.x);
        }
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchDown) {
        CGPoint touch = [[touches anyObject] locationInView:self.view];
//        CGPoint point = CGPointMake(touch.x - _touchOffset.x, touch.y - _touchOffset.y);
        
        CGPoint kCenter = self.sliderTouchArea.center;
        CGFloat dx = touch.x - kCenter.x;
        
        dx = CLAMP(dx, -MAX_JOYSTICK_TRAVEL, MAX_JOYSTICK_TRAVEL);
        _sliderPosition = dx / MAX_JOYSTICK_TRAVEL;
        
        [self updateThrottle:_sliderPosition
                   direction:[self getDirection:self.motionManager.deviceMotion]];
        
        self.sliderHead.center = CGPointMakeX(kCenter.x + dx);
        
//        CGFloat distance = dx;
//        CGFloat distance = sqrt(dx * dx + dy * dy);
//        CGFloat angle = atan2(dy, dx); // in radians
        
        // NOTE: Velocity goes from -1.0 to 1.0.
        // BE CAREFUL: don't just cap each direction at 1.0 since that
        // doesn't preserve the proportions.
//        if (distance > MAX_JOYSTICK_TRAVEL) {
//            dx = cos(angle) * MAX_JOYSTICK_TRAVEL;
//            dy = sin(angle) *  MAX_JOYSTICK_TRAVEL;
//        }
        
//        CGPoint velocity = CGPointMake(dx/MAX_JOYSTICK_TRAVEL, dy/MAX_JOYSTICK_TRAVEL);
        //        NSLog(@"Velocity %.3f, %.3f", velocity.x, -velocity.y);
//        [self updateThrottle:-velocity.y direction:velocity.x];
        
        // Constrain the thumb so that it stays within the joystick
        // boundaries.  This is smaller than the joystick radius in
        // order to account for the size of the thumb.
//        if (distance > MAX_JOYSTICK_TRAVEL) {
//            point.x = kCenter.x + cos(angle) * MAX_JOYSTICK_TRAVEL;
//            point.y = kCenter.y + sin(angle) * MAX_JOYSTICK_TRAVEL;
//        }
//        
//        // Update the thumb's position
//        self.joystickNub.center = point;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetJoystick];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self resetJoystick];
}


@end
