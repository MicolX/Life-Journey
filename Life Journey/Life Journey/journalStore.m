//
//  journalStore.m
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "journalStore.h"
#import "journal.h"

@import CoreData;

@interface journalStore ()

@property (nonatomic, strong)NSManagedObjectModel *model;
@property (nonatomic, strong)NSMutableArray<journal *> *privateJournal;
@property (nonatomic, strong)NSMutableDictionary *journalsInDict;   //字典用于tableview日期分类排序


@end

@implementation journalStore

+ (instancetype)sharedStore
{
    static journalStore *sharedStore;
    
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    
    return sharedStore;
}

- (instancetype)initPrivate
{
    if (self = [super init]) {
        
        _journalsInDict = [[NSMutableDictionary alloc] init];     //之前没有把字典实例化，导致字典一直为空
        
        self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        
        NSString *path = [self journalArchivePath];
        NSURL *url = [NSURL fileURLWithPath:path];
        
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:url options:nil error:&error]) {
            [NSException raise:@"Open Failure" format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.context.persistentStoreCoordinator = psc;
        
        [self loadAllJournals];
        
    }
    return self;
}

- (NSString *)journalArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    return [documentDirectory stringByAppendingPathComponent:@"journal.data"];
    
}

- (void)loadAllJournals
{
    if (!self.privateJournal) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:self.context];
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        if (!result) {
            [NSException raise:@"Fetch failed!" format:@"Reason: %@", [error localizedDescription]];
        }
        self.privateJournal = [[NSMutableArray alloc] initWithArray:result];
        [self bubbleSort_date:self.privateJournal];
        
        //将已有日记加入tableview分类排序字典里
        if (self.privateJournal.count > 0) {
            for (journal *j in self.privateJournal) {
                if (self.journalsInDict.allKeys.count > 0) {
                    NSUInteger key_count = self.journalsInDict.allKeys.count;
                    for (NSString *key in self.journalsInDict.allKeys) {
                        if ([key isEqualToString:[self getYearAndMonth:j]]) {
                            [self.journalsInDict[[self getYearAndMonth:j]] addObject:j];
                            break;
                        } else {
                            key_count--;
                            if (key_count == 0) {
                                NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:j, nil];
                                [self.journalsInDict setObject:arr forKey:[self getYearAndMonth:j]];
                            } else {
                                continue;
                            }
                        }
                    }
                } else {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:j, nil] ;
                    [self.journalsInDict setObject:arr forKey:[self getYearAndMonth:j]];
                }
            }
            for (NSString *key in self.journalsInDict) {
                [self bubbleSort_date:self.journalsInDict[key]];
            }
        }
    }
}



- (journal *)addJournal
{
    journal *journal = [NSEntityDescription insertNewObjectForEntityForName:@"Journal" inManagedObjectContext:self.context];
    [self.privateJournal insertObject:journal atIndex:0];
    
    
    //将新日记加入日期分类排序字典
    NSString *string = [self getYearAndMonth:journal];
    if ([self.journalsInDict objectForKey:string]) {
        
        if ([self.journalsInDict[string] isKindOfClass:[NSArray class]]) {
            //插入在数组的前面
            [self.journalsInDict[string] insertObject:journal atIndex:0];
        }
    } else {
       
        NSMutableArray *arr = [[NSMutableArray alloc] initWithObjects:journal, nil];
        [self.journalsInDict setObject:arr forKey:string];
    }
    
    
    return journal;
}

- (void)removeJournal:(journal *)journal
{
    
    [self.privateJournal removeObjectIdenticalTo:journal];

    [[self.journalsInDict objectForKey:[self getYearAndMonth:journal]] removeObject:journal];
    
    if ([[self.journalsInDict objectForKey:[self getYearAndMonth:journal]] count] == 0) {
        [self.journalsInDict removeObjectForKey:[self getYearAndMonth:journal]];
    }
    
    [self.context deleteObject:journal];
}

- (BOOL)saveChanges
{
    NSError *error;
    BOOL successful = [self.context save:&error];
    if (!successful) {
        NSLog(@"error saving: %@", [error localizedDescription]);
    }
    return successful;
}

- (NSDictionary *)allJournalsInDict
{
    return [self.journalsInDict copy];
}

- (NSMutableArray *)allKeysInDict
{
    NSMutableArray *keys = [self.journalsInDict.allKeys mutableCopy];
    [self bubbleSort_key:keys];
    return keys;
}

- (NSArray *)allJournals
{
    return [self.privateJournal copy];
}

- (NSString *)getYearAndMonth:(journal *)j
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger components = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponents = [calendar components:components fromDate:j.date];
    return [NSString stringWithFormat:@"%ld-%ld", (long)dateComponents.year,(long)dateComponents.month];
}

- (void)bubbleSort_date:(NSMutableArray<journal *> *)array
{
    if (array.count > 1) {
        for (int i = 0; i < array.count; i++) {
            for (int j = 0; j < array.count - i; j++) {
                if (j + 1 < array.count) {
                    if ([self dateIntoNumber:array[j]] < [self dateIntoNumber:array[j + 1]] ) {
                        [array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    }
                }
            }
        }
    }
}

- (void)bubbleSort_key:(NSMutableArray<NSString *> *)array
{
    if (array.count > 1) {
        for (int i = 0; i < array.count; i++) {
            for (int j = 0; j < array.count - i; j++) {
                if (j + 1 < array.count) {
                    if ([self stringIntoNumber:array[j]] < [self stringIntoNumber:array[j + 1]] ) {
                        [array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    }
                }
            }
        }
    }
}



- (NSNumber *)dateIntoNumber:(journal *)j
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *component = [calendar components:unit fromDate:j.date];
    return [NSNumber numberWithInteger:component.year * 10000 + component.month * 100 + component.day];
}


- (NSNumber *)stringIntoNumber:(NSString *)string
{
    NSNumber *sum;
    if (string.length > 0 && string.length <= 7) {
        int year = [[string substringWithRange:NSMakeRange(0, 4)] intValue];
        int month = [[string substringWithRange:NSMakeRange(5, string.length - 5)] intValue];
        sum = [NSNumber numberWithInt:year * 100 + month];
    }
    return sum;
}



@end
