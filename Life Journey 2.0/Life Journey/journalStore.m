//
//  journalStore.m
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "journalStore.h"
#import "journal.h"
#import "passwordStore.h"

#define JOURNAL         @"journal"
#define DATE            @"date"
#define LOCATION        @"location"
#define PHOTO           @"photo"
#define THUMBNAIL       @"thumbnail"
#define SECTION         @"section"
#define TOKENKEY        @"com.MichaelXiong.LifeJourney.UbiquityIdentityToken"

@import CoreData;

@interface journalStore ()

@property (nonatomic, strong)NSManagedObjectModel *model;
@property (nonatomic, strong)CKDatabase *privateDatabase;
@property (nonatomic, strong)NSMutableArray<CKRecordID *> *journalsNeedToBeDeletedOniCloud;
@property (nonatomic, strong)NSCondition *condition;

@property (nonatomic) BOOL appFirstLaunch;
@property (nonatomic)BOOL threadNeedToBeBlocked;


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
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(passwordPassed) name:@"PasswordDismiss" object:nil];
        
        self.model = [NSManagedObjectModel mergedModelFromBundles:nil];
        NSPersistentStoreCoordinator *psc = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:self.model];
        
        NSError *error;
        
        if (![psc addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:[self localStorePath] options:nil error:&error]) {
            [NSException raise:@"Open Failure" format:@"Reason: %@", [error localizedDescription]];
        }
        
        self.context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        self.context.persistentStoreCoordinator = psc;
                
        if (![[passwordStore sharedStore] hasPassword]) {
            [self verifyiCloudAvailability];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(iCloudAccountChanged) name:CKAccountChangedNotification object:nil];
    }
    return self;
}

- (NSURL *)localStorePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories firstObject];
    NSURL *url = [[NSURL fileURLWithPath:documentDirectory] URLByAppendingPathComponent:@"journal.data"];
    
    return url;
}

- (NSMutableArray *)allJournals
{
    if (!_allJournals) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        NSEntityDescription *e = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:self.context];
        [request setEntity:e];
        
        NSError *error;
        NSArray *result = [self.context executeFetchRequest:request error:&error];
        
        if (!result) {
            [NSException raise:@"Fetch failed!" format:@"Reason: %@", [error localizedDescription]];
        } else {
            _allJournals = [[NSMutableArray alloc] initWithArray:result];
            [self bubbleSort_date:_allJournals];
        }
    }
    
    return _allJournals;
}


- (journal *)addJournal
{
    journal *journal = [NSEntityDescription insertNewObjectForEntityForName:@"Journal" inManagedObjectContext:self.context];
    [self.allJournals insertObject:journal atIndex:0];
    
    return journal;
}

- (void)removeJournal:(journal *)journal
{
    [self.allJournals removeObjectIdenticalTo:journal];
    [self.context deleteObject:journal];
}


- (void)deleteAllJournalsInCoreData
{
    
    for (journal *j in self.allJournals) {
        [self.context deleteObject:j];
    }
    
    [self.allJournals removeAllObjects];
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



- (BOOL)appFirstLaunch
{
    NSUserDefaults *timeOfBootCount = [NSUserDefaults standardUserDefaults];
    if (![timeOfBootCount valueForKey:@"time"]) {
        [timeOfBootCount setValue:@"sd" forKey:@"time"];
        NSLog(@"app first launched");
        return YES;
    } else {
        NSLog(@"app is not first time launched");
        return NO;
    }
}

- (void)passwordPassed
{
    [self verifyiCloudAvailability];
}

#pragma mark - iCloud

- (void)verifyiCloudAvailability
{
    [[CKContainer defaultContainer] accountStatusWithCompletionHandler:^(CKAccountStatus status, NSError *error) {
        
        if (!error) {
            switch (status) {
                    
                case CKAccountStatusCouldNotDetermine:
                    NSLog(@"account status could not determine");
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:NSLocalizedString(@"iCloud account status could not determine, Please check your iCloud setting", nil)];
                    
                    self.iCloudWasOn = NO;
                    break;
                    
                case CKAccountStatusAvailable:
                    
                    NSLog(@"accout is available");
                    
                    self.privateDatabase = [[CKContainer defaultContainer] privateCloudDatabase];
                    
                    if (![[NSUserDefaults standardUserDefaults] objectForKey:TOKENKEY]) {
                        [self archiveCurrentToken];
                    }
                    
                    if (self.appFirstLaunch) {
                        
                        //check if there is journal on local
                        if (self.allJournals.count) {
                            
                            //local journals exist, back up to iCloud and inform the user
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudNotify" object:NSLocalizedString(@"Uploading journals to iCloud", nil)];
                            [self.privateDatabase addOperation:[self backupAllJournalsToCloud]];
                            
                        } else {
                            
                            //no local journals, fetch from iCloud
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudNotify" object:NSLocalizedString(@"Downloading Journals", nil)];
                            [self fetchAllJournalsFromCloud];
                        }
                        
                    } else {
                        
                        //check if iCloud account is the one which logged in last time
                        if ([self compareToken]) {
                            
                            if (!self.iCloudWasOn) {
                                NSLog(@"icloud was off");
                                [self syncJournalsBetweenLocalAndiCloud];
                            }
                            
                        } else {
                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudNotify" object:NSLocalizedString(@"Different iCloud account detected", nil)];
                            
                            [self deleteAllJournalsInCoreData];
                            [self fetchAllJournalsFromCloud];
                        }
                    }
                
                    self.iCloudWasOn = YES;
                
                    break;
                    
                case CKAccountStatusNoAccount:
                    NSLog(@"accout status NO account");
                    
                    if (self.appFirstLaunch || self.iCloudWasOn == YES) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"iCloudSuggestion" object:nil];
                    }
                    self.iCloudWasOn = NO;
                    break;
                    
                case CKAccountStatusRestricted:
                    NSLog(@"account status restricted");
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:NSLocalizedString(@"iCloud account is restricted, Please check your iCloud setting", nil)];
                    self.iCloudWasOn = NO;
                    break;
                    
                default:
                    break;
            }
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[error localizedDescription]];
        }
    }];
}

- (CKModifyRecordsOperation *)backupAllJournalsToCloud
{
    NSLog(@"back up to icloud");
    NSMutableArray<CKRecord *> *journalsToBeUploaded = [NSMutableArray new];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    NSEntityDescription *e = [NSEntityDescription entityForName:@"Journal" inManagedObjectContext:self.context];
    [request setEntity:e];
    
    NSError *error;
    NSArray *result = [self.context executeFetchRequest:request error:&error];
    if (!result) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[error localizedDescription]];
        [NSException raise:@"Fetch failed!" format:@"Reason: %@", [error localizedDescription]];
    }
    
    for (journal *journal in result) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@", journal.date]];
        CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Journals" recordID:recordID];
        record[JOURNAL] = journal.journal;
        record[JOURNAL] = journal.journal;
        record[DATE] = journal.date;
        record[LOCATION] = journal.location;
        
        if (journal.photo != nil) {
            NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
            if (photoData != nil) {
                record[PHOTO] = photoData;
            } else {
                record[PHOTO] = [NSData dataWithData:UIImagePNGRepresentation(journal.photo)];
            }
            
            NSData *thumbnailData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
            if (thumbnailData != nil) {
                record[THUMBNAIL] = thumbnailData;
            } else {
                record[THUMBNAIL] = [NSData dataWithData:UIImagePNGRepresentation(journal.thumbnail)];
            }
        }
        
        [journalsToBeUploaded addObject:record];
    }
    
    CKModifyRecordsOperation *saveOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:journalsToBeUploaded recordIDsToDelete:nil];
    
    saveOperation.qualityOfService = NSQualityOfServiceUserInitiated;
    saveOperation.timeoutIntervalForRequest = 30;
    
    saveOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> *savedRecords, NSArray<CKRecordID *> *deletedRecordIDs, NSError *operationError) {
        if (!operationError) {
            NSLog(@"backup complete");
            self.threadNeedToBeBlocked = NO;
            [self.condition signal];
            [_delegate dataDidFetched];
        } else {
            NSLog(@"%@", operationError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[operationError localizedDescription]];
        }
    };
    
    return saveOperation;
    
}


- (void)uploadJournalToCloud:(journal *)journal
{
    
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@", journal.date]];
    CKRecord *record = [[CKRecord alloc] initWithRecordType:@"Journals" recordID:recordID];
    
    record[JOURNAL] = journal.journal;
    record[DATE] = journal.date;
    record[LOCATION] = journal.location;
    
    if (journal.photo != nil) {
        NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
        if (photoData != nil) {
            record[PHOTO] = photoData;
        } else {
            record[PHOTO] = [NSData dataWithData:UIImagePNGRepresentation(journal.photo)];
        }
        
        NSData *thumbnailData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
        if (thumbnailData != nil) {
            record[THUMBNAIL] = thumbnailData;
        } else {
            record[THUMBNAIL] = [NSData dataWithData:UIImagePNGRepresentation(journal.thumbnail)];
        }
    }
    
    
    [self.privateDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
        if (error) {
            NSLog(@"upload failed: %@", [error localizedDescription]);
            
        } else {
            NSLog(@"upload successfully");
        }
    }];
    
}

- (void)deleteJournalFromCloud:(journal *)journal
{
    CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@", journal.date]];
    
    [self.privateDatabase deleteRecordWithID:recordID completionHandler:^(CKRecordID *ID, NSError *error) {
        if (error) {
            NSLog(@"error: %@", [error localizedDescription]);
        } else {
            NSLog(@"delete journal from cloud successfully!");
        }
    }];
}

- (void)modifyJournalOnCloud:(journal *)journal journalIsChanged:(BOOL)journalIsChanged photoIsChanged:(BOOL)photoIsChanged
{
    if (journalIsChanged || photoIsChanged) {
        CKRecordID *recordID = [[CKRecordID alloc] initWithRecordName:[NSString stringWithFormat:@"%@", journal.date]];
        
        [self.privateDatabase fetchRecordWithID:recordID completionHandler:^(CKRecord *record, NSError *error) {
            if (error) {
                NSLog(@"modify failed, fetch failed: %@", [error localizedDescription]);
            } else {
                if (journalIsChanged) {
                    record[JOURNAL] = journal.journal;
                }
                
                if (photoIsChanged) {
                    if (journal.photo == nil) {
                        record[PHOTO] = nil;
                        record[THUMBNAIL] = nil;
                    } else {
                        NSData *photoData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
                        if (photoData != nil) {
                            record[PHOTO] = photoData;
                        } else {
                            record[PHOTO] = [NSData dataWithData:UIImagePNGRepresentation(journal.photo)];
                        }
                        
                        NSData *thumbnailData = [NSData dataWithData:UIImageJPEGRepresentation(journal.photo, 0.5)];
                        if (thumbnailData != nil) {
                            record[THUMBNAIL] = thumbnailData;
                        } else {
                            record[THUMBNAIL] = [NSData dataWithData:UIImagePNGRepresentation(journal.thumbnail)];
                        }
                    }
                }
                
                [self.privateDatabase saveRecord:record completionHandler:^(CKRecord *record, NSError *error) {
                    if (error) {
                        NSLog(@"modify on cloud failed: %@", [error localizedDescription]);
                    } else {
                        NSLog(@"modify on cloud successfully");
                    }
                }];
            }
            
        }];
    }
    
}

- (CKQueryOperation *)createQueryOperationForOneRecordWith:(CKQuery *)query orCursor:(CKQueryCursor *)cursor forSync:(BOOL)sync
{
    NSLog(@"create query, down journals begin");
    if (sync) {
        self.journalsNeedToBeDeletedOniCloud = [NSMutableArray new];
    }
    
    __block CKQueryOperation *queryOperation;
    if (query) {
        NSLog(@"query");
        queryOperation = [[CKQueryOperation alloc] initWithQuery:query];
    } else if (cursor) {
        NSLog(@"cursor");
        queryOperation = [[CKQueryOperation alloc] initWithCursor:cursor];
    } else {
        return nil;
    }
    
    queryOperation.qualityOfService = NSQualityOfServiceUserInitiated;
    queryOperation.timeoutIntervalForRequest = 30;
    
    queryOperation.recordFetchedBlock = ^(CKRecord *record) {
        NSLog(@"a record fetched");
        if (sync) {
            NSLog(@"add to a array for delete later");
            [self.journalsNeedToBeDeletedOniCloud addObject:record.recordID];
        }
        
        NSLog(@"check if need to import");
        //check if we have this journal on local already
        BOOL needToImport = YES;
        if (self.allJournals.count) {
            NSLog(@"privateJournal has journal");
            for (journal *j in self.allJournals) {
                if ([[self dateIntoNumber:j.date] isEqual:[self dateIntoNumber:record[DATE]]]) {
                    NSLog(@"duplicated, don't import");
                    needToImport = NO;
                }
            }
        }
        
        if (needToImport) {
            NSLog(@"import a journal");
            journal *journal = [NSEntityDescription insertNewObjectForEntityForName:@"Journal" inManagedObjectContext:self.context];
            
            journal.journal = record[JOURNAL];
            journal.date = record[DATE];
            journal.location = record[LOCATION];
            
            if (record[PHOTO]) {
                UIImage *photo = [UIImage imageWithData:record[PHOTO]];
                UIImage *cutImage = [journal clipPhotoFromImage:photo];
                journal.photo = cutImage;
                
                journal.thumbnail = [journal setThumbnailFromImage:photo];
            }
            
            [self.allJournals addObject:journal];
        }
    };
    
    queryOperation.queryCompletionBlock = ^(CKQueryCursor *cursor, NSError *queryCompletionError) {
        if (!queryCompletionError) {
            if (cursor) {
                NSLog(@"there is more to fetch");
                CKQueryOperation *newOperation = [self createQueryOperationForOneRecordWith:nil orCursor:cursor forSync:sync];
                [self.privateDatabase addOperation:newOperation];
            } else {
                NSLog(@"download complete");
                
                //save context
                NSError *coreDataError;
                BOOL success = [self.context save:&coreDataError];
                if (success) {
                    NSLog(@"import complete & successfully");
                    [self bubbleSort_date:self.allJournals];
                } else {
                    NSLog(@"import failed, %@", [coreDataError localizedDescription]);
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[coreDataError localizedDescription]];
                }
                
                if (sync) {
                    self.threadNeedToBeBlocked = NO;
                    [self.condition signal];
                } else {
                    [_delegate dataDidFetched];
                }
            }
        } else {
            NSLog(@"%@", queryCompletionError);
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[queryCompletionError localizedDescription]];
        }
    };
    
    return queryOperation;
}

- (void)fetchAllJournalsFromCloud
{
    NSLog(@"fetchAllJournalsFromCloud called!, %@", [NSThread currentThread]);
    
    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    
    CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Journals" predicate:predicate];
    
    [self.privateDatabase addOperation:[self createQueryOperationForOneRecordWith:query orCursor:nil forSync:NO]];
    
}


- (void)syncJournalsBetweenLocalAndiCloud
{
    NSLog(@"syncJournals called");
    
    self.threadNeedToBeBlocked = YES;
    
    self.condition = [[NSCondition alloc] init];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShowHudNotify" object:NSLocalizedString(@"Syncing, Please wait", nil)];
    
    if (self.allJournals.count == 0) {
        [self fetchAllJournalsFromCloud];
    } else {
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(void) {
            
            NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
            CKQuery *query = [[CKQuery alloc] initWithRecordType:@"Journals" predicate:predicate];
     
            [self.condition lock];
            
            //1.import journals from icloud
            NSLog(@"import journals from icloud");
            CKQueryOperation *queryOperation = [self createQueryOperationForOneRecordWith:query orCursor:nil forSync:YES];
            [queryOperation start];
            
            
            while (self.threadNeedToBeBlocked) {
                NSLog(@"importing, block thread");
                [self.condition wait];
            }
            
            
            //2. delete all journals on icloud
            if (self.journalsNeedToBeDeletedOniCloud.count) {
                self.threadNeedToBeBlocked = YES;
                
                CKModifyRecordsOperation *deleteOperation = [[CKModifyRecordsOperation alloc] initWithRecordsToSave:nil recordIDsToDelete:self.journalsNeedToBeDeletedOniCloud];
                
                deleteOperation.qualityOfService = NSQualityOfServiceUserInitiated;
                
                deleteOperation.modifyRecordsCompletionBlock = ^(NSArray<CKRecord *> *savedRecords, NSArray<CKRecordID *> *deletedRecordIDs, NSError *operationError) {
                    NSLog(@"delete complete");
                    self.threadNeedToBeBlocked = NO;
                    [self.condition signal];
                    if (operationError) {
                        NSLog(@"%@", operationError);
                        [[NSNotificationCenter defaultCenter] postNotificationName:@"ErrorMessage" object:[operationError localizedDescription]];
                    }
                };
                
                [deleteOperation start];
            }
           
            
            while (self.threadNeedToBeBlocked) {
                NSLog(@"deleting, block thread");
                [self.condition wait];
                
            }
            
            //backup all journals to icloud
            self.threadNeedToBeBlocked = YES;
            
            CKModifyRecordsOperation *backupOperation = [self backupAllJournalsToCloud];
            [backupOperation start];
            
            while (self.threadNeedToBeBlocked) {
                NSLog(@"uploading, block thread");
                [self.condition wait];
            }
            
            [self.condition unlock];
        });
    
    }
}


- (BOOL)iCloudWasOn
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"iCloudWasOn"];
}

- (void)setICloudWasOn:(BOOL)iCloudWasOn
{
    [[NSUserDefaults standardUserDefaults] setBool:iCloudWasOn forKey:@"iCloudWasOn"];
}

- (void)iCloudAccountChanged
{
    NSLog(@"iCloud account changed");
    
    //check list: 1. compare token to check if account changed  2. if iCloud is off
    
    //get token first, compare with the old one, if token doesn't exist, iCloud is off
    
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (token) {
        NSLog(@"token exist, compare the old one");
        NSData *oldTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:TOKENKEY];
        id oldToken = [NSKeyedUnarchiver unarchiveObjectWithData:oldTokenData];
        
        if ([oldToken isEqual:token]) {
            NSLog(@"same token");
        } else {
            //account changed, delete local journals, fetch from iCloud
            NSLog(@"different token");
            [self deleteAllJournalsInCoreData];
            [self fetchAllJournalsFromCloud];
            [self archiveCurrentToken];
        }
        
    } else {
        NSLog(@"token doesn't exist, icloud is off");
        self.iCloudWasOn = NO;
    }
}

- (void)archiveCurrentToken
{
    id token = [[NSFileManager defaultManager] ubiquityIdentityToken];
    id tokenData = [NSKeyedArchiver archivedDataWithRootObject:token];
    [[NSUserDefaults standardUserDefaults] setObject:tokenData forKey:TOKENKEY];
}

- (BOOL)compareToken
{
    BOOL isSame;
    id currentToken = [[NSFileManager defaultManager] ubiquityIdentityToken];
    
    if (currentToken) {
        NSLog(@"current token get!");
        NSData *oldTokenData = [[NSUserDefaults standardUserDefaults] objectForKey:TOKENKEY];
        id oldToken = [NSKeyedUnarchiver unarchiveObjectWithData:oldTokenData];
        
        if ([currentToken isEqual:oldToken]) {
            NSLog(@"same token");
            isSame = YES;
        } else {
            NSLog(@"different token");
            [self archiveCurrentToken];
            isSame = NO;
        }
    } else {
        NSLog(@"no token get");
        
    }
    
    return isSame;
}


#pragma mark - Sorting Method

- (NSString *)getYearAndMonth:(journal *)j
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger components = NSCalendarUnitYear | NSCalendarUnitMonth;
    NSDateComponents *dateComponents = [calendar components:components fromDate:j.date];
    return [NSString stringWithFormat:@"%ld-%ld", (long)dateComponents.year,(long)dateComponents.month];
}


- (NSNumber *)dateIntoNumber:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *component = [calendar components:unit fromDate:date];
    return [NSNumber numberWithInteger:component.year * 10000 + component.month * 100 + component.day];
}

- (void)bubbleSort_date:(NSMutableArray<journal *> *)array
{
    if (array.count > 1) {
        for (int i = 0; i < array.count; i++) {
            for (int j = 0; j < array.count - i; j++) {
                if (j + 1 < array.count) {
                    if ([self dateIntoNumber:array[j].date] < [self dateIntoNumber:array[j + 1].date] ) {
                        [array exchangeObjectAtIndex:j withObjectAtIndex:j + 1];
                    }
                }
            }
        }
    }
}

@end
