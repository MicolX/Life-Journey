//
//  font.m
//  Life Journey
//
//  Created by Michael_Xiong on 28/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "font.h"

@implementation font

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.fontName forKey:@"fontName"];
    [aCoder encodeDouble:self.fontSize forKey:@"size"];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super init]) {
        _fontName = [aDecoder decodeObjectForKey:@"fontName"];
        _fontSize = [aDecoder decodeDoubleForKey:@"size"];
    }
    return self;
}

@end
