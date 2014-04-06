//
//  DRDeviceCell.m
//  Dash
//
//  Created by Adam Overholtzer on 3/30/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRDeviceCell.h"

@implementation DRDeviceCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.selectedBackgroundView.backgroundColor = self.tintColor;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    self.alpha = highlighted ? 0.5 : 1;
}

@end
