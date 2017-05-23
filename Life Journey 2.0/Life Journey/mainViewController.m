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
#import "MBProgressHUD.h"

#define listTabImage                        [UIImage imageNamed:@"List_tab"]
#define listTabImageForHighLighted          [UIImage imageNamed:@"List_tab_highlighted"]
#define calendarTabImage                    [UIImage imageNamed:@"Calendar_tab"]
#define calendarTabImageForHighLighted      [UIImage imageNamed:@"Calendar_tab_highlighted"]

@interface mainViewController () <LJTabBarDelegate, HudDismissDelegate>

@property (nonatomic, strong)LJJournalListTableViewController *tableVC;
@property (nonatomic)BOOL passwordIsNeeded;

@property (nonatomic, strong)MBProgressHUD *hud;



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
    
    self.tableVC = [[LJJournalListTableViewController alloc] init];
    self.tableVC.delegate = self;
    
    [self addVC:self.tableVC
          title:nil
      withImage:listTabImage
withSelectedImage:listTabImageForHighLighted];
    
    
    [self addVC:[[LJCalendarViewController alloc] init]
          title:nil
      withImage:calendarTabImage
withSelectedImage:calendarTabImageForHighLighted];
    
    [[UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]] setColor:[UIColor whiteColor]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showHud:) name:@"ShowHudNotify" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudSuggestionAction) name:@"iCloudSuggestion" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(postErrorMessage:) name:@"ErrorMessage" object:nil];

}



- (void)tabBarDidClickPlusButton:(LJTabBar *)tabBar
{
    NSArray<journal *> *journals = [[journalStore sharedStore] allJournals];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"yyyy-MM-dd";
    
    //由于设计一天限定只写一篇日记，如果已经有日记了就跳转进日记视图，否则再新建
    if (journals.count && [[formatter stringFromDate:journals[0].date] isEqualToString:[formatter stringFromDate:[NSDate date]]]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"You have already written a journal today, would you like to have a look?", nil) preferredStyle:UIAlertControllerStyleAlert];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yep", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            LJTextViewController *textVC = [[LJTextViewController alloc] init];
            textVC.journal = journals[0];
            textVC.isPopUpFromCalendar = YES;
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:textVC];
            [self presentViewController:nav animated:YES completion:NULL];
        }]];
        
        [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Nope", nil) style:UIAlertActionStyleCancel handler:NULL]];
        
        [self presentViewController:alertController animated:YES completion:NULL];
        
    } else {
        
        journal *newJournal = [[journalStore sharedStore] addJournal];
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


- (void)iCloudSuggestionAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sign in to iCloud", nil)
                                                                   message:NSLocalizedString(@"Sign in to your iCloud to backup your journals on the iCloud", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                              style:UIAlertActionStyleCancel
                                            handler:nil]];
    
        [self presentViewController:alert animated:YES completion:NULL];
}


- (void)showHud:(NSNotification *)notification
{
    NSString *string = [notification object];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [[UIActivityIndicatorView appearanceWhenContainedInInstancesOfClasses:@[[MBProgressHUD class]]] setColor:[UIColor whiteColor]];
        self.hud.label.text = string;
        self.hud.bezelView.color = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
        self.hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        self.hud.label.textColor = [UIColor whiteColor];
    });
}


- (void)HudDismiss
{
    NSLog(@"delegate method called, HudDismiss, %@", [NSThread currentThread]);

    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.hud.mode = MBProgressHUDModeText;
        self.hud.label.text = NSLocalizedString(@"Mission Complete", nil);
        self.hud.label.textColor = [UIColor whiteColor];
        [self.hud hideAnimated:YES afterDelay:1.8];
    });
    
}

- (void)postErrorMessage:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.hud hideAnimated:YES];
    });
    
    NSString *errorMessage = [notification object];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", nil) message:errorMessage preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:NULL]];
    [self presentViewController:alertController animated:YES completion:NULL];
}


@end
