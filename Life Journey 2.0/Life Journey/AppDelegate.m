//
//  AppDelegate.m
//  Life Journey
//
//  Created by Michael_Xiong on 5/18/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "AppDelegate.h"
#import "LJTabBar.h"
#import "mainViewController.h"
#import "journalStore.h"
#import "LJPasswordViewController.h"
#import "passwordStore.h"
#import "fontStore.h"

#define iCLOUDTOKENKEY     @"com.apple.Life_Journey.UbiquityIdentityToken"

@interface AppDelegate ()

@property (nonatomic) BOOL passwordIsNeeded;
@property (nonatomic, strong) mainViewController *mainVC;
@property (nonatomic) BOOL firstLaunchWithiCloudAvailable;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{

    //设置navigationbar颜色
    UINavigationBar *bar = [UINavigationBar appearance];
    bar.barStyle = UIBarStyleDefault;
    [bar setBarTintColor:[UIColor colorWithRed:74.0 / 255 green:144.0 /255 blue:226.0 / 255 alpha:1.0]];
    [bar setTintColor:[UIColor whiteColor]];
    
    
    //设置tabbar颜色
    UITabBar *tab = [UITabBar appearance];
    tab.barStyle = UIBarStyleDefault;
    [tab setBarTintColor:[UIColor colorWithRed:74.0 / 255 green:144.0 /255 blue:226.0 / 255 alpha:0.1]];
    
    
    _mainVC = [[mainViewController alloc] init];
    
    
    self.window.rootViewController = self.mainVC;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    
    [NSThread sleepForTimeInterval:1.0];
    
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    self.passwordIsNeeded = YES;
    [[passwordStore sharedStore] setAuthenticationPassed:NO];
    
    //save journals
    BOOL success = [[journalStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"journals saved");
    } else {
        NSLog(@"journals save failed!");
    }
    
    //save password
    BOOL passwordSaved = [[passwordStore sharedStore] saveChanges];
    if (passwordSaved) {
        NSLog(@"password saved");
    } else {
        NSLog(@"password save failed");
    }
    
    //save font
    BOOL fontSaved = [[fontStore sharedStore] saveFonts];
    if (fontSaved) {
        NSLog(@"font saved!");
    } else {
        NSLog(@"font save failed");
    }

    //save icloud status
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"user defaults synchronize success");
    } else {
        NSLog(@"user defaults synchronize failed");
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    if (self.passwordIsNeeded) {
        if ([[passwordStore sharedStore] hasPassword] && ![[passwordStore sharedStore] authenticationPassed]) {
            LJPasswordViewController *passwordVC = [[LJPasswordViewController alloc] initWithSwitchOn:YES changeMode:NO forInitial:YES];
            [self.mainVC presentViewController:passwordVC animated:YES completion:NULL];
        }
        self.passwordIsNeeded = NO;
    }
    
}



- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    //save journals
    BOOL success = [[journalStore sharedStore] saveChanges];
    if (success) {
        NSLog(@"journals saved");
    } else {
        NSLog(@"journals save failed!");
    }
    
    //save password
    BOOL passwordSaved = [[passwordStore sharedStore] saveChanges];
    if (passwordSaved) {
        NSLog(@"password saved");
    } else {
        NSLog(@"password save failed");
    }
    
    //save font
    BOOL fontSaved = [[fontStore sharedStore] saveFonts];
    if (fontSaved) {
        NSLog(@"font saved!");
    } else {
        NSLog(@"font save failed");
    }
    
    //save icloud status
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
        NSLog(@"user defaults synchronize success");
    } else {
        NSLog(@"user defaults synchronize failed");
    }
}



@end
