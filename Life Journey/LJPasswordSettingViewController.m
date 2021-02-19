//
//  LJPasswordSettingViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 21/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJPasswordSettingViewController.h"
#import "passwordStore.h"
#import "LJPasswordViewController.h"

@interface LJPasswordSettingViewController ()

@property (nonatomic, strong)UISwitch *switchEnable;
@property (nonatomic, strong)UISwitch *switchTouchID;


@end

@implementation LJPasswordSettingViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = NSLocalizedString(@"Password", nil);
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"passwordcell"];
    self.tableView.separatorStyle = NO;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}




#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return section == 1 ? 2:1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"passwordcell"];
    
    if (indexPath.section == 0) {
        
        _switchEnable = [[UISwitch alloc] init];
        _switchEnable.on = [[passwordStore sharedStore] hasPassword];
        [self.switchEnable addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];

        cell.textLabel.text = NSLocalizedString(@"Enable", nil);
        cell.accessoryView = self.switchEnable;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    } else if (indexPath.section == 1) {
        
        switch (indexPath.row) {
            case 0:
                
                cell.textLabel.text = NSLocalizedString(@"Change Password", nil);
                cell.textLabel.textColor = [UIColor redColor];
                
                if (!self.switchEnable.on) {
                    cell.hidden = YES;
                }
                
                break;
                
            case 1:
                
                _switchTouchID = [[UISwitch alloc] init];
                _switchTouchID.on = [[passwordStore sharedStore] touchIDEnabled];
                [self.switchTouchID addTarget:self action:@selector(switchTouchIDAction:) forControlEvents:UIControlEventValueChanged];
                
                cell.textLabel.text = NSLocalizedString(@"Touch ID", nil);
                cell.accessoryView = _switchTouchID;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                
                if (!self.switchEnable.on) {
                    cell.hidden = YES;
                }
        }
    }
    
    return cell;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1 && indexPath.row == 0) {
        LJPasswordViewController *passwordVC = [[LJPasswordViewController alloc] initWithSwitchOn:YES changeMode:YES forInitial:NO];
        [self presentViewController:passwordVC animated:YES completion:NULL];
    }
}

- (void)switchAction:(id)sender
{
    UISwitch *switcha = (UISwitch *)sender;
    LJPasswordViewController *passwordVC = [[LJPasswordViewController alloc] initWithSwitchOn:switcha.on changeMode:NO forInitial:NO];
    [self presentViewController:passwordVC animated:YES completion:NULL];
    
}

- (void)switchTouchIDAction:(id)sender
{
    UISwitch *switchTouchID = (UISwitch *)sender;
    if (switchTouchID.on) {
        LAContext *context = [[LAContext alloc] init];
        NSError *error = nil;
        
        //if touchID is not supported
        if (![context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                           message:NSLocalizedString(@"touchID is not supported", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            
            [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                      style:UIAlertActionStyleCancel
                                                    handler:^(UIAlertAction *action){
                                                        [self dismissViewControllerAnimated:YES completion:NULL];
                                                    }]];
            [self presentViewController:alert animated:YES completion:NULL];
            self.switchTouchID.on = NO;
        } else {
            [[passwordStore sharedStore] setTouchIDEnabled:YES];
        }
    } else {
        [[passwordStore sharedStore] setTouchIDEnabled:NO];
    }
}


@end
