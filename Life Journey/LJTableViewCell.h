//
//  LJTableViewCell.h
//  Life Journey
//
//  Created by Michael_Xiong on 6/20/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LJTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photo;
@property (weak, nonatomic) IBOutlet UILabel *text;
@property (weak, nonatomic) IBOutlet UILabel *location;
@property (weak, nonatomic) IBOutlet UILabel *date;

@end
