//
//  DRRootViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/30/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRRootViewController.h"
#import "DRRobotLeService.h"
#import "DRDeviceCell.h"
#import "DRWebViewController.h"

@interface DRRootViewController () {
    BOOL _shouldShowResults;
}
@property (weak, nonatomic) DRCentralManager *bleManager;
@property (strong, nonatomic) NSTimer *scanTimer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *stopButton;
@property (strong, nonatomic) IBOutlet UIProgressView *scanProgressView;
@property (weak, nonatomic) IBOutlet UIView *footerView;
@property (weak, nonatomic) IBOutlet UINavigationBar *myNavigationBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *myNavigationItem;
- (IBAction)didTapInfoButton:(UIButton *)sender;
- (IBAction)didTapAboutButton:(id)sender;
- (IBAction)didTapBuildButton:(id)sender;
- (IBAction)didTapRefreshButton;
- (IBAction)stopScanning;
@end

@implementation DRRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bleManager = [DRCentralManager sharedInstance];
    self.bleManager.discoveryDelegate = self;
    
    if (IS_IPAD) {
        self.collectionView.backgroundColor = self.view.backgroundColor;
        [self.myNavigationBar addSubview:self.scanProgressView];
    } else {
        self.myNavigationItem = self.navigationItem;
        self.myNavigationBar = self.navigationController.navigationBar;
        self.navigationItem.leftBarButtonItem = nil;
    }
    
    CGFloat progressBarHeight = 2.5f;
    CGRect navigaitonBarBounds = self.myNavigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigaitonBarBounds.size.height - progressBarHeight, navigaitonBarBounds.size.width, progressBarHeight);
    self.scanProgressView.frame = barFrame;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatusChanged)
                                                 name:kLGPeripheralDidDisconnect
                                               object:nil];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLGPeripheralDidDisconnect object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (IS_IPAD) [self.navigationController setNavigationBarHidden:YES animated:animated];
//    [self.bleManager disconnectPeripheral];
    if (!IS_IPAD) [self.navigationController.navigationBar addSubview:self.scanProgressView];
    [self.collectionView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (IS_IPAD) [self.navigationController setNavigationBarHidden:NO animated:animated];
    if (!IS_IPAD) [self.scanProgressView removeFromSuperview];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScanning];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    _shouldShowResults = NO;
    [[DRCentralManager sharedInstance] stopScanning];
    [self.scanTimer invalidate];
}

#pragma mark - IBActions

- (IBAction)didTapInfoButton:(UIButton *)sender
{
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *build = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    NSString *cancelButtonTitle = IS_IPAD ? nil : @"Dismiss";

    UIActionSheet *popupSheet = [[UIActionSheet alloc] initWithTitle:[NSString stringWithFormat:@"Dash Robotics %@ (%@)", version, build]
                                                            delegate:self
                                                   cancelButtonTitle:cancelButtonTitle
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:@"What is Dash?", @"How to Build", nil];
    [popupSheet showFromRect:sender.bounds inView:sender.superview animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == actionSheet.firstOtherButtonIndex) { // What is Dash?
        DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com"]];
        dvc.title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.navigationController pushViewController:dvc animated:YES];
    } else if (buttonIndex == actionSheet.firstOtherButtonIndex + 1) { // How to Build
        DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com/pages/dash-at-home"]];
        dvc.title = [actionSheet buttonTitleAtIndex:buttonIndex];
        [self.navigationController pushViewController:dvc animated:YES];
    }
}

- (void)didTapRefreshButton
{
    [self.bleManager.peripheralProperties removeAllObjects];
    [self startScanning];
}

- (void)startScanning
{
    _shouldShowResults = YES;
    
    if (self.bleManager.manager.isCentralReady) {
        self.scanProgressView.progress = 0;
        [NSTimer scheduledTimerWithTimeInterval:SCAN_INTERVAL/100.0 target:self selector:@selector(updateScanProgress:) userInfo:nil repeats:YES];
        
        [self.myNavigationItem setRightBarButtonItem:self.stopButton animated:NO];
        
        [self.bleManager startScanning];
        
        [self.scanTimer invalidate];
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(startScanning) userInfo:nil repeats:NO];
    } else {
        [self.bleManager startScanning];
        self.scanProgressView.progress = 0;
        [self discoveryDidRefresh];
    }
}

- (void)updateScanProgress:(NSTimer *)timer
{
    if (self.scanProgressView.progress < 1 && self.bleManager.manager.scanning) {
        self.scanProgressView.progress += timer.timeInterval / SCAN_INTERVAL;
    } else {
        [timer invalidate];
        self.scanProgressView.progress = 0;
    }
}

- (void)stopScanning
{
    [self.bleManager stopScanning];
}

- (IBAction)didTapAboutButton:(id)sender {
    DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com"]];
    dvc.title = [sender currentTitle];
    [self.navigationController pushViewController:dvc animated:YES];
}

- (IBAction)didTapBuildButton:(id)sender {
    DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com/pages/dash-at-home"]];
    dvc.title = [sender currentTitle];
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - DRDiscoveryDelegate

- (void)connectionStatusChanged
{
    DRRobotLeService *service = self.bleManager.connectedService;
    if (service) {
        if (!service.isManuallyDisconnecting) {
            NSString *msg = @"Lost connection with device.";
            if (service.peripheral && [[DRCentralManager sharedInstance] propertiesForPeripheral:service.peripheral]) {
                msg = [msg stringByReplacingOccurrencesOfString:@"device" withString:[[DRCentralManager sharedInstance] propertiesForPeripheral:service.peripheral].name];
            }
            [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:msg delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
        }
    }
}

- (void) discoveryDidRefresh
{
    [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
}

- (void)stoppedScanning
{
    [self.myNavigationItem setRightBarButtonItem:self.refreshButton animated:YES];
    if (_shouldShowResults && self.bleManager.peripherals.count && !self.bleManager.manager.scanning
        && [self.collectionView numberOfItemsInSection:0] == self.bleManager.peripherals.count+1) {
        [self.collectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]]];
    } else {
        [self discoveryDidRefresh];
    }
}

- (void)discoveryStatePoweredOff
{
    [self.collectionView reloadData];
    
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to connect to Dash.";
    [[[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (!_shouldShowResults) {
        return 0;
    } else {
        NSUInteger perifCount = self.bleManager.peripherals.count;
        if (self.bleManager.manager.scanning) perifCount += 1;
        return MAX(1, perifCount);
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (_shouldShowResults) {
        NSInteger index = self.bleManager.manager.scanning ? indexPath.row - 1 : indexPath.row;
        if (index >= 0 && index < self.bleManager.peripherals.count) {
            static NSString *CellIdentifier = @"DRDeviceCell";
            DRDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            
            LGPeripheral *peripheral = self.bleManager.peripherals[index];
            DRRobotProperties *robot = [self.bleManager propertiesForPeripheral:peripheral];
            cell.textLabel.text = robot ? robot.name : @"Robot";
            cell.detailTextLabel.text = peripheral.UUIDString;
            if (robot) {
//            NSString *hex = [peripheral.UUIDString substringToIndex:6];
//            cell.backgroundColor = UIColorFromRGB([hex integerValue]); // hilarious HACK to show custom colors
                cell.imageView.backgroundColor = robot.color;
                cell.imageView.tintColor = [UIColor whiteColor];
                cell.imageView.layer.borderColor = [UIColor clearColor].CGColor;
            } else {
                cell.imageView.tintColor = [UIColor colorWithRed:0.663 green:0.663 blue:0.663 alpha:1.000];
                cell.imageView.layer.borderColor = cell.imageView.tintColor.CGColor;
                cell.imageView.backgroundColor = [UIColor whiteColor];
            }
            return cell;
        } else {
            static NSString *CellIdentifier = @"explanation";
            DRDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
            if (!self.bleManager.manager.isCentralReady) {
                cell.textLabel.text = self.bleManager.manager.centralNotReadyReason.uppercaseString;
            } else {
                if (self.bleManager.manager.scanning) {
                    cell.textLabel.text = @"SCANNING FOR ROBOTS…";
                } else {
                    if (self.bleManager.peripherals.count == 0) {
                        cell.textLabel.text = @"NO ROBOTS FOUND";
                    } else {
                        cell.textLabel.text = @"UNKNOWN ERROR";
                    }
                }
            }
            return cell;
        }
    } else {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"blank" forIndexPath:indexPath];
    }
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)collectionViewLayout;
    NSInteger index = self.bleManager.manager.scanning ? indexPath.row - 1 : indexPath.row;
    if (index < 0 || !self.bleManager.peripherals.count) {
        return CGSizeMake(flowLayout.itemSize.width, 16); // explanation row
    } else {
        return flowLayout.itemSize;
    }
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = self.bleManager.manager.scanning ? indexPath.row - 1 : indexPath.row;
    return self.inSimulator || (_shouldShowResults && index >=0 && index < self.bleManager.peripherals.count);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger index = self.bleManager.manager.scanning ? indexPath.row - 1 : indexPath.row;
    if (index >= 0 && index < self.bleManager.peripherals.count) {
        LGPeripheral *peripheral = self.bleManager.peripherals[index];
        [[DRCentralManager sharedInstance] connectPeripheral:peripheral completion:^(NSError *error) {
            if (!error && self.bleManager.connectedService) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
                DRRobotProperties *robot = [self.bleManager propertiesForPeripheral:peripheral];
                vc.title = robot ? robot.name : @"Robot";
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to device." delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
            }
        }];
    } else {
        if (self.inSimulator) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
            vc.title = @"Demo";
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (BOOL)inSimulator
{
#if TARGET_IPHONE_SIMULATOR
    return YES;
#else
    return NO;
#endif
}

@end
