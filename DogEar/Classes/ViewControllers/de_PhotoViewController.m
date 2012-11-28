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
#define IPHONE_TOOL_BAR_HEIGHT 45
#define IPHONE_STATUS_BAR_HEIGHT 20

@interface de_PhotoViewController ()

@property (nonatomic) BKToolBarType bkToolBarType;
@property (nonatomic , retain) UIImage * photo;
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
        self.photo = image;
        self.view.backgroundColor = [UIColor blackColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect bounds = [[UIScreen mainScreen]bounds];
    
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    imageView.tag = 222;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view addSubview:imageView];
    
    NSInteger cameraActiveBarHeight;
    cameraActiveBarHeight = 68.0f;
    
    imageView.frame = CGRectOffset(imageView.frame, 0.0f, - cameraActiveBarHeight);
    
    UIToolbar * toolBar = [[UIToolbar alloc]initWithFrame:CGRectMake(0.0f, bounds.size.height - cameraActiveBarHeight - IPHONE_TOOL_BAR_HEIGHT, bounds.size.width, IPHONE_TOOL_BAR_HEIGHT)];
    toolBar.tag = 333;
    toolBar.barStyle = UIBarStyleBlackOpaque;
    UIBarButtonItem * spaceItme = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
	if (self.bkToolBarType == BKToolBarTypeEditing)
    {
        UIBarButtonItem * rotateItem = [[UIBarButtonItem alloc]initWithTitle:@"Rotate" style:UIBarButtonItemStylePlain target:self action:@selector(rotatePhoto)];
        UIBarButtonItem * enhanceItem = [[UIBarButtonItem alloc]initWithTitle:@"Enhance" style:UIBarButtonItemStylePlain target:self action:@selector(enhancePhoto)];
        UIBarButtonItem * cropItem = [[UIBarButtonItem alloc]initWithTitle:@"Crop" style:UIBarButtonItemStylePlain target:self action:@selector(cropPhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:rotateItem, spaceItme, enhanceItem, spaceItme, cropItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(retakePhoto)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Save" style:UIBarButtonItemStyleBordered target:self action:@selector(storeTheImage)];
        self.navigationItem.rightBarButtonItem = saveItem;
    }
    else if (self.bkToolBarType == BKToolBarTypeViewing)
    {
        UIBarButtonItem * shareItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-share"] style:UIBarButtonItemStylePlain target:self action:@selector(shareThePhoto)];
        de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
        
        UIBarButtonItem * cameraItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-camera"] style:UIBarButtonItemStyleDone target:tbc action:@selector(activateCamera)];
        
        UIBarButtonItem * trashItem = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"dogear-icon-trashcan"] style:UIBarButtonItemStylePlain target:self action:@selector(deleteThePhoto)];
        
        [toolBar setItems:[NSArray arrayWithObjects:shareItem, spaceItme, cameraItem, spaceItme, trashItem, nil]];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        UIBarButtonItem * detailItem = [[UIBarButtonItem alloc]initWithTitle:@"Detail" style:UIBarButtonItemStyleBordered target:self action:@selector(moreDetail)];
        self.navigationItem.rightBarButtonItem = detailItem;
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
}

- (void) viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    UIImageView * imageView = (UIImageView*)[self.view viewWithTag:222];
    imageView.image = self.photo;
    imageView.frame = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height);
    
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) retakePhoto
{
    de_MainTabBarController * tbc = (de_MainTabBarController*)self.tabBarController;
    [tbc activateCamera];
}

- (void) storeTheImage
{
    de_DetailViewController * vc = [[de_DetailViewController alloc]initWithStyle:UITableViewStyleGrouped andImage:self.photo];
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
