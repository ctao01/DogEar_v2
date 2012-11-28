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

@end
