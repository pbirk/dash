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

struct DRMotors {
    CGFloat left;
    CGFloat right;
};
typedef struct DRMotors DRMotors;

static inline DRMotors
DRMotorsMake(CGFloat left, CGFloat right)
{
    DRMotors p; p.left = left; p.right = right; return p;
}
static inline DRMotors
DRMotorsMakeZero()
{
    return DRMotorsMake(0, 0);
}

/****************************************************************************/
/*						Service Characteristics								*/
/****************************************************************************/
extern NSString *kBiscuitServiceUUIDString;                 // 713D0000-503E-4C75-BA94-3148F18D941E     Service UUID
extern NSString *kRead1CharacteristicUUIDString;                 // 713D0001-503E-4C75-BA94-3148F18D941E     First read characteristic
extern NSString *kWriteWithoutResponseCharacteristicUUIDString;   // 713D0003-503E-4C75-BA94-3148F18D941E     Write W/O Response Characteristic

//extern NSString *kAlarmServiceEnteredBackgroundNotification;
//extern NSString *kAlarmServiceEnteredForegroundNotification;

/****************************************************************************/
/*								Protocol									*/
/****************************************************************************/
@class DRRobotLeService;


@protocol DRRobotLeServiceDelegate<NSObject>
//- (void) serviceDidChangeStatus:(DRRobotLeService*)service;
//- (void) alarmServiceDidReset;
@end


/****************************************************************************/
/*						Temperature Alarm service.                          */
/****************************************************************************/
@interface DRRobotLeService : NSObject

@property (nonatomic) DRMotors motor;
@property BOOL isManuallyDisconnecting;
@property (strong, nonatomic) UIColor *eyeColor;

- (id) initWithPeripheral:(LGPeripheral *)peripheral;
- (void) reset;
//- (void) start;

@property (strong, nonatomic) id<DRRobotLeServiceDelegate> delegate;

///* Behave properly when heading into and out of the background */
//- (void)enteredBackground;
//- (void)enteredForeground;

@property (readonly) LGPeripheral *peripheral;
@end
