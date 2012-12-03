//
//  de_TwitterSetting.m
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_TwitterSetting.h"
#define SYSTEM_OS [[[UIDevice currentDevice] systemVersion] intValue]

@implementation de_TwitterSetting

+ (BOOL)hasAccounts {
    // For clarity
    return [TWTweetComposeViewController canSendTweet];

//    NSInteger systemOS =  [[[UIDevice currentDevice] systemVersion] intValue];
//    if (SYSTEM_OS < 6.0)
//        return [TWTweetComposeViewController canSendTweet];
//
//    else
//        return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}


+ (void) changePrivacySetting
{
    
}

+ (void) configureTwitterAccount
{
    TWTweetComposeViewController * ctrl = [[TWTweetComposeViewController alloc] init];
    if ([ctrl respondsToSelector:@selector(alertView:clickedButtonAtIndex:)]) {
        // Manually invoke the alert view button handler
        [(id <UIAlertViewDelegate>)ctrl alertView:nil
                             clickedButtonAtIndex:0];
    }
}


@end
