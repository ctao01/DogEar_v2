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

#import "TwitterManager.h"
#import "MessageManager.h"

#import "UIImage+DGStyle.h"

#define IPHONE_NAVIGATION_BAR_HEIGHT 44
#define IPHONE_TOOL_BAR_HEIGHT 45
#define IPHONE_STATUS_BAR_HEIGHT 20

#define DEVICE_OS [[[UIDevice currentDevice] systemVersion] intValue]
#define kPDFPageBounds CGRectMake(0, 0, 8.5 * 72, 11 * 72)

int currentAngle = 0;


@interface de_PhotoViewController ()
{
    UIPrintInteractionController *printController;
    NSString * keyString;
    
    // Zoom in/ out
    UIScrollView * scrollView;
    UIImageView * imageView;
    
    BOOL isAutoEnhance;

}
@property (nonatomic) BKToolBarType bkToolBarType;
@property (nonatomic , retain) UIImage * photo;
@property (nonatomic , retain) DogEarObject * existingDogEar;

@end

@implementation de_PhotoViewController
@synthesize photo = _photo;
@synthesize existingDogEar = _existingDogEar;
- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

// JT-TODO: get rid of toolBarType - using "initWithImage: andDogEar:(DogEar*)dogEar"

- (id) initWithImage:(UIImage*)image toolBarType:(BKToolBarType)toolBarType
{
    self = [self init];
    if (self)
    {
        self.bkToolBarType = toolBarType;
        self.photo = image;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (id) initWithImage:(UIImage*)image andExistingDogEar:(DogEarObject*)object
{
    self = [self init];
    if (self)
    {
        self.existingDogEar = object;
        self.photo = image;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.existingDogEar) keyString = self.existingDogEar.category;
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    
    // JT:ScrollView Setup
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.delegate = self;
	imageView = [[UIImageView alloc] initWithImage:self.photo];
	scrollView.contentSize = imageView.frame.size;
	[scrollView addSubview:imageView];
	scrollView.minimumZoomScale = scrollView.frame.size.width / imageView.frame.size.width;
	scrollView.maximumZoomScale = 2.0;
    
	[scrollView setZoomScale:scrollView.minimumZoomScale];
	[self.view addSubview:scrollView];
	[self.view sendSubviewToBack:scrollView];
    scrollView.frame = CGRectOffset(imageView.frame, 0.0f, - 68.0f);
    
//    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
//    imageView.tag = 222;
//    imageView.contentMode = UIViewContentModeScaleAspectFit;
//    [self.view addSubview:imageView];
    
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
        
        UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithTitle:@"Rotate" style:UIBarButtonItemStyleBordered target:self action:@selector(rotateLeft)];
//        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:@"Enhance" style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance)];
        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"Ehance:%@",isAutoEnhance?@"YES":@"NO"] style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance:)];

        UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(storeTheImage)];
        self.navigationItem.rightBarButtonItem = saveItem;
        
    }
    else 
    {
        UIBarButtonItem * shareItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareThePhoto)];
        de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
        
        UIBarButtonItem * cameraItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-camera"] style:UIBarButtonItemStyleDone target:tbc action:@selector(activateCamera)];
        
        UIBarButtonItem * trashItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteThePhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:shareItem, spaceItme, cameraItem, spaceItme, trashItem, nil]];
        
//        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
//        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * detailItem = [[UIBarButtonItem alloc]initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
        self.navigationItem.rightBarButtonItem = detailItem;
        self.navigationItem.title = self.existingDogEar.title;
    }
    [self.view addSubview:toolBar];

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

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc makeTabBarHidden:NO];
    
//    self.existingDogEar = nil;
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
//    UIImageView * imageView = (UIImageView*)[self.view viewWithTag:222];
//    imageView.image = self.photo;
//    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
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


- (void) storeTheImage
{
    
    CGSize size = imageView.frame.size;
    if (isAutoEnhance) self.photo = [self.photo autoEnhance];
    
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped andImage:[self.photo scaleToFitSize:size]];
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

#pragma mark - UIBarButtonItem (UIToolBar)

- (void) rotateLeft
{
    currentAngle = currentAngle - 90.0f;
    if (currentAngle == -360) currentAngle = 0.0;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( currentAngle / 180.0 * 3.14 );
	[scrollView setTransform:rotate];
    NSLog(@"%i",currentAngle);

    UIImage * newImage ;
    if (currentAngle == -90)
        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationLeft];
    else if (currentAngle == -180)
        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationDown];
    else if (currentAngle == -270)
        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationRight];
    else
        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationUp];
    self.photo = newImage;
}

- (void) autoEnhance:(id)sender
{
    UIBarButtonItem * button = (UIBarButtonItem*)sender;
    if (isAutoEnhance == NO)
    {
        UIImage * originImage = imageView.image;
        [imageView setImage:[originImage autoEnhance]];
        isAutoEnhance = YES;
    }
    else
    {
        [imageView setImage:self.photo];
        isAutoEnhance = NO;
    }
    [imageView setNeedsDisplay];
    button.title = [NSString stringWithFormat:@"Enhance:%@",isAutoEnhance?@"YES":@"NO"];

}

- (void) shareThePhoto
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"Email",@"Message",@"Print", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

- (void) retakePhoto
{
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc activateCamera];
}


- (void) deleteThePhoto
{
    
    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Dog Ear" message:@"Are you sure delete this dog ear" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Move To Trash", nil];
    [alertView show];
    
    
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
            
        }
            break;
        case 1: // Twitter
        {
            TwitterManager * twitter  = [TwitterManager sharedManager];

            if (DEVICE_OS < 6.0)
            {
//                [[twitter tweetTWComposerSheet] addImage:self.photo];
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Twitter_Account"])[self presentViewController:[twitter tweetTWComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                
            }
            else
            {
//                [[twitter tweetSLComposerSheet] addImage:self.photo];
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Twitter_Account"]) [self presentViewController:[twitter tweetSLComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                else
                {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter Authorization" message:@"Dog Ear has been disconnected to Twitter account. Turn on connection in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Setting", nil];
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
            MessageManager * composer = [MessageManager sharedComposer];
            [composer presentShareImageFromDogEar:self.existingDogEar viaMessageComposerFromParentent:self];
 
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
        if ([alertView.title isEqualToString:@""])
            [self.tabBarController setSelectedIndex:2];
        else if ([alertView.title isEqualToString:@"Dog Ear"])
        {
            de_ListTableViewController * vc  = (de_ListTableViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
            
            NSLog(@"%@",vc.collections);
            NSLog(@"%@",self.existingDogEar);


            
            NSMutableArray * temp = [[NSMutableArray alloc]initWithArray:[self decodedCollections]];
            
            for (int d = 0; d < [temp count]; d++)
            {
                DogEarObject * object = [temp objectAtIndex:d];
                if ([object.title isEqualToString:self.existingDogEar.title] && [object.insertedDate isEqualToDate:self.existingDogEar.insertedDate])
                    [temp removeObject:object];
            }
            
            [self updateDogEarDataCollectionWithSelectedCollections:temp];
            
            [vc.collections removeObject:self.existingDogEar];
            
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
}

@end
