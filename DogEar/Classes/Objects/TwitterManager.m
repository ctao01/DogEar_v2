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

- (void) connectToTwitterAccount
{
    ACAccountStore * accountStore = [[ACAccountStore alloc]init];
    ACAccountType * twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    if (DEVICE_OS < 6.0)
    {
        [accountStore requestAccessToAccountsWithType:twitterType withCompletionHandler:^(BOOL granted, NSError *error) {
            if(granted)
            {
                if (!error)
                {
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Twitter_Account"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
                else
                {
                    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Twitter_Account"];
                    [[NSUserDefaults standardUserDefaults]synchronize];
                }
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Twitter_Account"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }];
    }
    else if (DEVICE_OS >= 6.0)
    {
        [accountStore requestAccessToAccountsWithType:twitterType
                                              options:nil
                                           completion:^(BOOL granted, NSError * error)
         {
             NSString * message;
             if (granted)
             {
                 if (!error)
                 {
                     [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"Twitter_Account"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     message = @"Connected";

                 }
                 else
                 {
                     [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Twitter_Account"];
                     [[NSUserDefaults standardUserDefaults]synchronize];
                     message = @"There are no Twitter accounts configured. You can add or create a Twitter account in Settings.";
                 }
             }
             else
             {
                 [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"Twitter_Account"];
                 [[NSUserDefaults standardUserDefaults]synchronize];
                 message = @"DogEar is not allowed to connect your Twitter account. You can change it in Settings.";

             }
         }];
    }
    else return;
}


- (SLComposeViewController*) tweetSLComposerSheetWithSharedImage:(UIImage *)image
{
    SLComposeViewController * tweetSLComposerSheet;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
       tweetSLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        SLComposeViewControllerCompletionHandler block = ^(SLComposeViewControllerResult result) {
            [tweetSLComposerSheet dismissViewControllerAnimated:YES completion:^{
                NSString *output = @"";
                switch (result)
                {
                    case SLComposeViewControllerResultCancelled:
                    {
                        output = @"ACtionCancelled";
                        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Your post has been canceled." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    case SLComposeViewControllerResultDone:
                    {
                        output = @"Post successfully";
                        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Your DogEar has been successfully posted to Twitter!" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                        [alertView show];
                    }
                        break;
                    default:
                        break;
                }
            }];
            
            
        };
        tweetSLComposerSheet.completionHandler = block;
        [tweetSLComposerSheet addImage:image];
    }
    else{
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"No Twitter Account" message:@"In order to connect, please set up your Twitter account in iPhone Settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
    return tweetSLComposerSheet;
}

- (TWTweetComposeViewController*) tweetTWComposerSheetWithSharedImage:(UIImage *)image
{
    TWTweetComposeViewController * tweetTWComposerSheet;
    if ([TWTweetComposeViewController canSendTweet])
    {
        tweetTWComposerSheet = [[TWTweetComposeViewController alloc] init];
        [tweetTWComposerSheet addImage:image];
        [tweetTWComposerSheet setInitialText:@"DogEar"];
        [tweetTWComposerSheet setCompletionHandler:^(TWTweetComposeViewControllerResult result)
        {
            if (result == TWTweetComposeViewControllerResultDone)
            {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Your DogEar was posted successfully." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alertView show];
            }
            
            if (result == TWTweetComposeViewControllerResultCancelled)
            {
                UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Your post has been canceled." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                [alertView show];
            }
        }];
    }
    else
    {
        NSLog(@"can't send tweet");
        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Post failed. Please try again." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [alertView show];
    }
    return tweetTWComposerSheet;

}



@end
