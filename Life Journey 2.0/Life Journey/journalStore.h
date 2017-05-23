//
//  journalStore.h
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CloudKit/CloudKit.h>

@class journal;

@protocol JournalStoreDelegate <NSObject>

- (void)dataDidFetched;

@end

@interface journalStore : NSObject

@property (nonatomic, strong)NSMutableArray<journal *> *allJournals;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic)BOOL iCloudWasOn;   //用来判断上次启动时iCloud是否开启

@property (weak) id <JournalStoreDelegate> delegate;

+ (instancetype)sharedStore;

- (journal *)addJournal;

- (void)removeJournal:(journal *)journal;

- (BOOL)saveChanges;

- (NSString *)getYearAndMonth:(journal *)j;

- (void)uploadJournalToCloud:(journal *)journal;

- (void)modifyJournalOnCloud:(journal *)journal journalIsChanged:(BOOL)journalIsChanged photoIsChanged:(BOOL)photoIsChanged;

- (void)deleteJournalFromCloud:(journal *)journal;

- (void)syncJournalsBetweenLocalAndiCloud;

@end
