//
//  password.m
//  Life Journey
//
//  Created by Michael_Xiong on 28/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "password.h"

@implementation password

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.password forKey:@"password"];
    [aCoder encodeBool:self.touchIDEnabled forKey:@"touchID"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _password = [aDecoder decodeObjectForKey:@"password"];
        _touchIDEnabled = [aDecoder decodeBoolForKey:@"touchID"];
    }
    return self;
}

@end
