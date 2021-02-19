//
//  LJTextViewController.h
//  Life Journey
//
//  Created by Michael_Xiong on 5/25/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "journal.h"

@interface LJTextViewController : UIViewController

@property (nonatomic, strong)journal *journal;

@property (nonatomic)BOOL isPopUpFromCalendar;



@end
