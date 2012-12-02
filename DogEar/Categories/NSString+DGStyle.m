//
//  NSString+DGStyle.m
//  DogEar
//
//  Created by Joy Tao on 11/28/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "NSString+DGStyle.h"

@implementation NSString (DEStyle)

+ (NSString*) imagePathWithFileName:(NSString*)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsPath = [paths objectAtIndex:0]; //Get the docs directory
    NSString *filePath = [documentsPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png",filename]];
    
    return filePath;
}

+ (NSString*) mediumStyleDateAndShortStyleTimeWithDate:(NSDate*)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    NSString * dateString = [formatter stringFromDate:date];

    return dateString;
}

+ (NSString*) reminderStyleWithDate:(NSDate*)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"EEEE, MMM d, yyyy, hh:mm a"];

    
    NSString * dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+ (NSString*) reminderSubtitleStyleWithDate:(NSDate*)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/d/yy,hh:mm a"];
    
    NSString * dateString = [formatter stringFromDate:date];
    
    return dateString;
}

+ (NSString *)generateRandomStringWithDate:(NSDate*)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMddhhmmss"];    
    NSString * dateString = [formatter stringFromDate:date];
    
    return dateString;
}


+ (NSString *) generateRandomString
{
    int len = 6;
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random() % [letters length]]];
    }
    return randomString;
}


@end
