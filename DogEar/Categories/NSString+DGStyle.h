//
//  NSString+DGStyle.h
//  DogEar
//
//  Created by Joy Tao on 11/28/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (DEStyle)

+ (NSString*) imagePathWithFileName:(NSString*)filename;
+ (NSString*) mediumStyleDateAndShortStyleTimeWithDate:(NSDate*)date;

@end
