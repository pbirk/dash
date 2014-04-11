//
//  DRCentralManager.m
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "DRCentralManager.h"
#import "DRRobotLeService.h"

@implementation DRCentralManager

static DRCentralManager *_sharedInstance = nil;

+ (DRCentralManager *)sharedInstance
{
    // Thread blocking to be sure for singleton instance
	@synchronized(self) {
		if (!_sharedInstance) {
			_sharedInstance = [DRCentralManager new];
            _sharedInstance.peripheralNames = [NSMutableDictionary new];
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
        if (![self.peripheralNames objectForKey:peripheral.UUIDString]) {
            [LGUtils readDataFromCharactUUID:kRead1CharacteristicUUIDString serviceUUID:kBiscuitServiceUUIDString peripheral:peripheral completion:^(NSData *data, NSError *error) {
                if (data) {
                    NSString* newStr = [NSString stringWithUTF8String:[data bytes]];
                    [self.peripheralNames setObject:newStr forKey:peripheral.UUIDString];
                    [self.discoveryDelegate discoveryDidRefresh];
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
    
    [self.manager scanForPeripheralsByInterval:6 services:uuidArray options:options completion:^(NSArray *peripherals) {
        [self.discoveryDelegate stoppedScanning];
    }];
    [self.discoveryDelegate discoveryDidRefresh];
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

- (NSString *)nameForPeripheral:(LGPeripheral *)peripheral {
    return [self.peripheralNames objectForKey:peripheral.UUIDString];
}

@end
