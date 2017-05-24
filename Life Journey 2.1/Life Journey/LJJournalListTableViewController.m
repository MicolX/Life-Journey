//
//  LJJournalListTableViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 5/30/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//


#import "LJJournalListTableViewController.h"
#import "LJTableViewCell.h"
#import "journalStore.h"
#import "journal+CoreDataProperties.h"
#import "LJTextViewController.h"
#import "journal.h"
#import "LJSettingViewController.h"

#define FONTNAME    @"LJFontName"
#define FONTSIZE    @"LJFontSize"

@interface LJJournalListTableViewController () <JournalStoreDelegate, NSFetchedResultsControllerDelegate, UIViewControllerPreviewingDelegate>

@property (nonatomic, strong)NSCache *cache;

@property (nonatomic, strong)NSFetchedResultsController *fetchedResultsController;

@end


@implementation LJJournalListTableViewController

- (instancetype)init
{
    if ([super initWithStyle:UITableViewStylePlain]) {
        self.editButtonItem.title = nil;
        self.editButtonItem.image = [[UIImage imageNamed:@"edit_button"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[[UIImage imageNamed:@"wrench"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                                                                                  style:UIBarButtonItemStylePlain
                                                                                 target:self
                                                                                 action:@selector(setting)];
        
        
    }
    return self;
}


- (void)initializeFetchedResultsController
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"Journal"];
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    [fetchRequest setSortDescriptors:@[dateSort]];
    self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
                                                                        managedObjectContext:[[journalStore sharedStore] context]sectionNameKeyPath:@"section"
                                                                                   cacheName:nil];
    
    [self.fetchedResultsController setDelegate:self];
    
    NSError *fetchError;
    if (![self.fetchedResultsController performFetch:&fetchError]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [fetchError localizedDescription], [fetchError userInfo]);
        abort();
    }

}

- (void)setupRefresh
{
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(verifyShallBegin:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Drag down to synchronize", nil)];
    [self.tableView addSubview:self.refreshControl];
}

- (void)verifyShallBegin:(UIRefreshControl *)control
{
    [[journalStore sharedStore] syncJournalsBetweenLocalAndiCloud];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"LJTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LJTableViewCell"];
    
    UILabel *titleView = [[UILabel alloc] initWithFrame:CGRectMake(0,
                                                                   0,
                                                                   self.view.bounds.size.width / 2,
                                                                   self.navigationController.navigationBar.frame.size.height)];
    titleView.textColor = [UIColor whiteColor];
    titleView.text = @"Life Journey";
    titleView.font = [UIFont fontWithName:@"MarkerFelt-Thin" size:22];
    titleView.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleView;
    

    [self initializeFetchedResultsController];
    [journalStore sharedStore].delegate = self;
    [self setFetchedResultsController:self.fetchedResultsController];
    
    [self setupRefresh];
}

- (void)viewWillAppear:(BOOL)animated
{
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.isSelected) {
            cell.selected = NO;
        }
    }
    [self.tableView reloadData];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    NSLog(@"clear cache");
    [self.cache removeAllObjects];
}
    
- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    self.editButtonItem.title = nil;
}
    
    
- (void)setting
{
    LJSettingViewController *settingVC = [[LJSettingViewController alloc] init];
    [self.navigationController pushViewController:settingVC animated:YES];
}
    
    
#pragma mark - NSFetchedResultsControllerDelegate
    
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}
    
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}
    
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id<NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
        [[self tableView] deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        
        case NSFetchedResultsChangeInsert:
        [[self tableView] insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        case NSFetchedResultsChangeUpdate:
        
        break;
        
        default:
        break;
    }
}
    
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeDelete:
        [[self tableView] deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        
        case NSFetchedResultsChangeInsert:
        [[self tableView] insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        case NSFetchedResultsChangeUpdate:
        [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        break;
        
        default:
        break;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}	


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return [self.fetchedResultsController sections][section].name;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJTableViewCell" forIndexPath:indexPath];
    
    //获取日记
    journal *journal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.text.text = journal.journal;
    cell.text.font = [UIFont fontWithName:[[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME] size:19];
    cell.photo.image = journal.thumbnail;
    cell.location.text = journal.location;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger components = NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:components fromDate:journal.date];
    NSInteger day = dateComponents.day;
    cell.date.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    if (self.traitCollection.forceTouchCapability == UIForceTouchCapabilityAvailable) {
        [self registerForPreviewingWithDelegate:self sourceView:cell];
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJTextViewController *textVC = [[LJTextViewController alloc] init];
    
    journal *journal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    textVC.journal = journal;
    textVC.isPopUpFromCalendar = NO;
    
 
    textVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:textVC animated:YES];

}




- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        journal *journal = [self.fetchedResultsController objectAtIndexPath:indexPath];

        [[journalStore sharedStore] removeJournal:journal];
        
        if ([[journalStore sharedStore] iCloudWasOn]) {
            
            [[journalStore sharedStore] deleteJournalFromCloud:journal];
        }
       
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}

- (void)setExtraLineHidden:(UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor colorWithRed:74.0 / 255 green:144.0 /255 blue:226.0 / 255 alpha:1];
}

#pragma mark - UIViewControllerPreviewingDelegate
    
- (void)previewingContext:(id<UIViewControllerPreviewing>)previewingContext commitViewController:(UIViewController *)viewControllerToCommit
{
    [self showViewController:viewControllerToCommit sender:self];
}


- (UIViewController *)previewingContext:(id<UIViewControllerPreviewing>)previewingContext viewControllerForLocation:(CGPoint)location
{
    //get the indexpath
    NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)[previewingContext sourceView]];
    LJTextViewController *textVC = [[LJTextViewController alloc] init];
    textVC.preferredContentSize = CGSizeMake(0.0f, self.view.bounds.size.height * 4 / 5);
    textVC.journal = [self.fetchedResultsController objectAtIndexPath:indexPath];
    
    return textVC;
}

#pragma mark - JournalStore Delegate

- (void)dataDidFetched
{
    NSLog(@"journal store delegate method called, reload data");
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.tableView reloadData];
        [self.refreshControl endRefreshing];
    });
    
    [self.delegate HudDismiss];
    
}




@end
