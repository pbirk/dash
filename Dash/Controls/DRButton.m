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
    self.alpha = highlighted ? 0.5 : 1;
}

@end
