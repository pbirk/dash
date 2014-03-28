//
//  DRCentralManager.h
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "LGCentralManager.h"

@class DRRobotLeService;

/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol DRDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) discoveryStatePoweredOff;
- (void) connectionStatusChanged;
@end

@interface DRCentralManager : NSObject

+ (DRCentralManager *)sharedInstance;

- (LGCentralManager *)manager;
- (NSArray *)peripherals;

@property (nonatomic, assign) id<DRDiscoveryDelegate> discoveryDelegate;
@property (nonatomic, strong) NSMutableDictionary *peripheralNames;
@property (nonatomic, strong) DRRobotLeService *connectedService;

- (void) startScanning;
- (void) stopScanning;

- (void) connectPeripheral:(LGPeripheral*)peripheral completion:(LGPeripheralConnectionCallback)aCallback;
- (void) disconnectPeripheral;

- (NSString *)nameForPeripheral:(LGPeripheral*)peripheral;

@end
