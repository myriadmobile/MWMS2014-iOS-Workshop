//
//  MWMSRocketShipPart.m
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import "MWMSRocketShipPart.h"

#import <CoreLocation/CoreLocation.h>

@implementation MWMSRocketShipPart

- (instancetype) initWithName:(NSString *) name details:(NSString *) details major:(NSNumber *) major minor:(NSNumber *) minor
{
    self = [super init];

    if (self)
    {
        self.name = name;
        self.details = details;

        self.minor = minor;
        self.major = major;
    }

    return self;
}

- (NSComparisonResult) compare:(MWMSRocketShipPart *) otherBeacon
{
    NSComparisonResult result = [@(self.proximity)compare : @(otherBeacon.proximity)];

    if (result == NSOrderedSame)
    {
        return [self.name compare:otherBeacon.name options:NSNumericSearch];
    }
    else if (self.proximity == CLProximityUnknown)
    {
        return NSOrderedDescending;
    }
    else if (otherBeacon.proximity == CLProximityUnknown)
    {
        return NSOrderedAscending;
    }
    else
    {
        return result;
    }
}

- (NSString *) proximityString
{
    switch (self.proximity)
    {
        case CLProximityFar :
            return @"In range.";

            break;

        case CLProximityNear :
            return @"Getting warmer...";

            break;

        case CLProximityImmediate :
            return @"Right next to you!";

            break;

        case CLProximityUnknown :
        default :
            return @"Out of range.";

            break;
    }
}

+ (NSArray *) fakeData
{
    return @[
        [[MWMSRocketShipPart alloc] initWithName:@"Paperclip" details:@"A vital component of space shuttles. Never be without one!"  major:@0 minor:@1],
        [[MWMSRocketShipPart alloc] initWithName:@"Duct Tape" details:@"Seriously, like 80% of this thing is held together by duct tape." major:@0 minor:@2],
        [[MWMSRocketShipPart alloc] initWithName:@"Old sock" details:@"Not technically useful. Present from Grandma." major:@0 minor:@3],
        [[MWMSRocketShipPart alloc] initWithName:@"Road flare" details:@"Not... not really too sure what this one was for." major:@0 minor:@4]
    ];
}

@end
