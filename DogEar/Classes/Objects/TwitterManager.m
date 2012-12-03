//
//  TwitterManager.m
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "TwitterManager.h"
#import "AppDelegate.h"

#define DEVICE_OS [[[UIDevice currentDevice] systemVersion] intValue]

static TwitterManager * sharedManager = nil;

@implementation TwitterManager

+ (id) sharedManager
{
    @synchronized(self){
    if (sharedManager == nil)
        sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (void) getCurrentTwitterAccount
{
    ACAccountStore * accountStore = [[ACAccountStore alloc]init];
    ACAccountType * twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    
    [accountStore requestAccessToAccountsWithType:twitterType
                                          options:nil
                                       completion:^(BOOL granted, NSError * error)
     {
         ACAccount * twitterAccount = nil;
         
         if (granted)
         {
             NSArray * accounts = [accountStore accountsWithAccountType:twitterType];
             if ([accounts count] > 0)
                 twitterAccount = [accounts lastObject];
         }
         [[NSUserDefaults standardUserDefaults]setObject:twitterAccount.username forKey:@"Twitter_Username"];
         [[NSUserDefaults standardUserDefaults]setObject:twitterAccount.identifier forKey:@"Twitter_Account"];
         [[NSUserDefaults standardUserDefaults]synchronize];
         NSLog(@"%@",[[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Username"]);

     }];
}


- (SLComposeViewController*) tweetSLComposerSheet
{
    SLComposeViewController * tweetSLComposerSheet;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
       tweetSLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler block = ^(SLComposeViewControllerResult result) {
            [tweetSLComposerSheet dismissViewControllerAnimated:YES completion:nil];
            
            NSString *output = @"";
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    output = @"ACtionCancelled";
                    break;
                case SLComposeViewControllerResultDone:
                    output = @"Post Successfull";
                    break;
                default:
                    break;
            }
        };
        tweetSLComposerSheet.completionHandler = block;
    }
    else{
        NSLog(@"can't send tweet");
    }
    return tweetSLComposerSheet;
}

- (TWTweetComposeViewController*) tweetTWComposerSheet
{
    TWTweetComposeViewController * tweetTWComposerSheet;
    if ([TWTweetComposeViewController canSendTweet])
        tweetTWComposerSheet = [[TWTweetComposeViewController alloc] init];
    else
        NSLog(@"can't send tweet");
    return tweetTWComposerSheet;

}



@end
