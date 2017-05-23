//
//  LJEditViewController.h
//  Life Journey
//
//  Created by Michael_Xiong on 17/10/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "journal.h"


@interface LJEditViewController : UIViewController

//@property (nonatomic, copy) void(^dismissBlock)(void);
@property (nonatomic)BOOL isNew;
@property (nonatomic, strong)journal *journal;
@property (nonatomic, strong)UIImage *photo;


@end
