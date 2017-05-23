//
//  BNRTabBar.h
//  HomePwner
//
//  Created by Michael_Xiong on 5/23/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LJTabBar;

@protocol LJTabBarDelegate <UITabBarDelegate>

@optional

- (void)tabBarDidClickPlusButton:(LJTabBar *)tabBar;

@end

@interface LJTabBar : UITabBar

@property (nonatomic, weak) id <LJTabBarDelegate> tabBarDelegate;
@property (nonatomic, strong) UIButton *plusButton;

@end
