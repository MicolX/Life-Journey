//
//  LJSettingViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 21/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJSettingViewController.h"
#import "journalStore.h"
#import "LJFontSettingViewController.h"
#import "LJPasswordSettingViewController.h"

#define FONTNAME    @"LJFontName"
#define FONTSIZE    @"LJFontSize"

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
    if (![[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME]) {
        _font = @"AppleGothic";
        _fontSize = 18;
        [[NSUserDefaults standardUserDefaults] setObject:self.font forKey:FONTNAME];
        [[NSUserDefaults standardUserDefaults] setDouble:self.fontSize forKey:FONTSIZE];
    } else {
        self.font = [[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME];
        self.fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:FONTSIZE];
    }
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
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
    }
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.isSelected) {
            cell.selected = NO;
        }
    }
}



@end
