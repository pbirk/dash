//
//  DRCentralManager.h
//  Dash
//
//  Created by Adam Overholtzer on 3/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import "LGCentralManager.h"

@class DRRobotLeService;

#define SCAN_INTERVAL 5.0

/****************************************************************************/
/*							UI protocols									*/
/****************************************************************************/
@protocol DRDiscoveryDelegate <NSObject>
- (void) discoveryDidRefresh;
- (void) stoppedScanning;
- (void) discoveryStatePoweredOff;
- (void) connectionStatusChanged;
@end

@interface DRRobotProperties : NSObject
- (id)initWithName:(NSString *)name color:(UIColor *)color;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIColor *color;
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

@end
