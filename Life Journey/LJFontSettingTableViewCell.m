//
//  LJSettingTableViewCell.m
//  Life Journey
//
//  Created by Michael_Xiong on 15/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJFontSettingTableViewCell.h"

@implementation LJFontSettingTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (instancetype)init
{
    if (self = [super init]) {
        self = [[LJFontSettingTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"talbeViewCell"];
        self.selected = NO;
    }
    return self;
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//    if (selected) {
//        self.accessoryType = UITableViewCellAccessoryCheckmark;
//    }
//}

@end
