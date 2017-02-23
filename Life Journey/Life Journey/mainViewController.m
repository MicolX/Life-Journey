//
//  mainViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 5/24/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "mainViewController.h"
#import "LJTabBar.h"
#import "LJEditViewController.h"
#import "LJJournalListTableViewController.h"
#import "LJCalendarViewController.h"
#import "journalStore.h"
#import "LJTextViewController.h"
#import "passwordStore.h"
#import "LJPasswordViewController.h"

#define listTabImage                        [UIImage imageNamed:@"List_tab"]
#define listTabImageForHighLighted          [UIImage imageNamed:@"List_tab_highlighted"]
#define calendarTabImage                    [UIImage imageNamed:@"Calendar_tab"]
#define calendarTabImageForHighLighted      [UIImage imageNamed:@"Calendar_tab_highlighted"]

@interface mainViewController () <LJTabBarDelegate>

@property (nonatomic, strong)LJJournalListTableViewController *tableView;
@property (nonatomic)BOOL passwordIsNeeded;

@end

@implementation mainViewController

- (instancetype)init
{
    if (self = [super init]) {
        _passwordIsNeeded = YES;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LJTabBar *tabBar = [[LJTabBar alloc] init];
    tabBar.tabBarDelegate = self;
    
    
    [self setValue:tabBar forKeyPath:@"tabBar"];
    
    self.tableView = [[LJJournalListTableViewController alloc] init];
    
    [self addVC:self.tableView
          title:nil
      withImage:listTabImage
withSelectedImage:listTabImageForHighLighted];
    
    
    [self addVC:[[LJCalendarViewController alloc] init]
          title:nil
      withImage:calendarTabImage
withSelectedImage:calendarTabImageForHighLighted];
    
    
}

- (void)tabBarDidClickPlusButton:(LJTabBar *)tabBar
{
    journal *newJournal = [[journalStore sharedStore] addJournal];
    
    NSArray<journal *> *journals = [[journalStore sharedStore] allJournals];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    //由于设计一天限定只写一篇日记，如果已经有日记了就跳转进日记视图，否则再新建
    if (journals.count > 1 && [[formatter stringFromDate:journals[1].date] isEqualToString:[formatter stringFromDate:newJournal.date]]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You have already written a journal today, would you like to have a look?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yep", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            LJTextViewController *textVC = [[LJTextViewController alloc] init];
            textVC.journal = journals[1];
            textVC.isPopUpFromCalendar = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:textVC];
            [self presentViewController:nav animated:YES completion:NULL];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Nope", nil) style:UIAlertActionStyleCancel handler:NULL]];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
        [[journalStore sharedStore] removeJournal:newJournal];
    } else {
        
        LJEditViewController *editVC = [[LJEditViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:editVC];
        nav.navigationBar.translucent = NO;
        
        editVC.journal = newJournal;
        editVC.isNew = YES;
        
        [self presentViewController:nav animated:YES completion:NULL];
    }
    
    
//    __weak LJJournalListTableViewController* weakTableView = self.tableView;
//    editVC.dismissBlock = ^{
//        NSLog(@"table data reload!");
//        [weakTableView.tableView reloadData];
//    };
    
}

- (void)addVC:(UIViewController *)childVC title:(NSString *)title withImage:(UIImage *)image withSelectedImage:(UIImage *)selectedImage
{
    UIEdgeInsets inset = UIEdgeInsetsMake(6, 0, -6, 0);
    
    childVC.title = title;
    childVC.tabBarItem.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVC.tabBarItem.imageInsets = inset;
    childVC.tabBarItem.selectedImage = [selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:childVC];      
    [self addChildViewController:nav];
}


- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.passwordIsNeeded) {
        
        if ([[passwordStore sharedStore] hasPassword] && ![[passwordStore sharedStore] authenticationPassed]) {
            
            LJPasswordViewController *passwordVC = [[LJPasswordViewController alloc] initWithSwitchOn:YES changeMode:NO forInitial:YES];
            [self presentViewController:passwordVC animated:YES completion:NULL];
        }
        
        self.passwordIsNeeded = NO;
    }
    
}




/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
