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

@interface DRRootViewController ()
@property (weak, nonatomic) DRCentralManager *bleManager;
@property (strong, nonatomic) NSTimer *scanTimer;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *refreshSpinner;
- (IBAction)didTapRefreshButton:(id)sender;
- (IBAction)didTapAbout:(UIButton *)sender;
- (IBAction)didTapBuild:(UIButton *)sender;
- (void)appWillResignActive;
- (void)appDidBecomeActive;
@end

@implementation DRRootViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.bleManager = [DRCentralManager sharedInstance];
    self.bleManager.discoveryDelegate = self;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatusChanged)
                                                 name:kLGPeripheralDidDisconnect
                                               object:nil];
}

- (void)startScanning
{
    if (!self.scanTimer || !self.scanTimer.isValid) {
        self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self.bleManager selector:@selector(startScanning) userInfo:nil repeats:YES];
        [self.scanTimer fire];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLGPeripheralDidDisconnect object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [self.bleManager disconnectPeripheral];
    [self.collectionView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScanning];
}

- (void)appWillResignActive
{
    [[DRCentralManager sharedInstance] stopScanning];
    [self.scanTimer invalidate];
}

- (void)appDidBecomeActive
{
    if (self.isViewLoaded && self.view.superview) {
        [self startScanning];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[DRCentralManager sharedInstance] stopScanning];
    [self.scanTimer invalidate];
}

#pragma mark - IBActions

- (IBAction)didTapRefreshButton:(id)sender {
    [self.bleManager.peripheralNames removeAllObjects];
    [self.scanTimer fire];
}

- (IBAction)didTapAbout:(UIButton *)sender {
    DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com"]];
    dvc.title = sender.currentTitle;
    [self.navigationController pushViewController:dvc animated:YES];
}

- (IBAction)didTapBuild:(UIButton *)sender {
    DRWebViewController *dvc = [DRWebViewController webViewWithUrl:[NSURL URLWithString:@"http://dashrobotics.com/pages/dash-at-home"]];
    dvc.title = sender.currentTitle;
    [self.navigationController pushViewController:dvc animated:YES];
}

#pragma mark - DRDiscoveryDelegate

- (void)connectionStatusChanged
{
    DRRobotLeService *service = self.bleManager.connectedService;
    if (service) {
        if (!service.isManuallyDisconnecting) {
            NSString *msg = @"Lost connection with device.";
            if (service.peripheral && [[DRCentralManager sharedInstance] nameForPeripheral:service.peripheral]) {
                msg = [msg stringByReplacingOccurrencesOfString:@"device" withString:[[DRCentralManager sharedInstance] nameForPeripheral:service.peripheral]];
            }
            [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:msg delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
        }
    }
}

- (void) discoveryDidRefresh
{
    if ([self.collectionView numberOfItemsInSection:1] != [self collectionView:self.collectionView numberOfItemsInSection:1]) {
        [self.collectionView reloadSections:[NSIndexSet indexSetWithIndex:1]];
    } else {
        [self.collectionView reloadData];
    }
    
    if (self.bleManager.manager.scanning && self.navigationItem.rightBarButtonItem == self.refreshButton) {
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.refreshSpinner];
    }
}

- (void)stoppedScanning
{
    self.navigationItem.rightBarButtonItem = self.refreshButton;
}

- (void) discoveryStatePoweredOff
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
    return 2;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.bleManager.peripherals.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return [collectionView dequeueReusableCellWithReuseIdentifier:@"demo" forIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"DRDeviceCell";
        DRDeviceCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
        
        LGPeripheral *peripheral = self.bleManager.peripherals[indexPath.row];
        NSString *name = [self.bleManager nameForPeripheral:peripheral];
        cell.textLabel.text = name ? name : @"Robot";
        cell.detailTextLabel.text = peripheral.UUIDString;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
        vc.title = @"Demo";
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        LGPeripheral *peripheral = self.bleManager.peripherals[indexPath.row];
        [[DRCentralManager sharedInstance] connectPeripheral:peripheral completion:^(NSError *error) {
            if (!error && self.bleManager.connectedService) {
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
                NSString *name = [self.bleManager nameForPeripheral:peripheral];
                vc.title = name ? name : @"Robot";
                [self.navigationController pushViewController:vc animated:YES];
            } else {
                [[[UIAlertView alloc] initWithTitle:@"Connection Failed" message:@"Unable to connect to device." delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
            }
        }];
    }
}

@end
