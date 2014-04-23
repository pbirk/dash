//
//  DRButton.m
//  Dash
//
//  Created by Adam Overholtzer on 4/6/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRButton.h"

@implementation DRButton

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.alpha = 0.25;
    } else {
        
        [UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.alpha = 1;
        } completion:nil];
    }
}

@end
