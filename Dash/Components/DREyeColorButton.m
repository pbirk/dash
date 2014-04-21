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

@implementation DREyeColorButton

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (!self.buttons.count) {
        [self globalInit];
    }
}

- (void)globalInit
{
    self.bleService = [[DRCentralManager sharedInstance] connectedService];
    
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
        UIButton *button = [[UIButton alloc] initWithFrame:self.frame];
        button.backgroundColor = colors[i];
        button.layer.cornerRadius = CGRectGetHeight(self.bounds)/2;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.borderWidth = 0.5;
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
        
        [UIView animateWithDuration:kAnimationTotalTime delay:0
             usingSpringWithDamping:1 initialSpringVelocity:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                 for (NSUInteger i = 0; i < self.buttons.count; i++) {
                     UIButton *button = self.buttons[i];
                     button.center = self.center;
                     if (button != sender) button.alpha = 0;
                 }
                 if (sender != self) {
                     self.tintColor = [sender backgroundColor];
                     if ([self.tintColor isEqual:[UIColor blueColor]]) {
                         self.tintColor = [UIColor colorWithRed:0.122 green:0.512 blue:0.998 alpha:1.000];
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
