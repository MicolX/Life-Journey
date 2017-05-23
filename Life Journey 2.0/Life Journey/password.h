//
//  password.h
//  Life Journey
//
//  Created by Michael_Xiong on 28/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface password : NSObject <NSCoding>

@property (nonatomic, strong)NSString *password;
@property (nonatomic)BOOL touchIDEnabled;

@end
