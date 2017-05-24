//
//  BNRTabBar.m
//  HomePwner
//
//  Created by Michael_Xiong on 5/23/16.
//  Copyright © 2016 Big Nerd Ranch. All rights reserved.
//

#import "LJTabBar.h"

#define plusButtonImage                     [UIImage imageNamed:@"Plus_tab"]
#define plusButtonImageForHighLighted       [UIImage imageNamed:@"Plus_tab_highlighted"]

@implementation LJTabBar

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        UIButton *plusButton = [[UIButton alloc] init];
        [plusButton setBackgroundImage:plusButtonImage forState:UIControlStateNormal];
        [plusButton setBackgroundImage:plusButtonImageForHighLighted forState:UIControlStateHighlighted];
        CGRect temp = plusButton.frame;
        temp.size = plusButton.currentBackgroundImage.size;
        plusButton.frame = temp;
        [plusButton addTarget:self action:@selector(plusClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:plusButton];
        self.plusButton = plusButton;
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //加号按钮的位置
    CGPoint temp = self.plusButton.center;
    temp.x = self.frame.size.width / 2;
    temp.y = self.frame.size.height / 2;
    self.plusButton.center = temp;
    
    //设置tabbarbutton
    CGFloat tabBarButtonWidth = self.frame.size.width / 3;
    CGFloat tabBarButtonIndex = 0;
    
    for (UIView *childView in self.subviews) {
        if ([childView isKindOfClass:NSClassFromString(@"UITabBarButton")]) {
            CGRect frame = childView.frame;
            frame.size.width = tabBarButtonWidth;
            frame.origin.x = tabBarButtonIndex * tabBarButtonWidth;
            childView.frame = frame;
            
            tabBarButtonIndex++;
            if (tabBarButtonIndex == 1) {
                tabBarButtonIndex++;
            }
        }
    }
}

- (void)plusClick
{
    if ([self.tabBarDelegate respondsToSelector:@selector(tabBarDidClickPlusButton:)]) {
        [self.tabBarDelegate tabBarDidClickPlusButton:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
