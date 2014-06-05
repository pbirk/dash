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
#import "DRSignalsView.h"
#import "DREyeColorButton.h"
#import "DRRobotProperties.h"

static CGFloat MAX_JOYSTICK_TRAVEL = 100;
static CGFloat JOYSTICK_THUMB_SIZE = 100;
static CGFloat JOYSTICK_BASE_WOBBLE = 4;

@interface DRJoystickViewController () {
    BOOL _touchDown;
    CGPoint _touchOffset;
    CGFloat _throttle, _direction;//, _prevThrottle, _prevDirection;
    NSTimer *_updateTimer;
}
@property (weak, nonatomic) IBOutlet DRSignalsView *signalsView;
@property (weak, nonatomic) IBOutlet UIView *joystickTouchArea;
@property (weak, nonatomic) IBOutlet DREyeColorButton *eyeColorButton;
@property (weak, nonatomic) UIImageView *joystickBase;
@property (weak, nonatomic) UIImageView *joystickThumb;
@end

@implementation DRJoystickViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [DRCentralManager sharedInstance].moveableJoystick = NO;
    
    self.signalsView.backgroundColor = self.view.backgroundColor;
    [self addBottomBorderToView:self.signalsView];
    
    UIImageView *joystickThumb = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystick-thumb"]];
    [self.view insertSubview:joystickThumb aboveSubview:self.joystickTouchArea];
    self.joystickThumb = joystickThumb;
    
    UIImageView *joystickBase = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"joystick-well"]];
    [self.view insertSubview:joystickBase belowSubview:self.joystickThumb];
    self.joystickBase = joystickBase;
    
    [self updateThrottle:0 direction:0];

    if (IS_IPAD) {
        UIView *eyeButton = [self.view viewWithTag:111];
        for (NSLayoutConstraint *constraint in eyeButton.constraints) {
            NSLog(@"c %@", constraint);
            if (constraint.firstItem == eyeButton && (constraint.firstAttribute == NSLayoutAttributeWidth || constraint.firstAttribute == NSLayoutAttributeHeight )) {
                constraint.constant = 72;
            }
        }
    }
}

- (void)sendUpdate
{
    if (self.bleService.useGyroDrive) {
        [self.bleService sendThrottle:-_throttle direction:_direction];
    } else {
        CGFloat leftMotor = (_throttle + _direction) * 255.0;
        CGFloat rightMotor = (_throttle - _direction) * 255.0;
        [self.bleService sendLeftMotor:leftMotor rightMotor:rightMotor];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.signalsView updateWithProperties:self.bleService.robotProperties];
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.eyeColorButton willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.eyeColorButton didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)updateThrottle:(CGFloat)throttle direction:(CGFloat)direction
{
    _throttle = throttle;
    _direction = direction;
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

- (void)receivedNotifyWithSignals:(DRSignalPacket *)signals
{
    [self.signalsView updateWithSignals:signals];
}

- (void)receivedNotifyWithProperties:(DRRobotProperties *)properties
{
    [self.signalsView updateWithProperties:properties];
}

#pragma mark - Touch Events

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint touch = [[touches anyObject] locationInView:self.view];
    if ([DRCentralManager sharedInstance].moveableJoystick) {
        if (CGRectContainsPoint(self.joystickTouchArea.frame, touch)) {
            if (CGRectContainsPoint(self.joystickThumb.frame, touch)) {
                _touchOffset = CGPointMake(touch.x - self.joystickThumb.center.x, touch.y - self.joystickThumb.center.y);
                _touchDown = YES;
            } else {
                self.joystickThumb.center = self.joystickBase.center = touch;
                _touchOffset = CGPointZero;
                _touchDown = YES;
            }
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
    } else {
        CGFloat dx = touch.x - self.joystickThumb.center.x;
        CGFloat dy = touch.y - self.joystickThumb.center.y;
        CGFloat distance = sqrt(dx * dx + dy * dy);
        if (distance < JOYSTICK_THUMB_SIZE*2) {
            _touchOffset = CGPointMake(touch.x - self.joystickThumb.center.x, touch.y - self.joystickThumb.center.y);
            _touchDown = YES;
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
        
//        if (angle < 0 && distance > MAX_JOYSTICK_TRAVEL * 2 && ABS(angle + M_PI_2) < 0.15) {
//            angle = -M_PI_2;
//        }
        
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
        
        // Update the thumb's position
        self.joystickThumb.center = point;
        
        self.joystickBase.transform = CGAffineTransformMakeTranslation(cos(angle) * JOYSTICK_BASE_WOBBLE * distance/MAX_JOYSTICK_TRAVEL,
                                                                       sin(angle) * JOYSTICK_BASE_WOBBLE * distance/MAX_JOYSTICK_TRAVEL);
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
