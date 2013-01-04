//
//  MessageComposer.m
//  DogEar
//
//  Created by Joy Tao on 12/3/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "MessageManager.h"

@interface MessageManager()
@property (nonatomic , strong) MFMailComposeViewController * mailComposer;
@property (nonatomic , strong) MFMessageComposeViewController * messageComposer;
@end

static MessageManager * sharedManager = nil;


@implementation MessageManager
@synthesize mailComposer, messageComposer;

+(MessageManager*) sharedComposer
{
    @synchronized(self){
        if (sharedManager == nil)
            sharedManager = [[super allocWithZone:NULL] init];
    }
    return sharedManager;
}

+(id) allocWithZone:(NSZone *)zone
{
    return [self sharedComposer];
}

- (void) presentMailComposerWithSubject:(NSString*)subject withBody:(NSString*)body withAttachment:(NSData*)attachment withAttachmentFileName:(NSString*)filename fromParentViewController:(UIViewController*)vc
{
    if (!vc) return;
	
	if ([MFMailComposeViewController canSendMail])
	{
        self.mailComposer = nil;
        self.mailComposer = [[MFMailComposeViewController alloc]init];
        self.mailComposer.mailComposeDelegate = self;
        
		[self.mailComposer setSubject:subject];
        [self.mailComposer addAttachmentData:attachment mimeType:@"image/png" fileName:filename];
		
		[vc presentViewController:self.mailComposer animated:YES completion:nil];
	}
	else {
		NSLog(@"Can't send out");
	}
}

- (void) presentMessageComposerWithBody:(NSString*)body fromParentViewController:(UIViewController*)vc
{
    if (!vc) return;
	
	if ([MFMessageComposeViewController canSendText])
	{
        self.messageComposer = nil;
        self.messageComposer = [[MFMessageComposeViewController alloc]init];
        self.messageComposer.messageComposeDelegate = self;
        
        [self.messageComposer setBody:body];
		[vc presentViewController:self.messageComposer animated:YES completion:nil];
	}
	else {
		NSLog(@"Can't send out");
	}
}

- (void) presentShareImageFromDogEarObject:(DogEarObject*)sharedObject viaMailComposerFromParent:(UIViewController *)vcParent
{
    NSString *  bodyString = [NSString stringWithFormat:@"%@, insert Date:%@",[sharedObject title],[sharedObject insertedDate]];
    [self presentMailComposerWithSubject:[NSString stringWithFormat:@"DogEar :%@", sharedObject.title] withBody:bodyString withAttachment:[NSData dataWithContentsOfFile:sharedObject.imagePath] withAttachmentFileName:[NSString stringWithFormat:@"%@.png",sharedObject.title] fromParentViewController:vcParent];
}

- (void) presentShareImageFromDogEar:(DogEarObject*)sharedObject viaMessageComposerFromParentent:(UIViewController*)vcParent
{
    NSString *  bodyString = [NSString stringWithFormat:@"DogEar Kindly remind %@",sharedObject.title];
    [self presentMessageComposerWithBody:bodyString fromParentViewController:vcParent];

}

#pragma mark - MFMailComposeViewController Delegate Method

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled: you cancelled the operation and no email message was queued.");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved: you saved the email message in the drafts folder.");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail send: the email message is queued in the outbox. It is ready to send.");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail failed: the email message was not saved or queued, possibly due to an error.");
            break;
        default:
            NSLog(@"Mail not sent.");
            break;
    }
    // Remove the mail view
    [self.mailComposer dismissModalViewControllerAnimated:YES];
}

#pragma mark - MFMessageComposeViewController Delegate Method

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result
{
    [self.messageComposer dismissModalViewControllerAnimated:YES];
    
    if (result == MessageComposeResultCancelled)
        NSLog(@"Message cancelled");
    else if (result == MessageComposeResultSent)
        NSLog(@"Message sent");
    else
        NSLog(@"Message failed");
}

@end
