//
//  BKDogEar.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "DogEarObject.h"

@implementation DogEarObject

@synthesize title;
@synthesize note;
@synthesize category;
@synthesize reminderDate;
@synthesize flagged;
@synthesize insertedDate;


+ (NSArray *)keys
{
    return [NSArray arrayWithObjects:
            @"title",
            @"note",
            @"category",
            @"reminderDate",
            @"insertedDate",
            @"flagged",
            nil];
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.note forKey:@"note"];
    [encoder encodeObject:self.category forKey:@"category"];
    [encoder encodeObject:self.reminderDate forKey:@"reminder"];
    [encoder encodeObject:self.insertedDate forKey:@"insertedDate"];
    [encoder encodeObject:self.flagged forKey:@"flagged"];
    
    
}
- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if( self != nil )
    {
        self.title = [decoder decodeObjectForKey:@"title"];
        self.note = [decoder decodeObjectForKey:@"note"];
        self.category = [decoder decodeObjectForKey:@"category"];
        self.reminderDate = [decoder decodeObjectForKey:@"reminder"];
        self.insertedDate = [decoder decodeObjectForKey:@"insertedDate"];
        self.flagged = [decoder decodeObjectForKey:@"flagged"];

    }
    return self;
}


@end
