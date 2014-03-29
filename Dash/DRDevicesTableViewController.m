//
//  DRDevicesTableViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/9/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRDevicesTableViewController.h"
#import "DRRobotLeService.h"

@interface DRDevicesTableViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) DRCentralManager *bleManager;
@property (strong, nonatomic) NSTimer *scanTimer;
- (IBAction)didTapRefreshButton:(id)sender;
- (void)appWillResignActive;
- (void)appDidBecomeActive;
@end

@implementation DRDevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bleManager = [DRCentralManager sharedInstance];
    self.bleManager.discoveryDelegate = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(connectionStatusChanged)
                                                 name:kLGPeripheralDidConnect
                                               object:nil];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLGPeripheralDidConnect object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLGPeripheralDidDisconnect object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DRCentralManager sharedInstance] disconnectPeripheral];
    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self startScanning];
}

- (IBAction)didTapRefreshButton:(id)sender {
    [self.bleManager.peripheralNames removeAllObjects];
    [self.scanTimer fire];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    } else {
        return self.bleManager.peripherals.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section > 0) {
        return (self.bleManager.manager.scanning) ? @"Scanning…" : nil;
    } else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    // Configure the cell...
    if (indexPath.section == 0) {
        return [tableView dequeueReusableCellWithIdentifier:@"DemoCell" forIndexPath:indexPath];
    } else {
        static NSString *CellIdentifier = @"DeviceCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
        LGPeripheral *device = self.bleManager.peripherals[indexPath.row];
        cell.textLabel.text = [self.bleManager nameForPeripheral:device];
        cell.detailTextLabel.text = device.UUIDString;
        return cell;
    }
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section > 0) {
        LGPeripheral *peripheral = self.bleManager.peripherals[indexPath.row];
        [[DRCentralManager sharedInstance] connectPeripheral:peripheral completion:^(NSError *error) {
            if (!error && self.bleManager.connectedService) {
                UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
                [self.navigationController pushViewController:vc animated:YES];
            }
        }];
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - LeDiscoveryDelegate

- (void)connectionStatusChanged
{
    DRRobotLeService *service = self.bleManager.connectedService;
    if (service) {
        if (service.peripheral.cbPeripheral.state == CBPeripheralStateDisconnected) {
            if (!service.isManuallyDisconnecting) {// && self.navigationController.viewControllers.count > 1) {
                NSString *msg = @"Lost connection with device.";
                if (service.peripheral && [[DRCentralManager sharedInstance] nameForPeripheral:service.peripheral]) {
                    msg = [msg stringByReplacingOccurrencesOfString:@"device" withString:[[DRCentralManager sharedInstance] nameForPeripheral:service.peripheral]];
                }
                [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:msg delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
            }
        }
    }
}

- (void) discoveryDidRefresh
{
    [self.tableView reloadData];
//    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) discoveryStatePoweredOff
{
    [self.tableView reloadData];
    
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to connect to Dash.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - UIAlertView delegate

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

@end
