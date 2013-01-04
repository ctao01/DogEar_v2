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

int currentAngle = 0;


@interface de_PhotoViewController ()
{
    UIPrintInteractionController *printController;
    NSString * keyString;
    
    // Zoom
    UIScrollView * scrollView;
    UIImageView * imageView;
    
    // Auto Enhance Image
    BOOL isAutoEnhance;
    
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
        self.photo = [UIImage rotateImage:image];
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.existingDogEar) keyString = self.existingDogEar.category;
    
    
    // JT:ScrollView Setup
    scrollView = [[UIScrollView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    scrollView.delegate = self;
	scrollView.backgroundColor = [UIColor blackColor];
	scrollView.delegate = self;
	imageView = [[UIImageView alloc] initWithImage:self.photo];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
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
        
        UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithTitle:@"Rotate" style:UIBarButtonItemStyleBordered target:self action:@selector(rotateLeft)];
        //        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:@"Enhance" style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance)];
        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:[NSString stringWithFormat:@"Ehance:%@",isAutoEnhance?@"YES":@"NO"] style:UIBarButtonItemStyleBordered target:self action:@selector(autoEnhance:)];
        
        UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStyleBordered target:self action:@selector(cropPhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
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
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backToList)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * detailItem = [[UIBarButtonItem alloc]initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
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
    
//    CGSize size = imageView.frame.size;
    if (isAutoEnhance) self.photo = [self.photo autoEnhance];
    
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped andImage:self.photo];
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
//    if ([self.navigationController.viewControllers count]>3)
//    {
        de_ListTableViewController * vc = (de_ListTableViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
        de_ListTableViewController * previousVc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-3];
        NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKFlaggedItems"];
        if ([previousVc isKindOfClass:[de_BrowseTableViewController class]])
            vc.navigationItem.title = self.existingDogEar.category;
        else if ([previousVc isKindOfClass:[de_FlaggedListViewController class]])
            vc.navigationItem.title = [array objectAtIndex:[self.existingDogEar.flagged integerValue]];
        [self.navigationController popToViewController:vc animated:YES];
//    }
//    else [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark - UIBarButtonItem (UIToolBar)

- (void) rotateLeft
{
    currentAngle = currentAngle - 90.0f;
    if (currentAngle == -360) currentAngle = 0.0;
    CGAffineTransform rotate = CGAffineTransformMakeRotation( currentAngle / 180.0 * 3.14 );
	[scrollView setTransform:rotate];
    NSLog(@"%i",currentAngle);

    UIImage * newImage = [self.photo imageRotatedByDegrees:currentAngle];
//    if (currentAngle == -90)
//        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationLeft];
//    else if (currentAngle == -180)
//        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationDown];
//    else if (currentAngle == -270)
//        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationRight];
//    else
//        newImage = [[UIImage alloc] initWithCGImage:self.photo.CGImage scale:1 orientation:UIImageOrientationUp];
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

/******************************************************************************************/
- (void) cropPhoto
{
//    CGRect cropFrame = CGRectMake(40.0f, 40.0f, 240, 320.0f);
//    cropTL_y = cropFrame.origin.y;
//    cropTR_x = cropFrame.origin.x + cropFrame.size.width;
//    cropBR_y = cropFrame.origin.y + cropFrame.size.height;
//    cropBL_x = cropFrame.origin.x;
//    
//    cropView = [[CropView alloc]initWithOuterFrame:self.view.frame andInnerFrame:cropFrame];
//    [self.view addSubview:cropView];
//    [cropView setNeedsDisplay];
//    
//    UIImage * cropPointImg = [UIImage imageNamed:@"cropPoint.png"];
//	ivleftUp = [[UIImageView alloc]initWithImage:cropPointImg];
//	ivRightUp = [[UIImageView alloc]initWithImage:cropPointImg];
//	ivleftDown = [[UIImageView alloc]initWithImage:cropPointImg];
//	ivRightDown = [[UIImageView alloc]initWithImage:cropPointImg];
//	
//	ivleftUp.center = CGPointMake(cropBL_x, cropTL_y);
//	ivleftDown.center = CGPointMake(cropBL_x, cropBR_y);;
//	ivRightUp.center = CGPointMake(cropTR_x, cropTL_y);
//	ivRightDown.center = CGPointMake(cropTR_x, cropBR_y);;
//	
//	[cropView addSubview:ivleftUp];
//	[cropView addSubview:ivleftDown];
//	[cropView addSubview:ivRightUp];
//	[cropView addSubview:ivRightDown];
    
    cropView = [[NLImageCropperView alloc]initWithFrame:self.view.frame];
    [self.view addSubview:cropView];
    [cropView setImage:self.photo];
    [cropView setCropRegionRect:CGRectMake(10, 50, 450, 680)];
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelCrop)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneCrop)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void) doneCrop
{
//    CGRect rect = CGRectMake(cropBL_x, cropTL_y, cropTR_x - cropBL_x, cropBR_y - cropTL_y);
//    CGSize imageViewSize = imageView.frame.size;
    UIImage * image = [cropView getCroppedImage];
//    UIImage * image = [[UIImage alloc]imageByCropping:[self.photo scaleToFitSize:imageViewSize] toRect:rect];
    imageView.image = [image imageRotatedByDegrees:-currentAngle];
    self.photo = image;
    [imageView setNeedsDisplay];

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

//- (void) doneCropPhoto
//{
//    CGRect rect = CGRectMake(cropBL_x, cropTL_y, cropTR_x - cropBL_x, cropBR_y - cropTL_y);
//    CGSize imageViewSize = imageView.frame.size;
//    UIImage * image = [[UIImage alloc]imageByCropping:[self.photo scaleToFitSize:imageViewSize] toRect:rect];
//    
//    self.photo = image;
//    
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(storeTheImage)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
//}
//
//- (void) cancelCropPhoto
//{
//    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleDone target:self action:@selector(storeTheImage)];
//    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Retake" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
//}


//- (void)ControlCropView:(NSSet *)touches {
//	
//    
//    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
//	    
//    if ((fabs(movedPoint.x - cropBL_x)<=ktapDiff)&&(fabs(movedPoint.y -cropTL_y)<= ktapDiff))
//        //    if ((abs(movedPoint.x - cropBL_x)<ktapDiff) && ((cropTL_y -movedPoint.y <= ktapDiff)||(cropTL_y -movedPoint.y <= ktapDiff)))
//    {
//        NSLog(@"Touched upper left corner");
//        isTappedOnUpperLeftCorner = TRUE;
//    }
//    else if((fabs(movedPoint.x - cropTR_x)<=ktapDiff)&&(fabs(movedPoint.y -cropTL_y)<= ktapDiff))
//        //    else if(((movedPoint.x - cropTR_x <= ktapDiff)||(cropTR_x - movedPoint.x <= ktapDiff)) && ((cropTL_y -movedPoint.y <= ktapDiff)||(cropTL_y -movedPoint.y <= ktapDiff)))
//    {
//        NSLog(@"Touched upper Right corner");
//        isTappedOnUpperRightCorner = TRUE;
//    }
//    else if((fabs(movedPoint.x - cropTR_x)<=ktapDiff)&&(fabs(movedPoint.y -cropBR_y)<= ktapDiff))
//        
//        //    else if (((movedPoint.x - cropTR_x <= ktapDiff)||(cropTR_x -movedPoint.x <= ktapDiff)) && ((cropBR_y -movedPoint.y <= ktapDiff)||(cropBR_y -movedPoint.y <= ktapDiff)))
//        
//    {
//        NSLog(@"Touched lower Right corner");
//        isTappedOnLowerRightCorner = TRUE;
//
//    }
//    else if((fabs(movedPoint.x - cropBL_x)<=ktapDiff)&&(fabs(movedPoint.y -cropBR_y)<= ktapDiff))
//        
//        //    else if (((movedPoint.x - cropBL_x <= ktapDiff)||(cropBL_x -movedPoint.x <= ktapDiff)) && ((cropBR_y -movedPoint.y <= ktapDiff)||(cropBR_y -movedPoint.y <= ktapDiff)))
//    {
//        NSLog(@"Touched lower left corner");
//        isTappedOnLowerLeftCorner = TRUE;
//    }
//}
//
//-(void) updateCropPoints
//{
//	ivleftUp.center = CGPointMake(cropBL_x, cropTL_y);
//	ivleftDown.center = CGPointMake(cropBL_x, cropBR_y);;
//	ivRightUp.center = CGPointMake(cropTR_x, cropTL_y);
//	ivRightDown.center = CGPointMake(cropTR_x, cropBR_y);;
//}
//
//#pragma mark -
//#pragma mark UITOUCHES Stuff
//
//- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//	[self ControlCropView:touches];
//}
//- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
//	isTappedOnLowerLeftCorner = FALSE;
//	isTappedOnLowerRightCorner = FALSE;
//	isTappedOnUpperLeftCorner = FALSE;
//	isTappedOnUpperRightCorner = FALSE;
//}
//- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
//    //    messageLabel.text = @"Touches Stopped.";
//	isTappedOnLowerLeftCorner = FALSE;
//	isTappedOnLowerRightCorner = FALSE;
//	isTappedOnUpperLeftCorner = FALSE;
//	isTappedOnUpperRightCorner = FALSE;
//}
//
//- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
//{
//    CGPoint movedPoint = [[touches anyObject] locationInView:self.view];
//    
//    CGRect viewFrame = imageView.frame;
//    
//    if ((movedPoint.x <= 10 && movedPoint.x >= 310))
//		return;
//	if ((movedPoint.y <= 10  && movedPoint.y >= viewFrame.size.height - 10)) {
//		return;
//	}
//    
//    
//    if (isTappedOnUpperLeftCorner)
//    {
//        if (movedPoint.x >= cropView.frame.origin.x + cropView.frame.size.width) return;
//        if (movedPoint.y >= cropView.frame.origin.y + cropView.frame.size.height) return;
//        
//        // TODO: move left
//        
//        if ((cropBL_x - movedPoint.x) >= kWidthDifference)
//        {
//            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
//                cropTL_y = movedPoint.y;
//            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
//                cropTL_y = movedPoint.y;
//            else return;
//            
//            cropBL_x = movedPoint.x;
//            
//        }
//        // TODO: move right
//        else if ((movedPoint.x -cropBL_x) >= kWidthDifference)
//        {
//            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
//                cropTL_y = movedPoint.y;
//            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
//                cropTL_y = movedPoint.y;
//            else return;
//            
//            cropBL_x = movedPoint.x;
//        }
//        else return;
//    }
//    
//    else if (isTappedOnUpperRightCorner)
//    {
//        if (movedPoint.x <= cropView.frame.origin.x) return;
//        if (movedPoint.y >= cropView.frame.origin.y + cropView.frame.size.height) return;
//        
//        if ((cropTR_x - movedPoint.x) >= kWidthDifference)
//        {
//            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
//                cropTL_y = movedPoint.y;
//            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
//                cropTL_y = movedPoint.y;
//            else return;
//            
//            cropTR_x = movedPoint.x;
//            
//        }
//        // TODO: move right
//        else if ((movedPoint.x -cropTR_x) >= kWidthDifference)
//        {
//            if ((cropTL_y - movedPoint.y)>=kHeightDifference) // move up
//                cropTL_y = movedPoint.y;
//            else if ((movedPoint.y -cropTL_y)>= kHeightDifference) // move down
//                cropTL_y = movedPoint.y;
//            else return;
//            
//            cropTR_x = movedPoint.x;
//        }
//        else return;
//    }
//    
//     else if (isTappedOnLowerRightCorner)
//     {
//         if (movedPoint.x <= cropView.frame.origin.x) return;
//         if (movedPoint.y <=cropView.frame.origin.y) return;
//         
//         if ((cropTR_x - movedPoint.x) >= kWidthDifference)
//         {
//             if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
//             cropBR_y = movedPoint.y;
//             else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
//             cropBR_y = movedPoint.y;
//             else return;
//             
//             cropTR_x = movedPoint.x;
//             
//             }
//             // TODO: move right
//             else if ((movedPoint.x -cropTR_x) >= kWidthDifference)
//             {
//             if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
//             cropBR_y = movedPoint.y;
//             else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
//             cropBR_y = movedPoint.y;
//             else return;
//             
//             cropTR_x = movedPoint.x;
//             }
//         else return;
//     }
//     
//     else if (isTappedOnLowerLeftCorner)
//     {
//         if (movedPoint.x >= cropView.frame.origin.x + cropView.frame.size.width) return;
//         if (movedPoint.y <=cropView.frame.origin.y) return;
//
//         
//         if ((cropBL_x - movedPoint.x) >= kWidthDifference)
//         {
//             if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
//             cropBR_y = movedPoint.y;
//             else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
//             cropBR_y = movedPoint.y;
//             else return;
//             
//             cropBL_x = movedPoint.x;
//         
//         }
//         // TODO: move right
//         else if ((movedPoint.x -cropBL_x) >= kWidthDifference)
//         {
//             if ((cropBR_y - movedPoint.y)>=kHeightDifference) // move up
//             cropBR_y = movedPoint.y;
//             else if ((movedPoint.y -cropBR_y)>= kHeightDifference) // move down
//             cropBR_y = movedPoint.y;
//             else return;
//             
//             cropBL_x = movedPoint.x;
//         }
//         else return;
//     }
//    cropView.cropFrame = CGRectMake(cropBL_x, cropTL_y, cropTR_x - cropBL_x, cropBR_y - cropTL_y);
//    [self updateCropPoints];
//    [cropView setNeedsDisplay];
//    
//}
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

#pragma mark - 

- (void) publishDogEar
{
    NSMutableDictionary * params = [[NSMutableDictionary alloc]init];
    UIImage * pngImg = [UIImage imageWithData:[NSData dataWithContentsOfFile:self.existingDogEar.imagePath]];
    
    [params setObject:self.existingDogEar.title forKey:@"message"];
    [params setObject:UIImagePNGRepresentation(pngImg) forKey:@"picture"];
    
    [FBRequestConnection startWithGraphPath:@"me/photos" parameters:params HTTPMethod:@"POST"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error){
                              UIAlertView * alertView;
                            if (error)
                    //            NSLog(@"error");
                                alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Oops, Error !" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                            else
                    //            NSLog(@"successful!!");
                                alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Post Successfully " delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
                              [alertView show];
                            
    }];
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
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Twitter_Account"])[self presentViewController:[twitter tweetTWComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                
            }
            else
            {
                if ([[NSUserDefaults standardUserDefaults] objectForKey:@"Twitter_Account"]) [self presentViewController:[twitter tweetSLComposerSheetWithSharedImage:self.photo] animated:YES completion:nil];
                else
                {
                    UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter Authorization" message:@"DogEar has been disconnected to Twitter account. Turn on connection in Settings" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:@"Setting", nil];
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
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Save To Camera Roll Coming Soon" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
            [alertView show];
//            MessageManager * composer = [MessageManager sharedComposer];
//            [composer presentShareImageFromDogEar:self.existingDogEar viaMessageComposerFromParentent:self];
 
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
                    [temp removeObject:object];
            }
            
            [self updateDogEarDataCollectionWithSelectedCollections:temp];
            
            [vc.collections removeObject:self.existingDogEar];
            
            [self.navigationController popViewControllerAnimated:YES];

        }
    }
}

@end
