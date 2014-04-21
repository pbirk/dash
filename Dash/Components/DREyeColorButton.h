//
//  DREyeColorButton.h
//  Dash
//
//  Created by Adam Overholtzer on 4/20/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DRButton.h"

@interface DREyeColorButton : DRButton

@property CGFloat buttonPadding;
@property (strong, nonatomic) NSArray *buttons;
- (IBAction)didTapEyeColorButton:(UIButton *)sender;

@end
