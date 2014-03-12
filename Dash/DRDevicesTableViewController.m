//
//  DRDevicesTableViewController.m
//  Dash
//
//  Created by Adam Overholtzer on 3/9/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRDevicesTableViewController.h"
#import "DRRobotLeService.h"


@interface DRDevicesTableViewController ()
@property (weak, nonatomic) LeDiscovery *bleManager;
@end

@implementation DRDevicesTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

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
    [[LeDiscovery sharedInstance] startScanningForUUIDString:kTemperatureServiceUUIDString];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackgroundNotification:) name:kAlarmServiceEnteredBackgroundNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterForegroundNotification:) name:kAlarmServiceEnteredForegroundNotification object:nil];
}

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

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DeviceCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        cell.textLabel.text = @"UI Test";
        cell.detailTextLabel.text = @"No robot—just play with the controls";
    } else {
        DRRobotLeService *service = self.bleManager.foundPeripherals[indexPath.row];
        cell.textLabel.text = service.peripheral.name;
        cell.detailTextLabel.text = service.peripheral.identifier.UUIDString;
    }
    
    return cell;
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

//// In a story board-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
//{
//    if ([segue isKindOfClass:[UITableViewCell class]]) {
//        UITableViewCell *cell = (UITableViewCell *)segue;
//        NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
//    }
//}

#pragma mark - LeDiscoveryDelegate

- (void)serviceDidChangeStatus:(DRRobotLeService *)service {
    if (service.peripheral.state == CBPeripheralStateConnected) {
        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"DriveController"];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
}

- (void) discoveryDidRefresh
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void) discoveryStatePoweredOff
{
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    NSString *title     = @"Bluetooth Power";
    NSString *message   = @"You must turn on Bluetooth in Settings in order to connect to Dash.";
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}


@end
