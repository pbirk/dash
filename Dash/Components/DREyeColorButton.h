//
//  DREyeColorButton.h
//  Dash
//
//  Created by Adam Overholtzer on 4/20/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DREyeColorButton : UIButton

@property CGFloat buttonPadding;
@property (strong, nonatomic) NSArray *buttons;
- (IBAction)didTapEyeColorButton:(UIButton *)sender;

@end
