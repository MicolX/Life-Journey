//
//  passwordStore.m
//  Life Journey
//
//  Created by Michael_Xiong on 21/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "passwordStore.h"
#import "password.h"

@interface passwordStore () 

@property (nonatomic, strong)password *password;

@end

@implementation passwordStore

+ (instancetype)sharedStore
{
    static passwordStore *sharedStore;
    if (!sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}
                       
- (instancetype)initPrivate
{
    if (self = [super init]) {
        
        NSString *path = [self passwordArchivePath];
        _password = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (_password) {
            self.hasPassword = YES;
        } else {
            self.hasPassword = NO;
        }
    }
    return self;
}


- (NSString *)passwordArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"password.archive"];
}

- (BOOL)saveChanges
{
    NSString *path = [self passwordArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.password toFile:path];
}



- (NSString *)getPassword
{
    return _password.password;
}

- (void)setThePassword:(NSString *)string
{
    if (!_password) {
        _password = [[password alloc] init];
    }
    _password.password = string;
}

- (BOOL)hasPassword
{
    return _password.password ? YES:NO;
}

- (BOOL)verify:(NSString *)password
{
    return [password isEqualToString:_password.password] ? YES:NO;
}

- (void)setTouchIDEnabled:(BOOL)enable
{
    self.password.touchIDEnabled = enable;
}

- (BOOL)touchIDEnabled
{
    return self.password.touchIDEnabled;
}

@end
