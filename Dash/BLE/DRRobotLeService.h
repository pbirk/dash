/*
 
 File: LeTemperatureAlarmService.h
 
 Abstract: Temperature Alarm Service Header - Connect to a peripheral 
 and get notified when the temperature changes and goes past settable
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



#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "LGBluetooth.h"

//struct DRMotors {
//    CGFloat left;
//    CGFloat right;
//};
//typedef struct DRMotors DRMotors;
//
//static inline DRMotors
//DRMotorsMake(CGFloat left, CGFloat right)
//{
//    DRMotors p; p.left = left; p.right = right; return p;
//}
//static inline DRMotors
//DRMotorsMakeZero()
//{
//    return DRMotorsMake(0, 0);
//}

static NSUInteger const PACKET_SIZE = 14;
static NSUInteger const MAX_NAME_LENGTH = 10;

typedef NS_ENUM(char, DRMessageTypes) {
    DRMessageTypeName = '1',
    DRMessageTypeSignals = '2'
};

typedef NS_ENUM(char, DRCommandTypes) {
    DRCommandTypeAllStop = '0',
    DRCommandTypeSetName = '1',
    DRCommandTypeDirectDrive = '2',
    DRCommandTypeGyroDrive = '3',
    DRCommandTypeSetEyes = '4',
};
                        // Dark Blue, Red, Holiday Green, Lemon Yellow, Black, Orange
#define ROBOT_COLORS @[ [UIColor lightGrayColor], \
                        [UIColor colorWithRed:0.191 green:0.287 blue:0.611 alpha:1.000], \
                        [UIColor colorWithRed:0.905 green:0.150 blue:0.119 alpha:1.000], \
                        [UIColor colorWithRed:0.149 green:0.591 blue:0.279 alpha:1.000], \
                        [UIColor colorWithRed:0.929 green:0.799 blue:0.145 alpha:1.000], \
                        [UIColor colorWithRed:0.136 green:0.147 blue:0.157 alpha:1.000], \
                        [UIColor colorWithRed:0.952 green:0.501 blue:0.115 alpha:1.000], \
                      ]
typedef NS_ENUM(NSUInteger, DRRobotColorNames) {
    DRColorUndefined = 0,
    DRBlue,
    DRRedRobot,
    DRGreenRobot,
    DRYellowRobot,
    DRBlackRobot,
    DROrangeRobot,
};

/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kBiscuitServiceUUIDString;                     // Service UUID
extern NSString *kRead1CharacteristicUUIDString;                // First read characteristic
extern NSString *kNotifyCharacteristicUUIDString;                // Notify characteristic
extern NSString *kWriteWithoutResponseCharacteristicUUIDString; // Write w/o Response Characteristic

//extern NSString *kAlarmServiceEnteredBackgroundNotification;
//extern NSString *kAlarmServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class DRRobotLeService, DRSignalPacket;


@protocol DRRobotLeServiceDelegate<NSObject>
//- (void) serviceDidChangeStatus:(DRRobotLeService*)service;
//- (void) alarmServiceDidReset;
- (void) receivedNotifyWithData:(NSData *)data;
- (void) receivedNotifyWithSignals:(DRSignalPacket *)signals;
@end

/****************************************************************************/
/*                          Attributes of robot.                            */
/****************************************************************************/

@interface DRRobotProperties : NSObject
- (id)initWithName:(NSString *)name color:(NSUInteger)color;
@property (strong, nonatomic) NSString *name;
@property NSUInteger color;
@end

/****************************************************************************/
/*                              Robot service.                              */
/****************************************************************************/
@interface DRRobotLeService : NSObject

@property BOOL isManuallyDisconnecting;

- (id) initWithPeripheral:(LGPeripheral *)peripheral;
- (void) disconnect;

- (void) reset;
- (void) setLeftMotor:(CGFloat)leftMotor rightMotor:(CGFloat)rightMotor;
- (void) setThrottle:(CGFloat)throttle direction:(CGFloat)direction;
- (void) setRobotProperties:(DRRobotProperties *)properties;

@property (strong, nonatomic) UIColor *eyeColor;
//- (void) setEyeColor:(UIColor *)color;
@property BOOL useGyroDrive;
@property (strong, nonatomic) id<DRRobotLeServiceDelegate> delegate;

///* Behave properly when heading into and out of the background */
//- (void)enteredBackground;
//- (void)enteredForeground;

@property (readonly) LGPeripheral *peripheral;
@end
