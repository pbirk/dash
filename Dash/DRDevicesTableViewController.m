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
@property (weak, nonatomic) LeDiscovery *bleManager;
//- (void)appWillResignActive;
//- (void)appDidBecomeActive;
@end

@implementation DRDevicesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.bleManager = [LeDiscovery sharedInstance];
    self.bleManager.discoveryDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[LeDiscovery sharedInstance] disconnectAllPeripherals];
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kBiscuitServiceUUIDString];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kAlarmServiceEnteredBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kAlarmServiceEnteredForegroundNotification object:nil];
}

//- (void)appWillResignActive
//{
//    [[LeDiscovery sharedInstance] stopScanning];
//}
//
//- (void)appDidBecomeActive
//{
//    if (self.isViewLoaded && self.view.superview) {
//        [[LeDiscovery sharedInstance] startScanningForUUIDString:kBiscuitServiceUUIDString];
//    }
//}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[LeDiscovery sharedInstance] stopScanning];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
        return self.bleManager.foundPeripherals.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if (section > 0) {
        return @"Scanning…";
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
        
        CBPeripheral *device = self.bleManager.foundPeripherals[indexPath.row];
        cell.textLabel.text = device.identifier.UUIDString;
        return cell;
    }
}

#pragma mark - Navigation

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section > 0) {
        CBPeripheral *peripheral = [[LeDiscovery sharedInstance] foundPeripherals][indexPath.row];
        if (peripheral.state == CBPeripheralStateDisconnected) {
            [[LeDiscovery sharedInstance] connectPeripheral:peripheral];
        }
    } else {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - LeDiscoveryDelegate

- (void)serviceDidChangeStatus:(DRRobotLeService *)service
{
    if (service.peripheral.state == CBPeripheralStateConnected) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        if (!service.disconnecting) {// && self.navigationController.viewControllers.count > 1) {
            NSString *msg = @"Lost connection with device.";
            if (service.peripheral) {
                msg = [msg stringByReplacingOccurrencesOfString:@"device" withString:service.peripheral.identifier.UUIDString];
            }
            [[[UIAlertView alloc] initWithTitle:@"Disconnected" message:msg delegate:self cancelButtonTitle:@"Shucks" otherButtonTitles:nil] show];
        }
    }
}

- (void) discoveryDidRefresh
{
    [self.tableView reloadData];
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
