//
//  DRCentralManager.m
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRCentralManager.h"
#import "DRRobotLeService.h"
#import "DRRobotProperties.h"

@implementation DRCentralManager

static DRCentralManager *_sharedInstance = nil;

+ (DRCentralManager *)sharedInstance
{
    // Thread blocking to be sure for singleton instance
	@synchronized(self) {
		if (!_sharedInstance) {
			_sharedInstance = [DRCentralManager new];
            _sharedInstance.peripheralProperties = [NSMutableDictionary new];
            _sharedInstance.manager.delegate = _sharedInstance;
		}
	}
	return _sharedInstance;
}

- (LGCentralManager *)manager {
    return [LGCentralManager sharedInstance];
}
- (NSArray *)peripherals {
    return self.manager.peripherals;
}

- (void)updatedScannedPeripherals {
    for (LGPeripheral *peripheral in self.peripherals) {
        if (![self.peripheralProperties objectForKey:peripheral.UUIDString]) {
            [LGUtils readDataFromCharactUUID:kNotifyCharacteristicUUIDString serviceUUID:kBiscuitServiceUUIDString peripheral:peripheral completion:^(NSData *data, NSError *error) {
                if (data) {
                    DRRobotProperties *robot = [DRRobotProperties robotPropertiesWithData:data];
                    if (robot) [self.peripheralProperties setObject:robot forKey:peripheral.UUIDString];
                    [self.discoveryDelegate discoveryDidRefresh];
                }
                if (!data || error) {
                    NSLog(@"Error getting name/color: %@", error);
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error getting name" message:[NSString stringWithFormat:@"Unable to fetch name. %@", error] delegate:nil cancelButtonTitle:@"Bummer" otherButtonTitles:nil];
//                    [alert performSelectorOnMainThread:@selector(show) withObject:nil waitUntilDone:NO];
                }
                [peripheral disconnectWithCompletion:nil];
            }];
        }
    }
    [self.discoveryDelegate discoveryDidRefresh];
}

- (void)startScanning {
	NSArray			*uuidArray	= @[[CBUUID UUIDWithString:kBiscuitServiceUUIDString]];
	NSDictionary	*options	= @{CBCentralManagerScanOptionAllowDuplicatesKey: @NO};
    
    [self.manager scanForPeripheralsByInterval:SCAN_INTERVAL services:uuidArray options:options completion:^(NSArray *peripherals) {
        [self.discoveryDelegate stoppedScanning];
    }];
//    [self.discoveryDelegate discoveryDidRefresh];
}

- (void)stopScanning {
    [self.manager stopScanForPeripherals];
    [self.discoveryDelegate stoppedScanning];
}

- (void)connectPeripheral:(LGPeripheral *)peripheral completion:(LGPeripheralConnectionCallback)aCallback{
    [peripheral connectWithCompletion:^(NSError *error) {
        if (!error) {
            self.connectedService = [[DRRobotLeService alloc] initWithPeripheral:peripheral];
        }
        if (aCallback) {
            aCallback(error);
        }
    }];
}

- (void)disconnectPeripheral {
    if (self.connectedService) {
        [self.connectedService disconnect];
        [self.connectedService.peripheral performSelector:@selector(disconnectWithCompletion:) withObject:^(NSError *error) {
            self.connectedService = nil;
            [self.discoveryDelegate discoveryDidRefresh];
        } afterDelay:0.1];
    }
}

- (DRRobotProperties *)propertiesForPeripheral:(LGPeripheral *)peripheral {
    return [self.peripheralProperties objectForKey:peripheral.UUIDString];
}

- (DRRobotProperties *)propertiesForConnectedService {
    if (self.connectedService && self.connectedService.peripheral) {
        return [self propertiesForPeripheral:self.connectedService.peripheral];
    } else {
        return nil;
    }
}

- (void)updateProperties:(DRRobotProperties *)properties forPeripheral:(LGPeripheral *)periperhal {
    if (properties && periperhal) {
        [self.peripheralProperties setObject:properties forKey:periperhal.UUIDString];
    }
}

@end
