//
//  MWMSBeaconService.h
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol  MWMSBeaconServiceDelegate <NSObject>

- (void) beaconContentDidUpdate:(NSArray *) beaconContent;
- (void) beaconServiceDidFailWithError:(NSError *) error;
- (void) didExitRegion;
- (void) didEnterRegion;

@end

@interface MWMSBeaconService : NSObject

@property (nonatomic, weak) id <MWMSBeaconServiceDelegate> delegate;

- (void)      startMonitoring;
- (void)      stopMonitoring;
- (NSArray *) beaconData;

@end
