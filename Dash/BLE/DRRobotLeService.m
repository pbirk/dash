/*

 File: LeTemperatureAlarmService.m
 
 Abstract: Temperature Alarm Service Code - Connect to a peripheral 
 get notified when the temperature changes and goes past settable
 maximum and minimum temperatures.
 
 Version: 1.0
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by 
 Apple Inc. ("Apple") in consideration of your agreement to the
 following terms, and your use, installation, modification or
 redistribution of this Apple software constitutes acceptance of these
 terms.  If you do not agree with these terms, please do not use,
 install, modify or redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software. 
 Neither the name, trademarks, service marks or logos of Apple Inc. 
 may be used to endorse or promote products derived from the Apple
 Software without specific prior written permission from Apple.  Except
 as expressly stated in this notice, no other rights or licenses, express
 or implied, are granted by Apple herein, including but not limited to
 any patent rights that may be infringed by your derivative works or by
 other works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2011 Apple Inc. All Rights Reserved.
 
 */



#import "DRRobotLeService.h"
#import "LeDiscovery.h"


NSString *kBiscuitServiceUUIDString = @"713D0000-503E-4C75-BA94-3148F18D941E";
NSString *kRead1CharacteristicUUIDString = @"713D0001-503E-4C75-BA94-3148F18D941E";
NSString *kWriteWithoutResponseCharacteristicUUIDString = @"713D0003-503E-4C75-BA94-3148F18D941E";

//NSString *kAlarmServiceEnteredBackgroundNotification = @"kAlarmServiceEnteredBackgroundNotification";
//NSString *kAlarmServiceEnteredForegroundNotification = @"kAlarmServiceEnteredForegroundNotification";

@interface DRRobotLeService() {
@private
    LGService			*_robotService;
    LGCharacteristic	*_writeWoResponseCharacteristic;
//    CBUUID              *_writeWoResponseUUID;
}
@property (readwrite, strong, nonatomic) LGPeripheral *peripheral;
@end



@implementation DRRobotLeService

#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(LGPeripheral *)peripheral
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
//        [self.peripheral setDelegate:self];
        
//        _writeWoResponseUUID	= [CBUUID UUIDWithString:kWriteWithoutResponseCharacteristicUUIDString];
        self.eyeColor = [UIColor blackColor];
        
        CBUUID *serviceUuid = [CBUUID UUIDWithString:kBiscuitServiceUUIDString];
        
        [self.peripheral discoverServices:@[serviceUuid] completion:^(NSArray *services, NSError *error) {
            for (LGService *service in services) {
                if ([service.UUIDString isEqualToString:kBiscuitServiceUUIDString]) {
                    _robotService = service;
                    [_robotService discoverCharacteristicsWithCompletion:^(NSArray *characteristics, NSError *error) {
                        for (LGCharacteristic *characteristic in characteristics) {
                            NSLog(@"discovered characteristic %@", characteristic.UUIDString);
                            
                            if ([characteristic.UUIDString isEqualToString:kWriteWithoutResponseCharacteristicUUIDString]) {
                                NSLog(@"Discovered write without response");
                                _writeWoResponseCharacteristic = characteristic;
                            }
                        }

                    }];
                    break;
                }
            }
        }];
    }
    return self;
}


- (void) dealloc {
	[self reset];
//    self.peripheral.delegate = nil;
    self.peripheral = nil;
}

- (void) reset
{
	if (self.peripheral) {
        self.motor = DRMotorsMakeZero();
        self.eyeColor = [UIColor blackColor];
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
//- (void) start
//{
//	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kBiscuitServiceUUIDString];
//    [self.peripheral discoverServices:@[serviceUUID]];
//}

//- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
//{
//	NSArray		*services	= nil;
//	NSArray		*uuids	= @[];
//
//	if (peripheral != self.peripheral) {
//		NSLog(@"Wrong Peripheral.\n");
//		return ;
//	}
//    
//    if (error != nil) {
//        NSLog(@"Error %@\n", error);
//		return ;
//	}
//
//	services = [peripheral services];
//	if (!services || ![services count]) {
//		return ;
//	}
//
//	_robotService = nil;
//    
//	for (CBService *service in services) {
//		if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBiscuitServiceUUIDString]]) {
//			_robotService = service;
//			break;
//		}
//	}
//
//	if (_robotService) {
//		[peripheral discoverCharacteristics:uuids forService:_robotService];
//	}
//}


//- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
//{
//	NSArray		*characteristics	= [service characteristics];
//	CBCharacteristic *characteristic;
//    
//	if (peripheral != self.peripheral) {
//		NSLog(@"Wrong Peripheral.\n");
//		return ;
//	}
//	
//	if (service != _robotService) {
//		NSLog(@"Wrong Service.\n");
//		return ;
//	}
//    
//    if (error != nil) {
//		NSLog(@"Error %@\n", error);
//		return ;
//	}
//    
//	for (characteristic in characteristics) {
//        NSLog(@"discovered characteristic %@", [characteristic UUID]);
//        
//		if ([[characteristic UUID] isEqual:_writeWoResponseUUID]) {
//            NSLog(@"Discovered write without response");
//			_writeWoResponseCharacteristic = characteristic;
//		}
////        else if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) { // Alarm
////            NSLog(@"Discovered Alarm Characteristic");
////			alarmCharacteristic = [characteristic retain];
////            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
////		}
//	}
//}

- (void)setMotor:(DRMotors)motor {
    _motor = motor;
    [self writeData];
}

- (void)setEyeColor:(UIColor *)eyeColor {
    _eyeColor = eyeColor;
    [self writeData];
}

#pragma mark -
#pragma mark Characteristics interaction

- (void) writeData
{
    // mtrA1, mtrA2, mtrB1, mtrB2, eyesRed, eyesGreen, eyesBlue
    
    NSMutableData *data = [NSMutableData dataWithCapacity:7];
    
    uint8_t mtrA1, mtrA2, mtrB1, mtrB2;
    
    if (self.motor.left >= 0) {
        mtrA1 = (uint8_t)round(self.motor.left);
        mtrA2 = 0;
    } else {
        mtrA1 = 0;
        mtrA2 = (uint8_t)round(-self.motor.left);
    }
    
    if (self.motor.right >= 0) {
        mtrB1 = (uint8_t)round(self.motor.right);
        mtrB2 = 0;
    } else {
        mtrB1 = 0;
        mtrB2 = (uint8_t)round(-self.motor.right);
    }
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self.eyeColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    uint8_t eyesRed = (uint8_t)(red * 255);
    uint8_t eyesGreen = (uint8_t)(green * 255);
    uint8_t eyesBlue = (uint8_t)(blue * 255);
    
    if (!self.peripheral) {
        NSLog(@"Not connected to a peripheral!");
		return ;
    }

    if (!_writeWoResponseCharacteristic) {
        NSLog(@"No valid characteristic!");
        return;
    }
    
    [data appendBytes:&mtrA1 length:sizeof(mtrA1)];
    [data appendBytes:&mtrA2 length:sizeof(mtrA2)];
    [data appendBytes:&mtrB1 length:sizeof(mtrB1)];
    [data appendBytes:&mtrB2 length:sizeof(mtrB2)];
    
    [data appendBytes:&eyesRed length:sizeof(eyesRed)];
    [data appendBytes:&eyesGreen length:sizeof(eyesGreen)];
    [data appendBytes:&eyesBlue length:sizeof(eyesBlue)];
    
    [_writeWoResponseCharacteristic writeValue:data completion:nil];
//    [self.peripheral writeValue:data forCharacteristic:_writeWoResponseCharacteristic type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"data %@", data);
}

@end
