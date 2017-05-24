//
//  LJPasswordViewController.h
//  Life Journey
//
//  Created by Michael_Xiong on 24/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <LocalAuthentication/LocalAuthentication.h>

@interface LJPasswordViewController : UIViewController


- (instancetype)initWithSwitchOn:(BOOL)switcha changeMode:(BOOL)change forInitial:(BOOL)initial;

@end
