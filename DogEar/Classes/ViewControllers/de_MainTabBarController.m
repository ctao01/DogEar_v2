//
//  de_MainTabBarController.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_MainTabBarController.h"

#import "de_MainNavigationController.h"

#import "de_BrowseTableViewController.h"
#import "de_SettingViewController.h"
#import "de_PhotoViewController.h"

#import "UIImage+DGStyle.h"

#import <QuartzCore/QuartzCore.h>

@interface de_MainTabBarController ()
{
    UIImagePickerController * imagePickerController;
}
@end

@implementation de_MainTabBarController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	self.delegate = self;
    
    
    
    de_BrowseTableViewController * vcBrowse = [[de_BrowseTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vcBrowse.title = @"Browse";
    
    de_MainNavigationController * ncBrowse = [[de_MainNavigationController alloc]initWithRootViewController:vcBrowse];
    UITabBarItem * browseBtn = [[UITabBarItem alloc]initWithTitle:@"Browse" image:[UIImage imageNamed:@"dogear-icon-browse"] tag:0];
    [ncBrowse setTabBarItem:browseBtn];
    
    UINavigationController * ncDECamera = [[UINavigationController alloc]init];
    UITabBarItem * DECameraBtn = [[UITabBarItem alloc]initWithTitle:@"Camera" image:[UIImage imageNamed:@"dogear-icon-camera"] tag:1];
    ncDECamera.view.backgroundColor = [UIColor blackColor];
    [ncDECamera setTabBarItem:DECameraBtn];
    
    
    // Setup Setting View
    de_SettingViewController * vcSettings = [[de_SettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vcSettings.title = @"Settings";
    
    de_MainNavigationController * ncSettings = [[de_MainNavigationController alloc]initWithRootViewController:vcSettings];
    UITabBarItem * settingsBtn = [[UITabBarItem alloc]initWithTitle:@"Settings" image:[UIImage imageNamed:@"dogear-icon-settings"] tag:2];
    [ncSettings setTabBarItem:settingsBtn];
    
    self.viewControllers = [NSArray arrayWithObjects: ncBrowse , ncDECamera, ncSettings, nil];
    
    self.selectedIndex = 0;
    CGSize size = [DECameraBtn.image size];
    [self addCenterButtonWithFrame:CGRectMake(0.0, 0.0,size.width, size.height)];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Tab bar Button

-(void) addCenterButtonWithFrame:(CGRect)frame
{
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.tag = 3059;
    button.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    CGFloat width = self.tabBar.frame.size.width / 3;
    button.frame = CGRectMake(0.0f, 0.0f, width, frame.size.height);
    [button addTarget:self action:@selector(activateCamera) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat heightDifference = frame.size.height - self.tabBar.frame.size.height;
    if (heightDifference < 0)
        button.center = self.tabBar.center;
    else
    {
        CGPoint center = self.tabBar.center;
        center.y = center.y - heightDifference/2.0;
        button.center = center;
    }
    
    [self.view addSubview:button];
}

#pragma mark - UINavigationController Delegate
//
//- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
//{
//    [self addSomeElements:viewController];
//}


#pragma mark -

- (void) activateCamera
{
    [self setSelectedIndex:1];

    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;    
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePickerController.showsCameraControls = NO;
    
    UIToolbar * toolBar=[[UIToolbar alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height -55, 320, 55)];
    toolBar.barStyle =  UIBarStyleBlackOpaque;
    NSArray *items=[NSArray arrayWithObjects:
                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dogear-icon-load"] style:UIBarButtonItemStylePlain target:self action:@selector(loadImageFromLibrary)],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCamera  target:self action:@selector(shootPicture)],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace  target:nil action:nil],
                    [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"dogear-icon-cancel"] style:UIBarButtonItemStylePlain target:self action:@selector(dismissImagePicker)],
                    nil];
    [toolBar setItems:items];
    
    [self presentViewController:imagePickerController animated:YES completion:^{
        [imagePickerController.view addSubview:toolBar];

    }];
//    de_MainNavigationController * nc = (de_MainNavigationController*)[self.viewControllers objectAtIndex:1];
//    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:[UIImage imageNamed:@"sample"] andExistingDogEar:nil];
//    [nc pushViewController:vc animated:YES];
}

-(void) shootPicture {
    
    [imagePickerController takePicture];
}

-(void)makeTabBarHidden:(BOOL)hide
{
    // Custom code to hide TabBar
    UIView *contentView;
    if ( [[self.view.subviews objectAtIndex:0] isKindOfClass:[UITabBar class]] )
        contentView = [self.view.subviews objectAtIndex:1];
    else
        contentView = [self.view.subviews objectAtIndex:0];
    
    if (hide)
        contentView.frame = self.view.bounds;

    self.tabBar.hidden = hide;
    UIButton * button = (UIButton*)[self.view viewWithTag:3059];
    if (button) button.enabled = !hide;

    
}

#pragma mark - UITabBarControllerDelegate

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (self.selectedIndex == 0)
    {
        de_BrowseTableViewController * vc1 = (de_BrowseTableViewController*)[[[self.viewControllers objectAtIndex:self.selectedIndex] viewControllers] objectAtIndex:0];
        if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
        {
            //JT-Notes: Has Launch App - Read Category Array
            UIImageView *image = (UIImageView *)[vc1.view viewWithTag:999];
            if (image) [image removeFromSuperview];
            vc1.tableView.scrollEnabled = YES;
        }
    }
    
    return YES;
}

- (void) tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
	
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        [(UINavigationController*) viewController popToRootViewControllerAnimated:NO];
    }
    if (self.selectedIndex != 1)
    {
        NSMutableArray * array = [NSMutableArray arrayWithArray:[(UINavigationController*)viewController viewControllers]];
        [array removeAllObjects];
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage * originImage = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
    [self dismissViewControllerAnimated:YES completion:^{

    }];
    
    de_MainNavigationController * nc = (de_MainNavigationController*)[self.viewControllers objectAtIndex:1];
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:originImage andExistingDogEar:nil];
    [nc pushViewController:vc animated:YES];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedIndex = 0;
        [self makeTabBarHidden:NO];
    }];
    
}
/*
#pragma mark - Custom UIImagePicker 
-(UIView *)findView:(UIView *)aView withName:(NSString *)name
{
    Class cl = [aView class];
    NSString *desc = [cl description];
    
    if ([name isEqualToString:desc])
        return aView;
    
    for (NSUInteger i = 0; i < [aView.subviews count]; i++)
    {
        UIView *subView = [aView.subviews objectAtIndex:i];
        subView = [self findView:subView withName:name];
        if (subView)
            return subView;
    }
    return nil;
}

- (void)addSomeElements:(UIViewController *)viewController
{
    NSLog(@"addSomeElements");
    
    UIView *PLCameraView=[self findView:viewController.view withName:@"PLCameraView"];

    UIView * bottomBar=[self findView:PLCameraView withName:@"PLCropOverlayBottomBar"];
    UIImageView *bottomBarImageForSave = [bottomBar.subviews objectAtIndex:1];
    NSLog(@"%@",bottomBarImageForSave.subviews);
    
    UIButton *cameraButton=[bottomBarImageForSave.subviews objectAtIndex:0];
//    [cameraButton addTarget:self action:@selector(imagePickerController:didFinishPickingMediaWithInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *cacnelBtn =[bottomBarImageForSave.subviews objectAtIndex:1];
//    [loadButton setTitle:@"Load" forState:UIControlStateNormal];  //右下角按钮
    UIButton * loadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [loadButton setFrame:cacnelBtn.frame];
    [loadButton setImage:[UIImage imageNamed:@"dogear-icon-load"] forState:UIControlStateNormal];
    [loadButton addTarget:self action:@selector(loadImageFromLibrary) forControlEvents:UIControlEventTouchUpInside];
    
    [cacnelBtn removeFromSuperview];
    [bottomBarImageForSave addSubview:loadButton];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
//    [button setTitle:@"Cancel" forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:@"dogear-icon-cancel"] forState:UIControlStateNormal];
    [button setFrame:loadButton.frame];
    [button setCenter:CGPointMake(cameraButton.center.x + (cameraButton.center.x - loadButton.center.x), button.center.y)];
    [button addTarget:self action:@selector(dismissImagePicker) forControlEvents:UIControlEventTouchUpInside];

    [bottomBarImageForSave addSubview:button];
}
*/
- (void) loadImageFromLibrary
{
    [self dismissModalViewControllerAnimated:NO];
    
    imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
}

- (void) dismissImagePicker
{
    NSLog(@"dismissImagePicker");
    self.selectedIndex = 0;

    [self dismissModalViewControllerAnimated:YES];
}

@end
