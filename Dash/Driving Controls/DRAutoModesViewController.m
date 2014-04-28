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

#define PLACEHOLDER_AUTO_MODES @[ @"Figure 8", @"Circle", @"Dance", @"Wall Follow", @"Bump" ]

@interface DRAutoModesViewController ()
@property NSIndexPath *selectedModeIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIButton *stopButton;
@property (weak, nonatomic) IBOutlet UILabel *debugLabel;
- (IBAction)didTapStopbutton:(id)sender;
@end

@implementation DRAutoModesViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.stopButton.backgroundColor = DR_LITE_GRAY;
    [self.collectionView reloadData];
    [self addBottomBorderToView:self.debugLabel];
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
    self.stopButton.backgroundColor = DR_LITE_GRAY;
    [self.collectionView deselectItemAtIndexPath:self.selectedModeIndex animated:YES];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [PLACEHOLDER_AUTO_MODES count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRAutoModeCell *cell = (DRAutoModeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DRAutoModeCell" forIndexPath:indexPath];
    [cell setTitle:PLACEHOLDER_AUTO_MODES[indexPath.row]
             image:[UIImage imageNamed:@"motion-icon"]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    CGFloat height = IS_WIDESCREEN ? flowLayout.itemSize.height + 15 : flowLayout.itemSize.height;
    CGFloat width = (indexPath.row % 2 == 0) ? flowLayout.itemSize.width + 1 : flowLayout.itemSize.width;
    return CGSizeMake(width, height);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![indexPath isEqual:self.selectedModeIndex]) {
        [self.collectionView deselectItemAtIndexPath:self.selectedModeIndex animated:YES];
        self.selectedModeIndex = indexPath;
    }
    self.stopButton.backgroundColor = ROBOT_COLORS[DRRedRobot];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    UICollectionViewCell *item = [collectionView cellForItemAtIndexPath:indexPath];
    if ([indexPath isEqual:self.selectedModeIndex]) {
        self.selectedModeIndex = nil;
    }
}

@end
