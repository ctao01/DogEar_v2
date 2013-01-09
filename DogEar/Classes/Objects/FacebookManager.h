//
//  FacebookManager.h
//  DogEar
//
//  Created by Joy Tao on 1/9/13.
//  Copyright (c) 2013 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <Accounts/Accounts.h>
#import <Social/Social.h>

@interface FacebookManager : NSObject <UIAlertViewDelegate>

+(id) sharedManager;
- (void) connectToFacebookAccount;

- (SLComposeViewController*) facebookSLComposerSheetWithSharedImage:(UIImage*)image;

@end
