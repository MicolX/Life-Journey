//
//  LJSettingViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 15/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJFontSettingViewController.h"
#import "LJFontSettingTableViewCell.h"

#define LJFontAmericanTypewriter    [UIFont fontWithName:@"AmericanTypewriter" size:15]
#define LJFontAppleGothic           [UIFont fontWithName:@"AppleGothic" size:15]
#define LJFontArial                 [UIFont fontWithName:@"Arial" size:15]
#define LJFontBradley_Hand          [UIFont fontWithName:@"Bradley Hand" size:15]
#define LJFontCourier               [UIFont fontWithName:@"Courier" size:15]
#define LJFontGeoriga               [UIFont fontWithName:@"Georgia" size:15]
#define LJFontHelvetica             [UIFont fontWithName:@"Helvetica" size:15]
#define LJFontMarkerFelt            [UIFont fontWithName:@"MarkerFelt-Thin" size:15]
#define LJFontTimesNewRoman         [UIFont fontWithName:@"TimesNewRomanPSMT" size:15]
#define LJFontTrebuchetMS           [UIFont fontWithName:@"TrebuchetMS" size:15]
#define LJFontVerdana               [UIFont fontWithName:@"Verdana" size:15]
#define LJFontZapfino               [UIFont fontWithName:@"Zapfino" size:15]

#define LJFontHanYiFangNiJian       [UIFont fontWithName:@"HYFangLiJ" size:15]
#define LJFontPingFang_TC           [UIFont fontWithName:@"PingFang TC" size:15]
#define LJFontDroid_Sans            [UIFont fontWithName:@"Droid Sans" size:15]

#define FONTNAME    @"LJFontName"
#define FONTSIZE    @"LJFontSize"

@interface LJFontSettingViewController ()

@property (nonatomic, strong)NSString *fontName;
@property (nonatomic)double fontSize;

@end

@implementation LJFontSettingViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Font", nil);
    self.fontName = [[NSUserDefaults standardUserDefaults] objectForKey:FONTNAME];
    self.fontSize = [[NSUserDefaults standardUserDefaults] doubleForKey:FONTSIZE];
    
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return section == 0 ? NSLocalizedString(@"Font", nil):NSLocalizedString(@"Font Size", nil);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 0 ? 15:15;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LJFontSettingTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (cell == nil) {
        cell = [[LJFontSettingTableViewCell alloc] init];
    }
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"AmericanTypewriter";
                [cell.textLabel setFont:LJFontAmericanTypewriter];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 1:
                cell.textLabel.text = @"AppleGothic";
                [cell.textLabel setFont:LJFontAppleGothic];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
            
            case 2:
                cell.textLabel.text = @"Arial";
                [cell.textLabel setFont:LJFontArial];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 3:
                cell.textLabel.text = @"Bradley Hand";
                [cell.textLabel setFont:LJFontBradley_Hand];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 4:
                cell.textLabel.text = @"Courier";
                [cell.textLabel setFont:LJFontCourier];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 5:
                cell.textLabel.text = @"Georgia";
                [cell.textLabel setFont:LJFontGeoriga];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
            
            case 6:
                cell.textLabel.text = @"Helvetica";
                [cell.textLabel setFont:LJFontHelvetica];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 7:
                cell.textLabel.text = @"MarkerFelt-Thin";
                [cell.textLabel setFont:LJFontMarkerFelt];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 8:
                cell.textLabel.text = @"TimesNewRomanPSMT";
                [cell.textLabel setFont:LJFontTimesNewRoman];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 9:
                cell.textLabel.text = @"TrebuchetMS";
                [cell.textLabel setFont:LJFontTrebuchetMS];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
            
            case 10:
                cell.textLabel.text = @"Verdana";
                [cell.textLabel setFont:LJFontVerdana];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;

            case 11:
                cell.textLabel.text = @"Zapfino";
                [cell.textLabel setFont:LJFontZapfino];
                cell.fontName = cell.textLabel.text;
                cell.section = 0;
                break;
                
            case 12:
                cell.textLabel.text = @"汉仪方隶简";
                [cell.textLabel setFont:LJFontHanYiFangNiJian];
                cell.fontName = @"HYFangLiJ";
                cell.section = 0;
                break;
                
            case 13:
                cell.textLabel.text = @"苹方 TC";
                [cell.textLabel setFont:LJFontPingFang_TC];
                cell.fontName = @"PingFang TC";
                cell.section = 0;
                break;
                
            case 14:
                cell.textLabel.text = @"熊兔体";
                [cell.textLabel setFont:LJFontDroid_Sans];
                cell.fontName = @"Droid Sans";
                cell.section = 0;
                break;

                
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"11";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 1:
                cell.textLabel.text = @"12";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 2:
                cell.textLabel.text = @"13";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 3:
                cell.textLabel.text = @"15";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 4:
                cell.textLabel.text = @"16";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 5:
                cell.textLabel.text = @"17";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 6:
                cell.textLabel.text = @"18";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 7:
                cell.textLabel.text = @"20";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 8:
                cell.textLabel.text = @"22";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 9:
                cell.textLabel.text = @"24";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 10:
                cell.textLabel.text = @"26";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 11:
                cell.textLabel.text = @"28";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 12:
                cell.textLabel.text = @"30";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 13:
                cell.textLabel.text = @"36";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            case 14:
                cell.textLabel.text = @"42";
                cell.fontSize = [cell.textLabel.text doubleValue];
                cell.section = 1;
                break;
                
            default:
                break;
        }
    }
    
    for (LJFontSettingTableViewCell *acell in [self.tableView visibleCells]) {
        if (acell.fontSize == self.fontSize || [acell.fontName isEqualToString:self.fontName]) {
            acell.accessoryType = UITableViewCellAccessoryCheckmark;
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    for (LJFontSettingTableViewCell *cell in [self.tableView visibleCells]) {
        if (cell.section == indexPath.section) {
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    
    LJFontSettingTableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    if (indexPath.section == 0) {
        self.fontName = cell.fontName;
    } else if (indexPath.section == 1) {
        self.fontSize = cell.fontSize;
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [[NSUserDefaults standardUserDefaults] setObject:self.fontName forKey:FONTNAME];
    [[NSUserDefaults standardUserDefaults] setDouble:self.fontSize forKey:FONTSIZE];
}


@end
