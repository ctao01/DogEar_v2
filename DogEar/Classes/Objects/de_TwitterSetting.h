//
//  de_TwitterSetting.h
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface de_TwitterSetting : NSObject

+ (BOOL)hasAccounts;

+ (void) changePrivacySetting;
+ (void) configureTwitterAccount;

@end
