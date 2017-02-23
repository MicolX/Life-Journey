//
//  journalStore.h
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class journal;

@interface journalStore : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSDictionary *allJournalsInDict;   //字典是由year-month的nsstring为key，对应的是存放这个年月日记的nsmutablearray
@property (nonatomic, strong) NSMutableArray<NSString *> *allKeysInDict;     //字典key的copy，但是排序过的array
@property (nonatomic, strong) NSArray<journal *> *allJournals;

+ (instancetype)sharedStore;

- (journal *)addJournal;

- (void)removeJournal:(journal *)journal;

- (BOOL)saveChanges;

- (NSString *)getYearAndMonth:(journal *)j;



@end
