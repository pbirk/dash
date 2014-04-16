//
//  DRViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/1/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRJoystickViewController.h"
#import "DRCentralManager.h"
#import "DRSignalPacket.h"

static CGFloat MAX_JOYSTICK_TRAVEL = 40;

@interface DRJoystickViewController () {
    BOOL _touchDown, _useGyroDrive;
    CGPoint _touchOffset;
    CGFloat _throttle, _direction, _prevThrottle, _prevDirection;
    NSTimer *_updateTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UIView *joystickTouchArea;
@property (weak, nonatomic) IBOutlet UIImageView *joystickBase;
@property (weak, nonatomic) IBOutlet UIImageView *joystickNub;
- (IBAction)didToggleGyroDrive:(UISwitch *)sender;
@end

@implementation DRJoystickViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self updateThrottle:0 direction:0];
    self.joystickBase.layer.cornerRadius = CGRectGetWidth(self.joystickBase.bounds) / 2;
    self.joystickNub.layer.cornerRadius = CGRectGetWidth(self.joystickNub.bounds) / 2;
}

- (void)sendUpdate
{
    if (_prevThrottle != _throttle || _prevDirection != _direction) {
        
        if (_useGyroDrive) {
            [self.bleService setThrottle:_throttle direction:_direction];
        } else {
            CGFloat leftMotor = (_throttle + _direction) * 255.0;
            CGFloat rightMotor = (_throttle - _direction) * 255.0;
            [self.bleService setLeftMotor:leftMotor rightMotor:rightMotor];
        }
        
        _prevThrottle = _throttle;
        _prevDirection = _direction;
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!_updateTimer || !_updateTimer.isValid) {
        _updateTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(sendUpdate) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:_updateTimer forMode:NSRunLoopCommonModes];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [_updateTimer invalidate];
}

- (void)viewDidLayoutSubviews {
    self.joystickNub.center = self.joystickBase.center = self.joystickTouchArea.center;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)updateThrottle:(CGFloat)throttle direction:(CGFloat)direction
{
    _throttle = throttle;
    _direction = direction;
//    _leftMotor = (throttle + direction) * 255.0;
//    _rightMotor = (throttle - direction) * 255.0;
    
//    if (self.bleService) {
//        [self.bleService setLeftMotor:leftMotor rightMotor:rightMotor];
//    }
}

- (void)resetJoystick
{
    _touchDown = NO;
    [self updateThrottle:0 direction:0];
    
    [UIView animateWithDuration:0.1 delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
        self.joystickNub.center = self.joystickBase.center;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)receivedNotifyWithData:(NSData *)data
{
    self.debugLabel.text = [data description]; 
}

- (void)receivedNotifyWithSignals:(DRSignalPacket *)signals
{
    self.debugLabel.text = [signals description];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.view];
    if (CGRectContainsPoint(self.joystickTouchArea.frame, touch)) {
        if (!CGRectContainsPoint(self.joystickNub.frame, touch)) {
            self.joystickNub.center = self.joystickBase.center = touch;
            _touchOffset = CGPointZero;
        } else {
            _touchOffset = CGPointMake(touch.x - self.joystickNub.center.x, touch.y - self.joystickNub.center.y);
        }
        _touchDown = YES;
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchDown) {
        CGPoint touch = [[touches anyObject] locationInView:self.view];
        CGPoint point = CGPointMake(touch.x - _touchOffset.x, touch.y - _touchOffset.y);
        
        CGPoint kCenter = self.joystickBase.center;
        
        // Calculate distance and angle from the center.
        CGFloat dx = point.x - kCenter.x;
        CGFloat dy = point.y - kCenter.y;
        
        CGFloat distance = sqrt(dx * dx + dy * dy);
        CGFloat angle = atan2(dy, dx); // in radians
        
        // NOTE: Velocity goes from -1.0 to 1.0.
        // BE CAREFUL: don't just cap each direction at 1.0 since that
        // doesn't preserve the proportions.
        if (distance > MAX_JOYSTICK_TRAVEL) {
            dx = cos(angle) * MAX_JOYSTICK_TRAVEL;
            dy = sin(angle) *  MAX_JOYSTICK_TRAVEL;
        }
        
        [self updateThrottle:dy/MAX_JOYSTICK_TRAVEL direction:dx/MAX_JOYSTICK_TRAVEL];
        
        // Constrain the thumb so that it stays within the joystick
        // boundaries.  This is smaller than the joystick radius in
        // order to account for the size of the thumb.
        if (distance > MAX_JOYSTICK_TRAVEL) {
            point.x = kCenter.x + cos(angle) * MAX_JOYSTICK_TRAVEL;
            point.y = kCenter.y + sin(angle) * MAX_JOYSTICK_TRAVEL;
        }
        
        // Update the thumb's position
        self.joystickNub.center = point;
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

- (IBAction)didToggleGyroDrive:(UISwitch *)sender {
    _useGyroDrive = sender.on;
}
@end
