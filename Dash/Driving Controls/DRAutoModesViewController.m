//
//  DRAutoModesViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 4/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRAutoModesViewController.h"
#import "DRRobotLeService.h"
#import "DRRobotProperties.h"
#import "DRAutoModeCell.h"
#import "DRSignalPacket.h"
#import "DRButton.h"

@interface DRAutoModesViewController ()
@property NSIndexPath *selectedModeIndex;
@property (strong, nonatomic) NSArray *autoModeData;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet DRButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewWidthConstraint;
- (IBAction)didTapStopbutton:(id)sender;
@end

@implementation DRAutoModesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *dataPath = [[NSBundle mainBundle] pathForResource:@"DashAutoModes" ofType:@"plist"];
    self.autoModeData = [NSArray arrayWithContentsOfFile:dataPath];
    
    self.stopButton.backgroundColor = ROBOT_COLORS[DRRedRobot];
    [self.stopButton setEnabled:NO animated:NO];
    
//    [self addBottomBorderWithColor:DR_LITE_GRAY width:1 toView:self.debugLabel];
    [self addBottomBorderToView:self.debugLabel];
    
    self.collectionView.allowsMultipleSelection = YES;
    [self.collectionView reloadData];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self willRotateToInterfaceOrientation:self.interfaceOrientation duration:0];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self didTapStopbutton:nil];
}

#pragma mark - BLE control

- (void)receivedNotifyWithData:(NSData *)data
{
    self.debugLabel.text = [data description];
}

- (void)receivedNotifyWithSignals:(DRSignalPacket *)signals
{
    self.debugLabel.text = [signals description];
}

#pragma mark - IBActions

- (IBAction)didTapStopbutton:(id)sender {
    self.stopButton.enabled = NO;
    [self.collectionView deselectItemAtIndexPath:self.selectedModeIndex animated:NO];
    self.selectedModeIndex = nil;
    NSLog(@"Sent STOP command");
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    [UIView animateWithDuration:duration animations:^{
        if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
            self.collectionViewWidthConstraint.constant = flowLayout.itemSize.width * 4 + flowLayout.minimumInteritemSpacing * 3;
        } else {
            self.collectionViewWidthConstraint.constant = flowLayout.itemSize.width * 3 + flowLayout.minimumInteritemSpacing * 2;
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    if (IS_IPAD || self.autoModeData.count % 2 == 0) {
        return self.autoModeData.count;
    } else {
        return self.autoModeData.count + 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row < self.autoModeData.count) {
        DRAutoModeCell *cell = (DRAutoModeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DRAutoModeCell" forIndexPath:indexPath];
        cell.selectedColor = IS_IPAD ? [UIColor blackColor] : ROBOT_COLORS[DRRedRobot];
        
        NSString *name = self.autoModeData[indexPath.row][@"ModeName"];
        NSString *image = self.autoModeData[indexPath.row][@"ImageName"];
        [cell setTitle:name image:[UIImage imageNamed:image]];
        
        return cell;
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"blank" forIndexPath:indexPath];
    }
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    if (IS_IPAD) {
        return flowLayout.itemSize;
    } else {
        CGFloat height = flowLayout.itemSize.height + (IS_WIDESCREEN ? 11 : 0);
        CGFloat width = flowLayout.itemSize.width;
        if (indexPath.row % 2 == 0) {
            width += 1;
        } else {
            width += (IS_RETINA ? 0.5 : 0);
        }
        return CGSizeMake(width, height);
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.row < self.autoModeData.count;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    return !IS_IPAD && IS_RETINA ? 0.5 : flowLayout.minimumLineSpacing;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    return !IS_IPAD && IS_RETINA ? 0.5 : flowLayout.minimumInteritemSpacing;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.collectionView deselectItemAtIndexPath:self.selectedModeIndex animated:YES];
    self.selectedModeIndex = indexPath;
    
    NSString *cmdString = self.autoModeData[indexPath.row][@"DRCommandType"];
    if (cmdString.length) {
        char command = [cmdString characterAtIndex:0];
        NSLog(@"Selected auto mode %c", command);
    }
    self.stopButton.enabled = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self didTapStopbutton:nil];
}

@end
