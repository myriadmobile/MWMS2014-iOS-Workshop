//
//  MWMSRocketShipPart.h
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MWMSRocketShipPart : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *details;

@property (nonatomic, strong) NSNumber *minor;
@property (nonatomic, strong) NSNumber *major;
@property (nonatomic, assign) NSInteger proximity;

- (instancetype) initWithName:(NSString *) name details:(NSString *) details major:(NSNumber *) major minor:(NSNumber *) minor;

- (NSComparisonResult) compare:(MWMSRocketShipPart *) otherPart;
- (NSString *)         proximityString;

+(NSArray *) fakeData;

@end
