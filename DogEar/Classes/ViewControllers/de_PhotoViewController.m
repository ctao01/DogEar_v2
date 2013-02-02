//
//  de_PhotoViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_PhotoViewController.h"
#import "de_MainTabBarController.h"
#import "de_DetailViewController.h"

#import "de_ListTableViewController.h"
#import "de_BrowseTableViewController.h"
#import "de_FlaggedListViewController.h"

#import "TwitterManager.h"
#import "MessageManager.h"

//#import "UIImage+DGStyle.h"
//#import "CropView.h"
#import "NLImageCropperView.h"

#define IPHONE_NAVIGATION_BAR_HEIGHT 44
#define IPHONE_TOOL_BAR_HEIGHT 45
#define IPHONE_STATUS_BAR_HEIGHT 20


#define DEVICE_OS [[[UIDevice currentDevice] systemVersion] intValue]
#define kPDFPageBounds CGRectMake(0, 0, 8.5 * 72, 11 * 72)

#define ktapDiff 10
#define kWidthDifference 30 
#define kHeightDifference 30

@interface de_PhotoViewController ()
{
    UIPrintInteractionController *printController;
    NSString * keyString;
    
    // Zoom
    UIScrollView * scrollView;
    UIImageView * imageView;

    int currentAngle;

    // Auto Enhance Image
    BOOL isAutoEnhance;
    UIImage * originImage;
    
    // Image Crop

    UIView *overlayView;
//    CropView * cropView;
    NLImageCropperView * cropView;
    
    CGFloat cropTL_y; //top Left
    CGFloat cropTR_x; //top Right
    CGFloat cropBR_y; // Botton Right
    CGFloat cropBL_x;
    
    UIImageView * ivleftUp ;
	UIImageView * ivRightUp ;
	UIImageView * ivleftDown ;
	UIImageView * ivRightDown;
    
    UILabel * autoEnhanceLabel;
}
//@property (nonatomic) BKToolBarType bkToolBarType;
@property (nonatomic , retain) UIImage * photo;

@end

@implementation de_PhotoViewController
@synthesize photo = _photo;
@synthesize existingDogEar = _existingDogEar;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        currentAngle = 0.0f;
    }
    return self;
}

// JT-TODO: get rid of toolBarType - using "initWithImage: andDogEar:(DogEar*)dogEar"

//- (id) initWithImage:(UIImage*)image toolBarType:(BKToolBarType)toolBarType
//{
//    self = [self init];
//    if (self)
//    {
//        self.bkToolBarType = toolBarType;
//        self.photo = image;
//        self.view.backgroundColor = [UIColor blackColor];
//    }
//    return self;
//}

- (id) initWithImage:(UIImage*)image andExistingDogEar:(DogEarObject*)object
{
    self = [self init];
    if (self)
    {
        self.existingDogEar = object;
        self.photo = [[UIImage alloc]scaleAndRotateImage:image];
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.existingDogEar)
        keyString = self.existingDogEar.category;
    
    // JT:ScrollView Setup
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.delegate = self;
	imageView = [[UIImageView alloc] initWithImage:self.photo];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    originImage = imageView.image;
	[scrollView addSubview:imageView];
	scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
	scrollView.maximumZoomScale = 2.0;
    
	[scrollView setZoomScale:scrollView.minimumZoomScale];
	[self.view addSubview:scrollView];
	[self.view sendSubviewToBack:scrollView];
    scrollView.frame = CGRectOffset(scrollView.frame, 0.0f, - 68.0f);
    
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
//    imageView.tag = 222;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:imageView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc makeTabBarHidden:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    CGRect bounds = [[UIScreen mainScreen]bounds];
    NSInteger cameraActiveBarHeight;
    cameraActiveBarHeight = 68.0f;
    
    //    imageView.frame = CGRectOffset(imageView.frame, 0.0f, - cameraActiveBarHeight);
    
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, bounds.size.height - cameraActiveBarHeight - IPHONE_TOOL_BAR_HEIGHT, bounds.size.width, IPHONE_TOOL_BAR_HEIGHT)];
    toolBar.tag = 333;
    toolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem * spaceItme = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	if (self.existingDogEar == nil)
    {
        isAutoEnhance = NO;
        
        UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-rotate"]  style:UIBarButtonItemStyleBordered target:self action:@selector(rotateLeft)];
        //        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:@"Enhance" style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance)];
        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-enhance"] style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance:)];
        
        UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-crop"]  style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(storeTheImage)];
        self.navigationItem.rightBarButtonItem = saveItem;
        
//        self.photo = [self.photo imageRotatedByDegrees:-currentAngle];  //JT:Note rotate back to correct angle
    }
    else
    {
        UIBarButtonItem * shareItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareThePhoto)];
        de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
        
        UIBarButtonItem * cameraItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-camera"] style:UIBarButtonItemStyleDone target:tbc action:@selector(activateCamera)];
        
        UIBarButtonItem * trashItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteThePhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:shareItem, spaceItme, cameraItem, spaceItme, trashItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToList)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * detailItem = [[UIBarButtonItem alloc]initWithTitle:@"Details" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
        self.navigationItem.rightBarButtonItem = detailItem;
        self.navigationItem.title = self.existingDogEar.title;
    }
    [self.view addSubview:toolBar];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc makeTabBarHidden:NO];
    
//    self.existingDogEar = nil;
    
}

#pragma mark - Print Feature

- (NSData *) generatePDFDataForPrinting
{
    NSMutableData *pdfData = [NSMutableData data];
    UIGraphicsBeginPDFContextToData(pdfData, kPDFPageBounds, nil);
    UIGraphicsBeginPDFPage();
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    [self drawStuffInContext:ctx];  // Method also usable from drawRect:.
    UIImageView * printView = [[UIImageView alloc]initWithImage:self.photo];
    [printView.layer renderInContext:ctx];
    
    UIGraphicsEndPDFContext();
    NSLog(@"generatePDFDataForPrinting");
    return pdfData;
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) retakePhoto
{
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc activateCamera];
}


- (void) storeTheImage
{
    UIImage * savedImage;
    if (isAutoEnhance)
        savedImage = [[imageView.image autoEnhance] imageRotatedByDegrees:currentAngle];
    else
        savedImage = [imageView.image imageRotatedByDegrees:currentAngle];
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped andImage:savedImage];
//    [vc setAction:DogEarActionEditing];
    vc.existingDogEar = nil;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void) moreDetail
{
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped andImage:self.photo];
//    [vc setAction:DogEarActionViewing];
    vc.existingDogEar = self.existingDogEar;
    [self.navigationController pushViewController:vc animated:YES];

}

- (void) backToList
{
    if ([self.navigationController.viewControllers count]>=3)
    {
        de_ListTableViewController * vc = (de_ListTableViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
        de_ListTableViewController * previousVc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
        NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKFlaggedItems"];
        if ([previousVc isKindOfClass:[de_BrowseTableViewController class]])
            vc.navigationItem.title = self.existingDogEar.category;
        else if ([previousVc isKindOfClass:[de_FlaggedListViewController class]])
            vc.navigationItem.title = [array objectAtIndex:[self.existingDogEar.flagged integerValue]];
        [self.navigationController popToViewController:vc animated:YES];
    }
    else [self.navigationController popToRootViewControllerAnimated:YES];
    
    NSLog(@"%i",[self.navigationController.viewControllers count]);
}


#pragma mark - UIBarButtonItem (UIToolBar)

- (void) rotateLeft
{
    currentAngle = currentAngle - 90.0f;
    if (currentAngle == -360) currentAngle = 0.0;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( currentAngle / 180.0 * 3.14 );
	[scrollView setTransform:rotate];
    NSLog(@"%i",currentAngle);
    
//    UIImage * image = [self.photo imageRotatedByDegrees:currentAngle];
//    self.photo = image;
}

- (void) autoEnhance:(id)sender
{
    
    if (isAutoEnhance == NO)
    {
        imageView.image = [[imageView.image copy] autoEnhance];
        isAutoEnhance = YES;
    }
    else
    {
        imageView.image = originImage;
        isAutoEnhance = NO;
    }

    
    if (!autoEnhanceLabel)
    {
        autoEnhanceLabel = [[UILabel alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 200.0f, 20.0f)];
        CGRect bounds = [[UIScreen mainScreen]bounds];
        NSInteger cameraActiveBarHeight;
        cameraActiveBarHeight = 68.0f;
        autoEnhanceLabel.frame = CGRectOffset(autoEnhanceLabel.frame, 0.0f, bounds.size.height - cameraActiveBarHeight - IPHONE_TOOL_BAR_HEIGHT - autoEnhanceLabel.frame.size.height);
        autoEnhanceLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:12];
        autoEnhanceLabel.backgroundColor = [UIColor clearColor];
        autoEnhanceLabel.textColor = [UIColor whiteColor];
        
        [self.view addSubview:autoEnhanceLabel];
    }
    autoEnhanceLabel.text = [NSString stringWithFormat:@"Auto Enhance: %@",isAutoEnhance?@"On":@"Off"];
    autoEnhanceLabel.hidden = NO;
    
    [NSTimer scheduledTimerWithTimeInterval:2.5f target:self selector:@selector(dismissLabel) userInfo:nil repeats:NO];
}

- (void) dismissLabel
{
    autoEnhanceLabel.hidden = YES;
}

/******************************************************************************************/
- (void) cropPhoto
{    
    cropView = [[NLImageCropperView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:cropView];
    [cropView setImage:[imageView.image imageRotatedByDegrees:currentAngle]];
    [cropView setCropRegionRect:CGRectMake(10, 50, 450, 680)];
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCrop)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCrop)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) doneCrop
{
    imageView.image = [[cropView getCroppedImage] imageRotatedByDegrees:-currentAngle];
    originImage = imageView.image;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(storeTheImage)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
    [cropView removeFromSuperview];
}

- (void) cancelCrop
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(storeTheImage)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
    [cropView removeFromSuperview];
}

/******************************************************************************************/


- (void) shareThePhoto
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Share on Facebook",@"Share on Twitter",@"Email DogEar",@"Save To Camera Roll",@"Print", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}


- (void) deleteThePhoto
{
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Are you sure delete this DogEar" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Move To Trash", nil];
    [alertView show];
}

- (void) cancelExistingNotificationWithObject:(DogEarObject*)object
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in localNotifications)
    {
        NSDictionary * dict = notification.userInfo;
        if (dict)
        {
            NSDate * insertedDate = [dict objectForKey:@"DogEarObjectInsertedDate"];
            if ([insertedDate isEqualToDate:object.insertedDate])
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

#pragma mark - 

- (void) publishDogEarWithoutSheet
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    UIImage * pngImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.existingDogEar.imagePath]];
    
    [params setObject:self.existingDogEar.title forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(pngImg) forKey:@"picture"];


    
    [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                              UIAlertView * alertView;
                              if (error)
                                  alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Oops, Error !" delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                              else
                              {
                                  alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Post Successfully " delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
                                  [alertView show];
                              }
                              
                          }];
}

- (void) publishDogEar
{
    if (DEVICE_OS >= 6.0f)
    {
        if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
            
            SLComposeViewController *controller = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];                
            SLComposeViewControllerCompletionHandler block = ^(SLComposeViewControllerResult result){
                
                if (result == SLComposeViewControllerResultCancelled) {
                    
                    NSLog(@"Cancelled");
                    
                } else
                    
                {
                    NSLog(@"Done");
                }
                
                [controller dismissViewControllerAnimated:YES completion:Nil];
            };
            controller.completionHandler = block;
            [controller addImage:self.photo];
            [self presentViewController:controller animated:YES completion:Nil];
        }
        else
        {
            [self publishDogEarWithoutSheet];
            
        }
    }
    
    else
    {
        [self publishDogEarWithoutSheet];
    }
}

#pragma mark - NSuserDefaults  Method

- (NSMutableArray*) decodedCollections
{
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:self.existingDogEar.category];
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
    
    return decodedCollections;
}

- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)collections
{
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:collections];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    [dict setObject:encodedObjects forKey:self.existingDogEar.category];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"updateDogEarDataCollectionWithSelectedCollections");
}

#pragma mark -

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = scroll.bounds.size;
    CGRect frameToCenter = rView.frame;
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
    }
    else {
        frameToCenter.origin.x = 0;
    }
    
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
    }
    else {
        frameToCenter.origin.y = 0;
    }
	
	return frameToCenter;
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidZoom:(UIScrollView *)scrollV {
	imageView.frame = [self centeredFrameForScrollView:scrollV andUIView:imageView];

}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

#pragma mark - UIActionSheet Delegate Method

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == [actionSheet cancelButtonIndex]) return;
    switch (buttonIndex) {
        case 0: //Facebook
        {
            if (FBSession.activeSession.isOpen) {
                [self publishDogEar];
            } else {
                [FBSession openActiveSessionWithAllowLoginUI:YES success:^(FBSession *session, FBSessionState status, NSError *error) {
                    [self publishDogEar];

                } failure:^(FBSession *session, FBSessionState status, NSError *error) {
                    NSLog(@"Facebook connect Error.");
                }];
            }
        }
            break;
        case 1: // Twitter
        {
            TwitterManager * twitter  = [TwitterManager sharedManager];

            if (DEVICE_OS < 6.0)
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Twitter_Account"] == YES)[self presentViewController:[twitter tweetTWComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                else
                {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Can't connect to Twitter account. Please check your settings and try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Setting", nil];
                    [alertView show];
                }

            }
            else
            {
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Twitter_Account"] == YES) [self presentViewController:[twitter tweetSLComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                else
                {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter" message:@"Can't connect to Twitter account. Please check your settings and try again" delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:@"Setting", nil];
                    [alertView show];
                }
            }
        }
            break;
        case 2: // Email
        {
            MessageManager * composer = [MessageManager sharedComposer];
            [composer presentShareImageFromDogEarObject:self.existingDogEar viaMailComposerFromParent:self];
        }
            break;
        case 3: // Message
        {
            UIImageWriteToSavedPhotosAlbum(self.photo, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
 
        }
            break;
        case 4:
        {
            Class printControllerClass = NSClassFromString(@"UIPrintInteractionController");
            if (printControllerClass) {
                printController = [printControllerClass sharedPrintController];
            }
            
            void (^completionHandler)(UIPrintInteractionController *, BOOL, NSError *) =
            ^(UIPrintInteractionController *pic, BOOL completed, NSError *error) {
                if (!completed && error) NSLog(@"Print error: %@", error);
            };
            
            NSData *pdfData = [self generatePDFDataForPrinting];
            printController.printingItem = pdfData;
            printController.delegate = self;
            [printController presentAnimated:YES completionHandler:completionHandler];
        }
            
            break;
        default:
            break;
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        if ([alertView.title isEqualToString:@"Twitter Authorization"])
            [self.tabBarController setSelectedIndex:2];
        else if ([alertView.title isEqualToString:@"DogEar"])
        {
            de_ListTableViewController * vc  = (de_ListTableViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
            
            NSLog(@"%@",vc.collections);
            NSLog(@"%@",self.existingDogEar);


            
            NSMutableArray * temp = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
            
            for (int d = 0; d < [temp count]; d++)
            {
                DogEarObject * object = [temp objectAtIndex:d];
                if ([object.title isEqualToString:self.existingDogEar.title] && [object.insertedDate isEqualToDate:self.existingDogEar.insertedDate])
                    [self cancelExistingNotificationWithObject:object];
                    [temp removeObject:object];
            }
            
            [self updateDogEarDataCollectionWithSelectedCollections:temp];
            
            [vc.collections removeObject:self.existingDogEar];
            
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSString * message;
    if (error != NULL)
        message = @"Oops, Save To Camera Roll Failed...";
    else  // No errors
        message = @"DogEar has been saved to camera roll";
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:message delegate:self cancelButtonTitle:@"Okay" otherButtonTitles: nil];
    [alertView show];
}
@end
