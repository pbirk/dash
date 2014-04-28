//
//  DRCentralManager.h
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "LGCentralManager.h"

@class DRRobotLeService, DRRobotProperties;

static NSTimeInterval const SCAN_INTERVAL = 5.0;

/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol DRDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) stoppedScanning;
- (void) discoveryStatePoweredOff;
@end

@interface DRCentralManager : NSObject <LGCentralManagerDelegate>

+ (DRCentralManager *)sharedInstance;

- (LGCentralManager *)manager;
- (NSArray *)peripherals;

@property (nonatomic, assign) id<DRDiscoveryDelegate> discoveryDelegate;
@property (nonatomic, strong) NSMutableDictionary *peripheralProperties;
@property (nonatomic, strong) DRRobotLeService *connectedService;

- (void) startScanning;
- (void) stopScanning;

- (void) connectPeripheral:(LGPeripheral*)peripheral completion:(LGPeripheralConnectionCallback)aCallback;
- (void) disconnectPeripheral;

- (DRRobotProperties *)propertiesForPeripheral:(LGPeripheral*)peripheral;
- (DRRobotProperties *)propertiesForConnectedService;

- (void)updateProperties:(DRRobotProperties *)properties forPeripheral:(LGPeripheral *)periperhal;

@end
