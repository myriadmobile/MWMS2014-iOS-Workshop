//
//  MWMSViewController.m
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/3/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import "MWMSViewController.h"

// our headers
#import "MWMSBeaconService.h"
#import "MWMSRocketShipPart.h"
#import "MWMSPartCell.h"

#import <CoreLocation/CoreLocation.h>

@interface MWMSViewController () <MWMSBeaconServiceDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) MWMSBeaconService *beaconService;
@property (nonatomic, strong) MWMSRocketShipPart *itemToCollect;
@property (nonatomic, strong) NSMutableArray *collectedItems;

@property (nonatomic, copy) NSArray *beaconContent;

@property (nonatomic, assign, getter = isDisplayingAlert) BOOL displayingAlert;


@end

@implementation MWMSViewController

#pragma mark - Lazy Loading

- (MWMSBeaconService *) beaconService
{
    if (!_beaconService)
    {
        _beaconService = [[MWMSBeaconService alloc] init];
        _beaconService.delegate = self;
    }

    return _beaconService;
}

- (NSMutableArray *) collectedItems
{
    if (!_collectedItems)
    {
        _collectedItems = [NSMutableArray array];
    }

    return _collectedItems;
}

#pragma mark - Life Cycle

- (void) viewDidLoad
{
    [super viewDidLoad];
}

- (void) viewDidAppear:(BOOL) animated
{
    [super viewDidAppear:animated];

    self.beaconContent = [self.beaconService beaconData];
    [self.beaconService startMonitoring];
    [self.tableView reloadData];
}

- (void) viewDidDisappear:(BOOL) animated
{
    [super viewDidDisappear:animated];

    [self.beaconService stopMonitoring];
}

#pragma mark - Beacon Service Delegate

- (void) beaconContentDidUpdate:(NSArray *) beaconContent
{
    self.beaconContent = beaconContent;

    [self.tableView reloadData];
    for (MWMSRocketShipPart *part in self.beaconContent)
    {
        if (part.proximity == CLProximityImmediate && ![self.collectedItems containsObject:part] && ![self isDisplayingAlert])
        {
            NSString *messageString = [NSString stringWithFormat:@"You're real close to the %@, did you find it?!", part.name];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Item Found?" message:messageString delegate:self cancelButtonTitle:@"Nope" otherButtonTitles:@"Yeah!", nil];
            [alert show];
            self.displayingAlert = YES;
            self.itemToCollect = part;
            break;
        }
    }
}

- (void) beaconServiceDidFailWithError:(NSError *) error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"An unexpected error has occured. :(" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alert show];
}

- (void) didEnterRegion
{
    // typical reaction to finding a new region - just display a local notification.
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = @"You're in range of some items!";

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

- (void) didExitRegion
{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.fireDate = [NSDate date];
    notification.alertBody = @"Make sure you don't forget your repair kit!";

    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

#pragma mark - Table View Data Source

- (NSInteger) numberOfSectionsInTableView:(UITableView *) tableView
{
    return [self.collectedItems count] ? 2 : 1;
}

- (NSInteger) tableView:(UITableView *) tableView numberOfRowsInSection:(NSInteger) section
{
    if (section == 0)
    {
        return [self.beaconContent count] - [self.collectedItems count];
    }
    else
    {
        return [self.collectedItems count];
    }
}

- (UITableViewCell *) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *) indexPath
{
    static NSString *identifier = @"kPromotionsCell";
    MWMSPartCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    MWMSRocketShipPart *part;

    if (indexPath.section == 0)
    {
        NSMutableArray *filteredContents = [NSMutableArray arrayWithArray:self.beaconContent];
        [filteredContents removeObjectsInArray:self.collectedItems];

        part = filteredContents[indexPath.row];
        cell.collectedImageView.image = [[UIImage imageNamed:@"circle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    else
    {
        part = self.collectedItems[indexPath.row];
        cell.collectedImageView.image = [[UIImage imageNamed:@"checkandcircle"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }

    cell.proximityLabel.text = [part proximityString];
    cell.descriptionLabel.text = part.details;
    cell.nameLabel.text = part.name;

    return cell;
}

- (CGFloat) tableView:(UITableView *) tableView heightForHeaderInSection:(NSInteger) section
{
    return 22;
}

- (CGFloat) tableView:(UITableView *) tableView heightForFooterInSection:(NSInteger) section
{
    return 0.1;
}

- (UIView *) tableView:(UITableView *) tableView viewForHeaderInSection:(NSInteger) section
{
    CGRect headerFrame = CGRectMake(0, 0, tableView.frame.size.width, 22);

    UIView *view = [[UIView alloc] initWithFrame:headerFrame];
    //
    view.backgroundColor = [UIColor colorWithRed:122.0 / 255.0 green:13.0 / 255.0 blue:21.0 / 255.0 alpha:1];

    UILabel *label = [[UILabel alloc] initWithFrame:headerFrame];
    label.font = [UIFont boldSystemFontOfSize:15];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];

    if (section == 0)
    {
        label.text = @"Remaining Items";
    }
    else
    {
        label.text = @"Collected Items";
    }

    [view addSubview:label];

    return view;
}

- (UIView *) tableView:(UITableView *) tableView viewForFooterInSection:(NSInteger) section
{
    return [[UIView alloc] initWithFrame:CGRectZero];
}

#pragma mark - Table View Delegate

- (void) tableView:(UITableView *) tableView didSelectRowAtIndexPath:(NSIndexPath *) indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Alert View Delegate

- (void) alertView:(UIAlertView *) alertView didDismissWithButtonIndex:(NSInteger) buttonIndex
{
    self.displayingAlert = NO;

    if (buttonIndex == alertView.cancelButtonIndex)
    {
        self.itemToCollect = nil;
    }
    else
    {
        if (self.itemToCollect)
        {
            [self.collectedItems addObject:self.itemToCollect];
            [self.tableView reloadData];
        }
    }
}

@end
