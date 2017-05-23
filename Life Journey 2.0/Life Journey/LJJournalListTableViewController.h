//
//  LJJournalListTableViewController.h
//  Life Journey
//
//  Created by Michael_Xiong on 5/30/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HudDismissDelegate <NSObject>

- (void)HudDismiss;

@end

@interface LJJournalListTableViewController : UITableViewController

@property (weak) id <HudDismissDelegate> delegate;

@end
