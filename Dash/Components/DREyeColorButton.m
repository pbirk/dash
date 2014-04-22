//
//  DREyeColorButton.m
//  Dash
//
//  Created by Adam Overholtzer on 4/20/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DREyeColorButton.h"
#import "DRCentralManager.h"
#import "DRRobotLeService.h"

@interface DREyeColorButton ()
@property (weak, nonatomic) DRRobotLeService *bleService;
@end

@interface UIColor (changeBrightness)
- (UIColor *)lighterColor;
@end

@implementation UIColor (changeBrightness)
- (UIColor *)lighterColor
{
    CGFloat r, g, b, a;
    if ([self getRed:&r green:&g blue:&b alpha:&a])
        return [UIColor colorWithRed:MIN(r + 0.2, 1.0)
                               green:MIN(g + 0.2, 1.0)
                                blue:MIN(b + 0.2, 1.0)
                               alpha:a];
    return nil;
}
@end

@implementation DREyeColorButton

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.buttons.count) {
        [self globalInit];
    }
}

- (void)orientationDidChange:(NSNotification *)note
{
    if (self.buttons.count) {
        for (UIButton *button in self.buttons) {
            button.center = self.center;
        }
        self.selected = NO;
        if ([self.bleService.eyeColor isEqual:[UIColor blackColor]]) {
            [self setImage:[[UIImage imageNamed:@"eye-off-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            self.tintColor = [UIColor whiteColor];
        } else {
            [self setImage:[[UIImage imageNamed:@"eye-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
            self.tintColor = self.bleService.eyeColor;
        }
    }
}

- (void)globalInit
{
    self.bleService = [[DRCentralManager sharedInstance] connectedService];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];

    self.buttonPadding = 7;

    [self addTarget:self action:@selector(didTapEyeColorButton:) forControlEvents:UIControlEventTouchUpInside];
    
    self.backgroundColor = [UIColor blackColor];
    self.tintColor = [UIColor whiteColor];
    [self setImage:[[UIImage imageNamed:@"eye-off-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
    [self setImage:[[UIImage imageNamed:@"eye-off-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
    self.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
    
    NSArray *colors = @[
                        [UIColor whiteColor],
                        [UIColor redColor],
                        [UIColor colorWithRed:0.700 green:0.000 blue:0.400 alpha:1.000],
                        [UIColor blueColor],
                        [UIColor greenColor],
                        ];
    
    NSMutableArray *buttons = [NSMutableArray array];
    for (NSUInteger i = 0; i < colors.count; i++) {
        UIButton *button = [[DRButton alloc] initWithFrame:self.frame];
        button.backgroundColor = colors[i];
        button.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
        if ([button.backgroundColor isEqual:[UIColor whiteColor]]) {
            button.layer.borderColor = [UIColor grayColor].CGColor;
            button.layer.borderWidth = 0.5;
        }
        button.alpha = 0;
        [button addTarget:self action:@selector(didTapEyeColorButton:) forControlEvents:UIControlEventTouchUpInside];
        
        if (buttons.count) {
            [self.superview insertSubview:button belowSubview:buttons.lastObject];
        } else {
            [self.superview insertSubview:button belowSubview:self];
        }
        
        [buttons addObject:button];
    }
    self.buttons = [NSArray arrayWithArray:buttons];
}

- (IBAction)didTapEyeColorButton:(id)sender
{
    static NSTimeInterval kAnimationTotalTime = 0.36;
    
    if (self.selected) {
        self.selected = NO;
        if (self.bleService) {
            if (sender == self) {
                [self.bleService setEyeColor:[UIColor blackColor]];
            } else {
                [self.bleService setEyeColor:[sender backgroundColor]];
            }
        }
        
        [UIView animateWithDuration:kAnimationTotalTime-0.09 delay:0
             usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                 for (NSUInteger i = 0; i < self.buttons.count; i++) {
                     UIButton *button = self.buttons[i];
                     button.center = self.center;
                     if (button != sender) button.alpha = 0;
                 }
                 if (sender != self) {
                     if ([[sender backgroundColor] isEqual:[UIColor blueColor]]) {
                         self.tintColor = [UIColor colorWithRed:0.122 green:0.512 blue:0.998 alpha:1.000];
                     } else {
                         self.tintColor = [[sender backgroundColor] lighterColor];
                     }
                     [self setImage:[[UIImage imageNamed:@"eye-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                 } else {
                     [self setImage:[[UIImage imageNamed:@"eye-off-icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateNormal];
                 }
             } completion:^(BOOL finished) {
                 if (sender != self) {
                     [sender setAlpha:0];
                 }
             }];
    } else {
        self.selected = YES;
        self.tintColor = [UIColor whiteColor];
        [UIView animateWithDuration:kAnimationTotalTime delay:0 usingSpringWithDamping:0.7 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            for (NSUInteger i = 0; i < self.buttons.count; i++) {
                UIButton *button = self.buttons[i];
                button.center = CGPointMake(self.center.x + (CGRectGetWidth(self.bounds)+self.buttonPadding)*(i+1), self.center.y);
                button.alpha = 1;
            }
        } completion:nil];
    }
}



@end