//
//  journal.m
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "journal.h"

@interface journal ()



@end

@implementation journal

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    
    self.date = [NSDate date];
}

- (NSString *)section
{
    [self willAccessValueForKey:@"section"];
    NSString *section = [self getYearAndMonth:self.date];
    [self didAccessValueForKey:@"section"];
    
    return section;
}

- (NSString *)getYearAndMonth:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger components = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponents = [calendar components:components fromDate:date];
    return [NSString stringWithFormat:@"%ld-%ld", (long)dateComponents.year,(long)dateComponents.month];
}

@end
