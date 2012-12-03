//
//  TwitterManager.h
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>
#import <Social/Social.h>

@interface TwitterManager : NSObject

+(id) sharedManager;

- (SLComposeViewController*) tweetSLComposerSheet;
- (TWTweetComposeViewController*) tweetTWComposerSheet;


@end
