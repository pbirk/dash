//
//  DRConfigViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 4/18/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRConfigViewController.h"
#import "DRButton.h"

@interface DRConfigViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UILabel *characterLimitLabel;
@property (weak, nonatomic) IBOutlet UIView *colorPickerView;
@property (strong, nonatomic) NSArray *buttons;
- (IBAction)didToggleGyroDrive:(UISwitch *)sender;

@property (strong, nonatomic) UIFont *nameFont, *namePlaceholderFont;
@end

@implementation DRConfigViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.namePlaceholderFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:17];
    self.nameFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    
    self.nameTextField.delegate = self;
    self.nameTextField.backgroundColor = self.view.backgroundColor;
    self.nameTextField.font = self.namePlaceholderFont;
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTextField.placeholder
                                                              attributes:@{ NSForegroundColorAttributeName : DR_DARK_GRAY}];
    CGFloat borderWidth = IS_RETINA ? 0.5 : 1.0;
    
    CALayer *topBorder = [CALayer layer];
    topBorder.backgroundColor = [DR_DARK_GRAY colorWithAlphaComponent:0.666].CGColor;
    topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(self.nameTextField.bounds), borderWidth);
    [self.nameTextField.layer addSublayer:topBorder];
    
    CALayer *bottomBorder = [CALayer layer];
    bottomBorder.backgroundColor = [DR_DARK_GRAY colorWithAlphaComponent:0.666].CGColor;
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(self.nameTextField.bounds)-borderWidth, CGRectGetWidth(self.nameTextField.bounds), borderWidth);
    [self.nameTextField.layer addSublayer:bottomBorder];
    
    self.characterLimitLabel.alpha = 0;
    self.characterLimitLabel.textColor = ROBOT_COLORS[DRRedRobot];
    
    self.colorPickerView.backgroundColor = self.view.backgroundColor;
    NSMutableArray *buttons = [NSMutableArray array];
    NSUInteger size = CGRectGetHeight(self.colorPickerView.bounds);
    for (NSUInteger i = 0; i < ROBOT_COLORS.count; i++) {
        UIButton *button = [[DRButton alloc] initWithFrame:CGRectMake(size*i, 0, size, size)];
        button.backgroundColor = ROBOT_COLORS[i];
        button.tintColor = [UIColor whiteColor];
        [button addTarget:self action:@selector(didTapColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[[UIImage imageNamed:@"check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [self.colorPickerView addSubview:button];
        [buttons addObject:button];
    }
    self.buttons = [NSArray arrayWithArray:buttons];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.nameTextField resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didToggleGyroDrive:(UISwitch *)sender
{
    self.bleService.useGyroDrive = sender.on;
}

- (IBAction)didTapColorButton:(UIButton *)sender
{
    [self.nameTextField resignFirstResponder];
    for (UIButton *button in self.buttons) {
        button.selected = (button == sender);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newLength = [newString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    if (newLength > 0) {
        textField.font = self.nameFont;
    } else {
        textField.font = self.namePlaceholderFont;
    }
    if (newLength > MAX_NAME_LENGTH) {
        [UIView animateKeyframesWithDuration:2.5 delay:0 options:UIViewKeyframeAnimationOptionBeginFromCurrentState animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.01 animations:^{
                self.characterLimitLabel.alpha = 1;
            }];
            [UIView addKeyframeWithRelativeStartTime:0.8 relativeDuration:0.2 animations:^{
                self.characterLimitLabel.alpha = 0;
            }];
        } completion:nil];
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.font = self.namePlaceholderFont;
    [self.characterLimitLabel.layer removeAllAnimations];
    self.characterLimitLabel.alpha = 0;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

@end
