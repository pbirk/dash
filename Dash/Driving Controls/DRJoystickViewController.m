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
static CGFloat JOYSTICK_THUMB_SIZE = 100;

@interface DRJoystickViewController () {
    BOOL _touchDown;
    CGPoint _touchOffset;
    CGFloat _throttle, _direction, _prevThrottle, _prevDirection;
    NSTimer *_updateTimer;
}
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet UIView *joystickTouchArea;
@property (weak, nonatomic) UIImageView *joystickBase;
@property (weak, nonatomic) UIImageView *joystickThumb;
@end

@implementation DRJoystickViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *joystickThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JOYSTICK_THUMB_SIZE, JOYSTICK_THUMB_SIZE)];
    joystickThumb.image = [UIImage imageNamed:@"joystick-thumb"];
    [self.view insertSubview:joystickThumb aboveSubview:self.joystickTouchArea];
    self.joystickThumb = joystickThumb;
    
    UIImageView *joystickBase = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JOYSTICK_THUMB_SIZE+MAX_JOYSTICK_TRAVEL, JOYSTICK_THUMB_SIZE+MAX_JOYSTICK_TRAVEL)];
    joystickBase.image = [UIImage imageNamed:@"joystick-well"];
    [self.view insertSubview:joystickBase belowSubview:self.joystickThumb];
    self.joystickBase = joystickBase;
    
    [self updateThrottle:0 direction:0];

    if (IS_IPAD) {
        UIView *eyeButton = [self.view viewWithTag:111];
        for (NSLayoutConstraint *constraint in eyeButton.constraints) {
            NSLog(@"c %@", constraint);
            if (constraint.firstItem == eyeButton && (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.firstAttribute == NSLayoutAttributeHeight )) {
                constraint.constant = 52;
            }
        }
    }
}

- (void)sendUpdate
{
    if (_prevThrottle != _throttle || _prevDirection != _direction) {
        
        if (self.bleService.useGyroDrive) {
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    CGPoint center = self.joystickTouchArea.center;
    if (!IS_RETINA) {
        center = CGPointMake(round(center.x), round(center.y));
    }
    self.joystickThumb.center = self.joystickBase.center = center;
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
        self.joystickThumb.center = self.joystickBase.center;
        self.joystickBase.transform = CGAffineTransformIdentity;
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
        if (!CGRectContainsPoint(self.joystickThumb.frame, touch)) {
            self.joystickThumb.center = self.joystickBase.center = touch;
            _touchOffset = CGPointZero;
        } else {
            _touchOffset = CGPointMake(touch.x - self.joystickThumb.center.x, touch.y - self.joystickThumb.center.y);
        }
        _touchDown = YES;
    } else {
        if (CGRectContainsPoint(CGRectInset(self.joystickTouchArea.frame, -JOYSTICK_THUMB_SIZE/2, -JOYSTICK_THUMB_SIZE/2), touch)) {
            CGPoint newCenter;
            newCenter.x = MAX(touch.x, CGRectGetMinX(self.joystickTouchArea.frame));
            newCenter.x = MIN(newCenter.x, CGRectGetMaxX(self.joystickTouchArea.frame));
            newCenter.y = MAX(touch.y, CGRectGetMinY(self.joystickTouchArea.frame));
            newCenter.y = MIN(newCenter.y, CGRectGetMaxY(self.joystickTouchArea.frame));
            self.joystickThumb.center = self.joystickBase.center = newCenter;
            if (CGRectContainsPoint(self.joystickThumb.frame, touch)) {
                _touchOffset = CGPointMake(touch.x - self.joystickThumb.center.x, touch.y - self.joystickThumb.center.y);
                _touchDown = YES;
            }
        }
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
            distance = MAX_JOYSTICK_TRAVEL;
        }
        
        self.joystickBase.transform = CGAffineTransformMakeTranslation(cos(angle) * 4 * distance/MAX_JOYSTICK_TRAVEL,
                                                                       sin(angle) * 4 * distance/MAX_JOYSTICK_TRAVEL);
        
        // Update the thumb's position
        self.joystickThumb.center = point;
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
