//
//  journal+CoreDataProperties.h
//  Life Journey
//
//  Created by Michael_Xiong on 6/28/16.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

#import "journal.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface journal (CoreDataProperties)

@property (nullable, nonatomic, retain) NSString *journal;
@property (nullable, nonatomic, retain) NSDate *date;
@property (nullable, nonatomic, retain) UIImage *thumbnail;
@property (nullable, nonatomic, retain) NSString *location;
@property (nullable, nonatomic, retain) UIImage *photo;
@property (nullable, nonatomic, retain) NSString *section;

- (UIImage *)setThumbnailFromImage:(UIImage *)image;
- (UIImage *)clipPhotoFromImage:(UIImage *)image;


@end

NS_ASSUME_NONNULL_END
