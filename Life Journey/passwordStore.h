//
//  passwordStore.h
//  Life Journey
//
//  Created by Michael_Xiong on 21/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface passwordStore : NSObject

@property (nonatomic)BOOL hasPassword;
@property (nonatomic)BOOL authenticationPassed;  //一旦程序退出或者进入后台，改变bool状态已重新开启touchid验证

+ (instancetype)sharedStore;
- (NSString *)getPassword;
- (void)setThePassword:(NSString *)password;
- (BOOL)verify:(NSString *)password;
- (BOOL)saveChanges;
- (void)setTouchIDEnabled:(BOOL)enable;
- (BOOL)touchIDEnabled;

@end
