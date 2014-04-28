//
//  DRAutoModeCell.m
//  Dash
//
//  Created by Adam Overholtzer on 4/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRAutoModeCell.h"
#import "DRRobotProperties.h"

@interface DRAutoModeCell ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *textLabel;
@property (strong, nonatomic) UIColor *deselectedColor;
@end

@implementation DRAutoModeCell

-(void)awakeFromNib
{
    [super awakeFromNib];
    self.imageView.tintAdjustmentMode = UIViewTintAdjustmentModeNormal;
    self.imageView.image = [self.imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.deselectedColor = self.backgroundColor;
}

- (void)setTitle:(NSString *)title image:(UIImage *)image
{
    self.imageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    self.textLabel.text = title.uppercaseString;
}

- (UIViewTintAdjustmentMode)tintAdjustmentMode
{
    return UIViewTintAdjustmentModeNormal;
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    if (selected) {
        self.backgroundColor = ROBOT_COLORS[DRGreenRobot];
        self.imageView.tintColor = [UIColor whiteColor];
        self.textLabel.textColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = self.deselectedColor;
        self.imageView.tintColor = [UIColor blackColor];
        self.textLabel.textColor = [UIColor blackColor];
    }
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    if (highlighted) {
        self.contentView.alpha = 0.25;
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.contentView.alpha = 1;
        }];
    }
}

@end
