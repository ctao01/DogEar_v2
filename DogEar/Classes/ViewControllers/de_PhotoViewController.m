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

#define IPHONE_NAVIGATION_BAR_HEIGHT 44
#define IPHONE_TOOL_BAR_HEIGHT 44
#define IPHONE_STATUS_BAR_HEIGHT 20

@interface de_PhotoViewController ()

@property (nonatomic) BKToolBarType bkToolBarType;

@end

@implementation de_PhotoViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id) initWithImage:(UIImage*)image toolBarType:(BKToolBarType)toolBarType
{
    self = [self init];
    if (self)
    {
        self.bkToolBarType = toolBarType;
        
        self.view.backgroundColor = [UIColor blackColor];
        
        CGRect bounds = [[UIScreen mainScreen]bounds];
        
        UIImageView * imageView = [[UIImageView alloc]initWithImage:image];
        imageView.tag = 222;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = self.view.frame;
        [self.view addSubview:imageView];
        
        NSInteger cameraActiveBarHeight;
        cameraActiveBarHeight = 68.0f;
        //        if (bounds.size.height == 568.0f) cameraActiveBarHeight = 68.0f;
        //        else cameraActiveBarHeight = 50.0f;
        
        imageView.frame = CGRectOffset(imageView.frame, 0.0f, - cameraActiveBarHeight);
        
        UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, bounds.size.height - cameraActiveBarHeight - IPHONE_TOOL_BAR_HEIGHT, bounds.size.width, IPHONE_TOOL_BAR_HEIGHT)];
        toolBar.tag = 333;
        toolBar.barStyle = UIBarStyleBlackOpaque;
        UIBarButtonItem * spaceItme = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        if (toolBarType == BKToolBarTypeEditing)
        {
            UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithTitle:@"Rotate" style:UIBarButtonItemStylePlain target:self action:@selector(rotatePhoto)];
            UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:@"Enhance" style:UIBarButtonItemStylePlain target:self action:@selector(enhancePhoto)];
            UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStylePlain target:self action:@selector(cropPhoto)];
            
            [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
        }
        
        else if (toolBarType == BKToolBarTypeViewing)
        {
            UIBarButtonItem * shareItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareThePhoto)];
            de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
            
            UIBarButtonItem * cameraItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-camera"] style:UIBarButtonItemStyleDone target:tbc action:@selector(activateCamera)];
            
            UIBarButtonItem * trashItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteThePhoto)];
            
            [toolBar setItems:[NSArray arrayWithObjects:shareItem, spaceItme, cameraItem, spaceItme, trashItem, nil]];
        }
        
        [self.view addSubview:toolBar];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	if (self.bkToolBarType == BKToolBarTypeEditing)
    {
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(storeTheImage)];
        self.navigationItem.rightBarButtonItem = saveItem;
    }
    else if (self.bkToolBarType == BKToolBarTypeViewing)
    {
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * detailItem = [[UIBarButtonItem alloc]initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
        self.navigationItem.rightBarButtonItem = detailItem;
    }
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
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) retakePhoto
{
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc activateCamera];
}

- (void) storeTheImage
{
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [vc setAction:DogEarActionEditing];
    [self.navigationController pushViewController:vc animated:YES];
    
}

- (void) cancel
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) moreDetail
{
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped];
    [vc setAction:DogEarActionViewing];
    [self.navigationController pushViewController:vc animated:YES];

}

#pragma mark - UIBarButtonItem (UIToolBar)
- (void) shareThePhoto
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc]initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Facebook",@"Twitter",@"Email",@"Message",@"Print", nil];
    actionSheet.delegate = self;
    [actionSheet showInView:self.view];
}

@end
