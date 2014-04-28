//
//  DRConfigViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 4/18/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRConfigViewController.h"
#import "DRButton.h"
#import "DRCentralManager.h"
#import "DRRobotProperties.h"

@interface DRConfigViewController () <UITextFieldDelegate>
@property (strong, nonatomic) DRRobotProperties *robotProperties;
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
    
    // HACK for iOS bug: saving separate fonts for text and placeholder, will swap as-needed
    self.namePlaceholderFont = [UIFont fontWithName:@"AvenirNextCondensed-Regular" size:17];
    self.nameFont = [UIFont fontWithName:@"AvenirNext-Regular" size:17];
    
    self.robotProperties = [[DRCentralManager sharedInstance] propertiesForConnectedService];
    if (!self.robotProperties) {
        self.robotProperties = [DRRobotProperties new];
        self.nameTextField.font = self.namePlaceholderFont;
    } else {
        self.nameTextField.text = self.robotProperties.name;
        self.nameTextField.font = self.nameFont;
    }
    
    self.nameTextField.delegate = self;
    self.nameTextField.backgroundColor = self.view.backgroundColor;
    [self addBottomBorderToView:self.nameTextField];
    [self addTopBorderToView:self.nameTextField];
    self.nameTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:self.nameTextField.placeholder
                                                              attributes:@{ NSForegroundColorAttributeName : DR_DARK_GRAY,     // set custom color
                                                                            NSFontAttributeName : self.namePlaceholderFont }]; // BUG: setting font doesn't work
    
    self.characterLimitLabel.text = [NSString stringWithFormat:@"%lu byte limit", (unsigned long)MAX_NAME_LENGTH];
    self.characterLimitLabel.alpha = 0;
    self.characterLimitLabel.textColor = ROBOT_COLORS[DRRedRobot];
    
    self.colorPickerView.backgroundColor = self.view.backgroundColor;
    NSMutableArray *buttons = [NSMutableArray array];
    NSUInteger size = CGRectGetHeight(self.colorPickerView.bounds);
    for (NSUInteger i = 1; i < ROBOT_COLORS.count; i++) { // start from 1 to skip DRColorUndefined
        UIButton *button = [[DRButton alloc] initWithFrame:CGRectMake(size*(i-1), 0, size, size)];
        button.backgroundColor = ROBOT_COLORS[i];
        button.tintColor = [UIColor whiteColor];
        button.tag = i;
        button.selected = (self.robotProperties.color == i);
        [button addTarget:self action:@selector(didTapColorButton:) forControlEvents:UIControlEventTouchUpInside];
        [button setImage:[[UIImage imageNamed:@"check"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate] forState:UIControlStateSelected];
        [self.colorPickerView addSubview:button];
        [buttons addObject:button];
    }
    self.buttons = [NSArray arrayWithArray:buttons];
}

- (void)receivedNotifyWithProperties:(DRRobotProperties *)properties
{
    NSLog(@"Received properties (?) : %@", properties);
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!self.nameTextField.hasText) {
        [self.nameTextField becomeFirstResponder];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.nameTextField resignFirstResponder];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.robotProperties = nil;
}

#pragma mark - BLE Commands

- (void)sendRobotProperties
{
    [[DRCentralManager sharedInstance] updateProperties:self.robotProperties forPeripheral:self.bleService.peripheral];
    [self.bleService setRobotProperties:self.robotProperties];
}

#pragma mark - IBActions

- (IBAction)didToggleGyroDrive:(UISwitch *)sender
{
    self.bleService.useGyroDrive = sender.on;
}

- (IBAction)didTapColorButton:(UIButton *)sender
{
    [self.nameTextField resignFirstResponder];
//    for (NSUInteger i = 0; i < self.buttons.count; i++) {
//        UIButton *button = self.buttons[i];
//        if (button == sender) {
//            self.robotProperties.color = i+1;
//            [self sendRobotProperties];
//            button.selected = YES;
//        } else {
//            button.selected = NO;
//        }
//    }
    for (UIButton *button in self.buttons) {
//        button.selected = (button == sender);
        if (button == sender) {
            self.robotProperties.color = button.tag;
            [self sendRobotProperties];
            button.selected = YES;
        } else {
            button.selected = NO;
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.robotProperties.name = self.nameTextField.text;
    [self sendRobotProperties];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSUInteger newLength = [newString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    
    // HACK to force iOS to use separate fonts for placeholder and text
    if (newLength > 0) {
        textField.font = self.nameFont;
    } else {
        textField.font = self.namePlaceholderFont;
    }
    
    // accept if the new length is less than X bytes, otherwise reject
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
