//
//  LJSettingViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 21/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJSettingViewController.h"
#import "journalStore.h"
#import "fontStore.h"
#import "LJFontSettingViewController.h"
#import "LJPasswordSettingViewController.h"

@interface LJSettingViewController ()

@property (nonatomic, strong)UITableViewCell *cell;
@property (nonatomic)NSInteger number;
@property (nonatomic, strong)NSString *font;
@property (nonatomic)NSInteger fontSize;
@property (nonatomic)BOOL iCloudEnabled;

@end

@implementation LJSettingViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Setting", nil);
    [self.tableView registerClass:[_cell class] forCellReuseIdentifier:@"cell"];
    self.iCloudEnabled = [[journalStore sharedStore] iCloudWasOn];
}

- (void)viewWillAppear:(BOOL)animated
{
    _number = [[[journalStore sharedStore] allJournals] count];
    _font = [[fontStore sharedStore] getFontName];
    _fontSize = (int)[[fontStore sharedStore] getFontSize];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section ? 1 : 3;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    NSString *stringForiCloudEnabled = NSLocalizedString(@"If automatic synchronization failed, you can synchronize manually", nil);
    NSString *stringForiCloudDisabled = NSLocalizedString(@"Enable iCloud Drive for synchronization on iCloud", nil);
    NSString *string;
    if (self.iCloudEnabled) {
        string = stringForiCloudEnabled;
    } else {
        string = stringForiCloudDisabled;
    }
    
    return section ? string : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    _cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    
    switch (indexPath.section) {
        case 0:
            switch (indexPath.row) {
                case 0:
                    self.cell.textLabel.text = NSLocalizedString(@"Journals", nil);
                    self.cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld",(long)_number];
                    self.cell.userInteractionEnabled = NO;
                    break;
                    
                case 1:
                    self.cell.textLabel.text = NSLocalizedString(@"Font & Font Size", nil);
                    self.cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ + %ld",_font,(long)_fontSize];
                    self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                case 2:
                    self.cell.textLabel.text = NSLocalizedString(@"Password", nil);
                    self.cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    break;
                    
                    
                default:
                    break;
            }
            break;
            
        case 1:
            switch (indexPath.row) {
                case 0:
                    self.cell.textLabel.text = NSLocalizedString(@"Synchronize", nil);
                    self.cell.accessoryType = UITableViewCellAccessoryNone;
                    self.cell.textLabel.textAlignment = NSTextAlignmentCenter;
                    if (!self.iCloudEnabled) {
                        self.cell.userInteractionEnabled = NO;
                        self.cell.textLabel.textColor = [UIColor grayColor];
                    } else {
                        self.cell.textLabel.textColor = [UIColor redColor];
                    }
                    break;
                    
                default:
                    break;
            }
            
        default:
            break;
    }
    
    return _cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 1) {
            LJFontSettingViewController *fontVC = [[LJFontSettingViewController alloc] init];
            [self.navigationController pushViewController:fontVC animated:YES];
        } else if (indexPath.row == 2) {
            LJPasswordSettingViewController *passwordVC = [[LJPasswordSettingViewController alloc] init];
            [self.navigationController pushViewController:passwordVC animated:YES];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Do you want to synchronize?", nil) message:@"This action will make journals on iCloud and local stay the same" preferredStyle:UIAlertControllerStyleAlert];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Yes", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [[journalStore sharedStore] syncJournalsBetweenLocalAndiCloud];
            }]];
            
            [alertController addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"No", nil) style:UIAlertActionStyleCancel handler:NULL]];
            
            [self presentViewController:alertController animated:YES completion:NULL];
        }
    }
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.isSelected) {
            cell.selected = NO;
        }
    }
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
