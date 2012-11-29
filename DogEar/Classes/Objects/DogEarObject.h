//
//  BKDogEar.h
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DogEarObject : NSObject

@property (nonatomic , strong) NSString * title;
@property (nonatomic , strong) NSString * note;
@property (nonatomic , strong) NSString * category;
@property (nonatomic , strong) NSString * imagePath;

@property (nonatomic , strong) NSDate * reminderDate;
@property (nonatomic , strong) NSDate * insertedDate;

@property (nonatomic , strong) NSNumber * flagged;
@property (nonatomic , strong) NSNumber * imageOrientation;

- (void)encodeWithCoder:(NSCoder *)encoder;
- (id)initWithCoder:(NSCoder *)decoder;

+ (NSArray *)keys;


@end
