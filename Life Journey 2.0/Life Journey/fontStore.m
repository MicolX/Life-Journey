//
//  fontStore.m
//  Life Journey
//
//  Created by Michael_Xiong on 16/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "fontStore.h"
#import "font.h"

@interface fontStore ()

@property (nonatomic, strong)font *font;

@end

@implementation fontStore

+ (instancetype)sharedStore
{
    static fontStore *sharedStore;
    if (! sharedStore) {
        sharedStore = [[self alloc] initPrivate];
    }
    return sharedStore;
}

- (instancetype)initPrivate
{
    if (self = [super init]) {
        NSString *path = [self fontArchivePath];
        _font = [NSKeyedUnarchiver unarchiveObjectWithFile:path];
        
        if (!_font) {
            _font = [[font alloc] init];
            _font.fontName = @"AppleGothic";
            _font.fontSize = 18;
        }
    }
    return self;
}

- (NSString *)fontArchivePath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentDirectory = [documentDirectories firstObject];
    
    return [documentDirectory stringByAppendingPathComponent:@"font.archive"];
}

- (BOOL)saveFonts
{
    NSString *path = [self fontArchivePath];
    
    return [NSKeyedArchiver archiveRootObject:self.font toFile:path];
}

- (NSString *)getFontName
{
    return _font.fontName;
}

- (CGFloat)getFontSize
{
    return _font.fontSize;
}

- (void)setFontName:(NSString *)name fontSize:(CGFloat)size
{
    _font.fontName = name;
    _font.fontSize = size;
}

@end
