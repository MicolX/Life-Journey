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


@interface LJJournalListTableViewController ()

@property (nonatomic, strong)NSCache *cache;

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

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:@"LJTableViewCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:@"LJTableViewCell"];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    return [[[journalStore sharedStore] allKeysInDict] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSMutableArray *keys = [[journalStore sharedStore] allKeysInDict];
    NSDictionary *dict = [[journalStore sharedStore] allJournalsInDict];
    return [dict[keys[section]] count];
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{

    return [[journalStore sharedStore] allKeysInDict][section];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LJTableViewCell" forIndexPath:indexPath];
    
    //获取日记
    NSDictionary *journalsInDict = [[journalStore sharedStore] allJournalsInDict];
    NSMutableArray *allKeys = [[journalStore sharedStore] allKeysInDict];
    NSArray *journalsInArray = [journalsInDict objectForKey:allKeys[indexPath.section]];
    journal *journal = journalsInArray[indexPath.row];
    
    
    //显示日记
    cell.text.text = journal.journal;
    
    //显示图片
    cell.photo.image = journal.thumbnail;
    
    //显示位置
    cell.location.text = journal.location;
    
    //显示日期
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger components = NSCalendarUnitDay;
    NSDateComponents *dateComponents = [calendar components:components fromDate:journal.date];
    NSInteger day = dateComponents.day;
    cell.date.text = [NSString stringWithFormat:@"%ld",(long)day];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    LJTextViewController *textVC = [[LJTextViewController alloc] init];
    
    NSMutableArray *keys = [[journalStore sharedStore] allKeysInDict];
    NSDictionary *dict = [[journalStore sharedStore] allJournalsInDict];
    NSMutableArray *journals = dict[keys[indexPath.section]];
    journal *journal = journals[indexPath.row];
    
    textVC.journal = journal;
    textVC.isPopUpFromCalendar = NO;
    
 
    textVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:textVC animated:YES];

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



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSMutableArray *keys = [[journalStore sharedStore] allKeysInDict];
        NSDictionary *dict = [[journalStore sharedStore] allJournalsInDict];
        NSMutableArray *journals = dict[keys[indexPath.section]];
        journal *journal = journals[indexPath.row];

        [[journalStore sharedStore] removeJournal:journal];
        
        //开始删除
        [tableView beginUpdates];    //用 beginupdates 和 endupdates 将删除cell和删除section的动作包起来后就不会crush了!
        
        //删除cell
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        //如果删除的是section里的最后一个cell，则要删除section，否则会crush
        if ([[dict objectForKey:[[journalStore sharedStore] getYearAndMonth:journal]] count] == 0) {
            NSLog(@"这是section里的最后一个，删除掉");
            [tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        //删除结束
        [tableView endUpdates];
       
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section
{
    UITableViewHeaderFooterView *headerView = (UITableViewHeaderFooterView *)view;
    headerView.textLabel.textColor = [UIColor colorWithRed:74.0 / 255 green:144.0 /255 blue:226.0 / 255 alpha:1];
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
