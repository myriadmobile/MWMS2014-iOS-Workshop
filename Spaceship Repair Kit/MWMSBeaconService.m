//
//  MWMSBeaconService.m
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import "MWMSBeaconService.h"
#import "MWMSRocketShipPart.h"

#import <CoreLocation/CoreLocation.h>

@interface MWMSBeaconService () <CLLocationManagerDelegate>

@property (nonatomic, strong) NSArray *beaconData;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLBeaconRegion *region;

@end

@implementation MWMSBeaconService

- (instancetype) init
{
    self = [super init];

    if (self)
    {
    }

    return self;
}

#pragma mark - Lazy Loading

- (CLLocationManager *) locationManager
{
    if (!_locationManager)
    {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
    }

    return _locationManager;
}

- (NSArray *) beaconData
{
    if (!_beaconData)
    {
        _beaconData = [MWMSRocketShipPart fakeData];
    }

    return _beaconData;
}

- (CLBeaconRegion *) region
{
    if (!_region)
    {
        // how do they select a uuid?
        // generate an arbitrary one with command line 'uuidgen'
        NSUUID *uuid = [[NSUUID alloc] initWithUUIDString:@"9F52A467-D2D1-4C84-A0DE-136D2053303A"];

        // what does this id mean?
        // generally a reverse domain string that assists identifying a beacon
        _region = [[CLBeaconRegion alloc] initWithProximityUUID:uuid identifier:@"myriadMobile.beacondemo.beaconRegion"];

        // what do these mean
        // do we want to be notified (more importantly - given foreground time) in certain conditions
        _region.notifyOnEntry = YES;
        _region.notifyOnExit = YES;

        // do we want more fine-grained control over state?
        // keeps us safe by not requiring background processing to monitor state
        _region.notifyEntryStateOnDisplay = YES;
    }

    return _region;
}

#pragma mark -

- (void) startMonitoring
{
    // start monitoring a particular region
    // be careful not to call this on a region we're already monitoring OR a region with the same values (id/major/minor)
    // it will stop monitoring the region asynchronously
    [self.locationManager startMonitoringForRegion:self.region];
}

- (void) stopMonitoring
{
    // stop monitoring a particular region
    // same view of equality - id/major/minor
    [self.locationManager stopMonitoringForRegion:self.region];
}

#pragma mark - CLLocationManager Delegate

- (void) locationManager:(CLLocationManager *) manager didStartMonitoringForRegion:(CLRegion *) region
{
    // region monitoring started successfully
    NSLog(@"%@", NSStringFromSelector(_cmd));

    if ([region isKindOfClass:[CLBeaconRegion class]])
    {
        // start calculating ranges for beacons belonging to this region
        [manager startRangingBeaconsInRegion:(CLBeaconRegion *) region];
    }
}

- (void) locationManager:(CLLocationManager *) manager didFailWithError:(NSError *) error
{
    // region monitoring failed.
    // what kind of errors can we expect? -> CLError.h
    NSLog(@"%@ : %@", NSStringFromSelector(_cmd), [error localizedDescription]);

    if ([self.delegate respondsToSelector:@selector(beaconServiceDidFailWithError:)])
    {
        [self.delegate beaconServiceDidFailWithError:error];
    }
}

- (void) locationManager:(CLLocationManager *) manager didRangeBeacons:(NSArray *) beacons inRegion:(CLBeaconRegion *) region
{
    // what happens when you have multiple regions?
    // we can search based on region.identifier. the UUID string is intended to solve that problem.

    // set or clear the last known proximity for each of our objects
    for (MWMSRocketShipPart *content in self.beaconData)
    {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"minor == %@", content.minor];
        CLBeacon *beacon = [[beacons filteredArrayUsingPredicate:predicate] firstObject];

        content.proximity = (beacon) ? beacon.proximity : 0;
    }

    if ([self.delegate respondsToSelector:@selector(beaconContentDidUpdate:)])
    {
        NSArray *sortedBeacons = [self.beaconData sortedArrayUsingSelector:@selector(compare:)];
        [self.delegate beaconContentDidUpdate:sortedBeacons];
    }
}

- (void) locationManager:(CLLocationManager *) manager didEnterRegion:(CLRegion *) region
{
    // how reliable is this?
    // entering typically occurs quickly - within a few seconds.

    // multiple regions? same idea - use identifier.

    // we can have foreground time for this!!

    NSLog(@"%@", NSStringFromSelector(_cmd));

    if ([self.delegate respondsToSelector:@selector(didEnterRegion)])
    {
        [self.delegate didEnterRegion];
    }
}

- (void) locationManager:(CLLocationManager *) manager didExitRegion:(CLRegion *) region
{
    // how reliable is this?
    // entering typically occurs less reliably - can take minutes due to Apple's implementation

    // we can have foreground time for this!!

    NSLog(@"%@", NSStringFromSelector(_cmd));

    if ([self.delegate respondsToSelector:@selector(didExitRegion)])
    {
        [self.delegate didExitRegion];
    }
}

@end
