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
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.autoModeData.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DRAutoModeCell *cell = (DRAutoModeCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"DRAutoModeCell" forIndexPath:indexPath];
    
    NSString *name = self.autoModeData[indexPath.row][@"ModeName"];
    NSString *image = self.autoModeData[indexPath.row][@"ImageName"];
    
    [cell setTitle:name image:[UIImage imageNamed:image]];
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    
    if (IS_IPAD) {
        return flowLayout.itemSize;
    } else {
        CGFloat height = flowLayout.itemSize.height + (IS_WIDESCREEN ? 15 : 0);
        CGFloat width = flowLayout.itemSize.width;
        if (indexPath.row % 2 == 0) {
            width += 1;
        } else {
            width += (IS_RETINA ? 0.5 : 0);
        }
        return CGSizeMake(width, height);
    }
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return !IS_IPAD && IS_RETINA ? 0.5 : 1.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return !IS_IPAD && IS_RETINA ? 0.5 : 1.0;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:self.selectedModeIndex];
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return ![indexPath isEqual:self.selectedModeIndex];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (![indexPath isEqual:self.selectedModeIndex]) {
        [self.collectionView deselectItemAtIndexPath:self.selectedModeIndex animated:YES];
        self.selectedModeIndex = indexPath;
        
        NSString *cmdString = self.autoModeData[indexPath.row][@"DRCommandType"];
        if (cmdString.length) {
            char command = [cmdString characterAtIndex:0];
            NSLog(@"Selected auto mode %c", command);
        }
    }
    self.stopButton.enabled = YES;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath isEqual:self.selectedModeIndex]) {
        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
    }
}

@end
