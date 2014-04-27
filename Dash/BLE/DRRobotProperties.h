//
//  DRRobotProperties.h
//  Dash
//
//  Created by Adam Overholtzer on 4/27/14.
//  Copyright (c) 2014 Dash Robotics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DRRobotLeService.h"

@interface DRRobotProperties : NSObject

@property (strong, nonatomic) NSString *name;
@property NSUInteger color, robotType, codeVersion;

- (id)initWithName:(NSString *)name color:(NSUInteger)color;

+ (instancetype)robotPropertiesWithData:(NSData *)data;

@end
