//
//  MWMSBeaconService.m
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import "MWMSBeaconService.h"
#import "MWMSRocketShipPart.h"

@interface MWMSBeaconService ()

@end

@implementation MWMSBeaconService

#pragma mark - Lazy Loading

- (NSArray *)beaconData
{
	return [MWMSRocketShipPart fakeData];
}

#pragma mark -

- (void)startMonitoring
{
}

- (void)stopMonitoring
{
}

@end
