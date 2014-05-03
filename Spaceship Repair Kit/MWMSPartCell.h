//
//  MWMSPartCell.h
//  Beacon Promotions
//
//  Created by Brandon Kobilansky on 5/4/14.
//  Copyright (c) 2014 Myriad Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MWMSPartCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;
@property (nonatomic, weak) IBOutlet UILabel *descriptionLabel;
@property (nonatomic, weak) IBOutlet UILabel *proximityLabel;
@property (nonatomic, weak) IBOutlet UIImageView *collectedImageView;

@end
