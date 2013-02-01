//
//  MessageComposer.h
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>

@interface MessageManager : NSObject <MFMailComposeViewControllerDelegate , MFMessageComposeViewControllerDelegate>

+(MessageManager*) sharedComposer;

- (void) presentShareImageFromDogEarObject:(DogEarObject*)sharedObject viaMailComposerFromParent:(UIViewController *)vcParent;
- (void) presentShareImageFromDogEar:(DogEarObject*)sharedObject viaMessageComposerFromParentent:(UIViewController*)vcParent;

- (void) reportSupportviaMailComposerFromParent:(UIViewController *)vcParent;


@end
