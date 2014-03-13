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
NSString *kWriteWithoutResponseCharacteristicUUIDString = @"713D0003-503E-4C75-BA94-3148F18D941E";
//NSString *kMinimumTemperatureCharacteristicUUIDString = @"C0C0C0C0-DEAD-F154-1319-740381000000";
//NSString *kMaximumTemperatureCharacteristicUUIDString = @"EDEDEDED-DEAD-F154-1319-740381000000";
//NSString *kAlarmCharacteristicUUIDString = @"AAAAAAAA-DEAD-F154-1319-740381000000";

NSString *kAlarmServiceEnteredBackgroundNotification = @"kAlarmServiceEnteredBackgroundNotification";
NSString *kAlarmServiceEnteredForegroundNotification = @"kAlarmServiceEnteredForegroundNotification";

@interface DRRobotLeService() <CBPeripheralDelegate> {
@private
//    CBPeripheral		*self.peripheral;
//    
    CBService			*_robotService;
//
//    CBCharacteristic    *tempCharacteristic;
    CBCharacteristic	*_writeWoResponseCharacteristic;
//    CBCharacteristic    *maxTemperatureCharacteristic;
//    CBCharacteristic    *alarmCharacteristic;
//    
//    CBUUID              *temperatureAlarmUUID;
    CBUUID              *_writeWoResponseUUID;
//    CBUUID              *maximumTemperatureUUID;
//    CBUUID              *currentTemperatureUUID;
}
@property (readwrite, strong, nonatomic) CBPeripheral *peripheral;
@end



@implementation DRRobotLeService


//@synthesize peripheral = self.peripheral;


#pragma mark -
#pragma mark Init
/****************************************************************************/
/*								Init										*/
/****************************************************************************/
- (id) initWithPeripheral:(CBPeripheral *)peripheral
{
    self = [super init];
    if (self) {
        self.peripheral = peripheral;
        [self.peripheral setDelegate:self];
        
        _writeWoResponseUUID	= [CBUUID UUIDWithString:kWriteWithoutResponseCharacteristicUUIDString];
        self.eyeColor = [UIColor blackColor];
//        maximumTemperatureUUID	= [[CBUUID UUIDWithString:kMaximumTemperatureCharacteristicUUIDString] retain];
//        currentTemperatureUUID	= [[CBUUID UUIDWithString:kCurrentTemperatureCharacteristicUUIDString] retain];
//        temperatureAlarmUUID	= [[CBUUID UUIDWithString:kAlarmCharacteristicUUIDString] retain];
	}
    return self;
}


- (void) dealloc {
	[self reset];
    self.peripheral.delegate = nil;
    self.peripheral = nil;
}


- (void) reset
{
	if (self.peripheral) {
        self.eyeColor = [UIColor blackColor];
        self.motor = CGPointZero;
        [self writeData];
	}
}



#pragma mark -
#pragma mark Service interaction
/****************************************************************************/
/*							Service Interactions							*/
/****************************************************************************/
- (void) start
{
	CBUUID	*serviceUUID	= [CBUUID UUIDWithString:kBiscuitServiceUUIDString];
	NSArray	*serviceArray	= @[serviceUUID];

    [self.peripheral discoverServices:serviceArray];
}

- (void) peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
	NSArray		*services	= nil;
	NSArray		*uuids	= @[];

	if (peripheral != self.peripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
    
    if (error != nil) {
        NSLog(@"Error %@\n", error);
		return ;
	}

	services = [peripheral services];
	if (!services || ![services count]) {
		return ;
	}

	_robotService = nil;
    
	for (CBService *service in services) {
		if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBiscuitServiceUUIDString]]) {
			_robotService = service;
			break;
		}
	}

	if (_robotService) {
		[peripheral discoverCharacteristics:uuids forService:_robotService];
	}
}


- (void) peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error;
{
	NSArray		*characteristics	= [service characteristics];
	CBCharacteristic *characteristic;
    
	if (peripheral != self.peripheral) {
		NSLog(@"Wrong Peripheral.\n");
		return ;
	}
	
	if (service != _robotService) {
		NSLog(@"Wrong Service.\n");
		return ;
	}
    
    if (error != nil) {
		NSLog(@"Error %@\n", error);
		return ;
	}
    
	for (characteristic in characteristics) {
        NSLog(@"discovered characteristic %@", [characteristic UUID]);
        
		if ([[characteristic UUID] isEqual:_writeWoResponseUUID]) { // Min Temperature.
            NSLog(@"Discovered Minimum Alarm Characteristic");
			_writeWoResponseCharacteristic = characteristic;
//			[peripheral readValueForCharacteristic:characteristic];
		}
//        else if ([[characteristic UUID] isEqual:maximumTemperatureUUID]) { // Max Temperature.
//            NSLog(@"Discovered Maximum Alarm Characteristic");
//			maxTemperatureCharacteristic = [characteristic retain];
//			[peripheral readValueForCharacteristic:characteristic];
//		}
//        else if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) { // Alarm
//            NSLog(@"Discovered Alarm Characteristic");
//			alarmCharacteristic = [characteristic retain];
//            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
//		}
//        else if ([[characteristic UUID] isEqual:currentTemperatureUUID]) { // Current Temp
//            NSLog(@"Discovered Temperature Characteristic");
//			tempCharacteristic = [characteristic retain];
//			[peripheral readValueForCharacteristic:tempCharacteristic];
//			[peripheral setNotifyValue:YES forCharacteristic:characteristic];
//		} 
	}
}

//- (void)setLeftMotor:(NSInteger)leftMotor {
//    _leftMotor = leftMotor;
//    [self writeData];
//}
//
//- (void)setRightMotor:(NSInteger)rightMotor {
//    _rightMotor = rightMotor;
//    [self writeData];
//}

- (void)setMotor:(CGPoint)motor {
    _motor = motor;
    [self writeData];
}

#pragma mark -
#pragma mark Characteristics interaction

- (void) writeData
{
    // mtrA1, mtrA2, mtrB1, mtrB2, eyesRed, eyesGreen, eyesBlue
    
    NSMutableData *data = [NSMutableData dataWithCapacity:7];
    
    uint8_t mtrA1, mtrA2, mtrB1, mtrB2;
    
    if (self.motor.x >= 0) {
        mtrA1 = (uint8_t)round(self.motor.x);
        mtrA2 = 0;
    } else {
        mtrA1 = 0;
        mtrA2 = (uint8_t)round(-self.motor.x);
    }
    
    if (self.motor.y >= 0) {
        mtrB1 = (uint8_t)round(self.motor.y);
        mtrB2 = 0;
    } else {
        mtrB1 = 0;
        mtrB2 = (uint8_t)round(-self.motor.y);
    }
    
//    uint8_t mtrA1 = (uint8_t)MAX(0, self.motor.x);
//    uint8_t mtrA2 = (uint8_t)ABS(MIN(0, self.motor.x));
//    
//    uint8_t mtrB1 = (uint8_t)MAX(0, self.motor.y);
//    uint8_t mtrB2 = (uint8_t)ABS(MIN(0, self.motor.y));
    
    CGFloat red = 0.0, green = 0.0, blue = 0.0, alpha =0.0;
    [self.eyeColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    uint8_t eyesRed = (uint8_t)(red * 255);
    uint8_t eyesGreen = (uint8_t)(green * 255);
    uint8_t eyesBlue = (uint8_t)(blue * 255);
    
    //(self.leftMotor >= 0) ? (uint8_t)self.leftMotor : 0;
    
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
    
    [self.peripheral writeValue:data forCharacteristic:_writeWoResponseCharacteristic type:CBCharacteristicWriteWithoutResponse];
    NSLog(@"data %@", data);
}


//- (void) writeHighAlarmTemperature:(int)high
//{
//    NSData  *data	= nil;
//    int16_t value	= (int16_t)high;
//
//    if (!self.peripheral) {
//        NSLog(@"Not connected to a peripheral");
//    }
//
//    if (!maxTemperatureCharacteristic) {
//        NSLog(@"No valid minTemp characteristic");
//        return;
//    }
//
//    data = [NSData dataWithBytes:&value length:sizeof (value)];
//    [self.peripheral writeValue:data forCharacteristic:maxTemperatureCharacteristic type:CBCharacteristicWriteWithResponse];
//}


/** If we're connected, we don't want to be getting temperature change notifications while we're in the background.
 We will want alarm notifications, so we don't turn those off.
 */
- (void)enteredBackground
{
    // Find the fishtank service
    for (CBService *service in [self.peripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBiscuitServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kWriteWithoutResponseCharacteristicUUIDString]] ) {
                    
                    // And STOP getting notifications from it
                    [self.peripheral setNotifyValue:NO forCharacteristic:characteristic];
                }
            }
        }
    }
}

/** Coming back from the background, we want to register for notifications again for the temperature changes */
- (void)enteredForeground
{
    // Find the fishtank service
    for (CBService *service in [self.peripheral services]) {
        if ([[service UUID] isEqual:[CBUUID UUIDWithString:kBiscuitServiceUUIDString]]) {
            
            // Find the temperature characteristic
            for (CBCharacteristic *characteristic in [service characteristics]) {
                if ( [[characteristic UUID] isEqual:[CBUUID UUIDWithString:kWriteWithoutResponseCharacteristicUUIDString]] ) {
                    
                    // And START getting notifications from it
                    [self.peripheral setNotifyValue:YES forCharacteristic:characteristic];
                }
            }
        }
    }
}

//- (CGFloat) minimumTemperature
//{
//    CGFloat result  = NAN;
//    int16_t value	= 0;
//	
//    if (minTemperatureCharacteristic) {
//        [[minTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
//        result = (CGFloat)value / 10.0f;
//    }
//    return result;
//}
//
//
//- (CGFloat) maximumTemperature
//{
//    CGFloat result  = NAN;
//    int16_t	value	= 0;
//    
//    if (maxTemperatureCharacteristic) {
//        [[maxTemperatureCharacteristic value] getBytes:&value length:sizeof (value)];
//        result = (CGFloat)value / 10.0f;
//    }
//    return result;
//}
//
//
//- (CGFloat) temperature
//{
//    CGFloat result  = NAN;
//    int16_t	value	= 0;
//
//	if (tempCharacteristic) {
//        [[tempCharacteristic value] getBytes:&value length:sizeof (value)];
//        result = (CGFloat)value / 10.0f;
//    }
//    return result;
//}


- (void) peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
//    uint8_t alarmValue  = 0;
    
	if (peripheral != self.peripheral) {
		NSLog(@"Wrong peripheral\n");
		return ;
	}

    if ([error code] != 0) {
		NSLog(@"Error %@\n", error);
		return ;
	}

//    /* Temperature change */
//    if ([[characteristic UUID] isEqual:currentTemperatureUUID]) {
//        [self.delegate alarmServiceDidChangeTemperature:self];
//        return;
//    }
//    
//    /* Alarm change */
//    if ([[characteristic UUID] isEqual:temperatureAlarmUUID]) {
//
//        /* get the value for the alarm */
//        [[alarmCharacteristic value] getBytes:&alarmValue length:sizeof (alarmValue)];
//
//        NSLog(@"alarm!  0x%x", alarmValue);
//        if (alarmValue & 0x01) {
//            /* Alarm is firing */
//            if (alarmValue & 0x02) {
//                [self.delegate alarmService:self didSoundAlarmOfType:kAlarmLow];
//			} else {
//                [self.delegate alarmService:self didSoundAlarmOfType:kAlarmHigh];
//			}
//        } else {
//            [self.delegate alarmServiceDidStopAlarm:self];
//        }
//
//        return;
//    }
//
//    /* Upper or lower bounds changed */
//    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
//        [self.delegate alarmServiceDidChangeTemperatureBounds:self];
//    }
}

- (void) peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    /* When a write occurs, need to set off a re-read of the local CBCharacteristic to update its value */
    [peripheral readValueForCharacteristic:characteristic];
    
//    /* Upper or lower bounds changed */
//    if ([characteristic.UUID isEqual:minimumTemperatureUUID] || [characteristic.UUID isEqual:maximumTemperatureUUID]) {
//        [self.delegate alarmServiceDidChangeTemperatureBounds:self];
//    }
}
@end
