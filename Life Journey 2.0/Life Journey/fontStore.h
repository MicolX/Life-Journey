//
//  fontStore.h
//  Life Journey
//
//  Created by Michael_Xiong on 16/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface fontStore : NSObject


+ (instancetype)sharedStore;
- (NSString *)getFontName;
- (CGFloat)getFontSize;
- (void)setFontName:(NSString *)name fontSize:(CGFloat)size;
- (BOOL)saveFonts;

@end
