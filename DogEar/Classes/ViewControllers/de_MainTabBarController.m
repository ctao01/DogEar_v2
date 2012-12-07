//
//  de_MainTabBarController.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_MainTabBarController.h"

#import "de_BrowseTableViewController.h"
#import "de_SettingViewController.h"
#import "de_PhotoViewController.h"
#import "UIImage+DGStyle.h"

@interface de_MainTabBarController ()

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
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:62.0f/255.0f green:153.0f/255.0f blue:166.0f/255.0f alpha:0.3]];
    
    de_BrowseTableViewController * vcBrowse = [[de_BrowseTableViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vcBrowse.title = @"Browse";
    
    UINavigationController * ncBrowse = [[UINavigationController alloc]initWithRootViewController:vcBrowse];
    UITabBarItem * browseBtn = [[UITabBarItem alloc]initWithTitle:@"Browse" image:[UIImage imageNamed:@"dogear-icon-browse"] tag:0];
    [ncBrowse setTabBarItem:browseBtn];
    
    UINavigationController * ncDECamera = [[UINavigationController alloc]init];
    UITabBarItem * DECameraBtn = [[UITabBarItem alloc]initWithTitle:@"Camera" image:[UIImage imageNamed:@"dogear-icon-camera"] tag:1];
    ncDECamera.view.backgroundColor = [UIColor blackColor];
    [ncDECamera setTabBarItem:DECameraBtn];
    
    
    // Setup Setting View
    de_SettingViewController * vcSettings = [[de_SettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
    vcSettings.title = @"Settings";
    
    UINavigationController * ncSettings = [[UINavigationController alloc]initWithRootViewController:vcSettings];
    
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

#pragma mark -

- (void) activateCamera
{
    self.selectedIndex = 1;
    UIImagePickerController * imagePickerController = [[UIImagePickerController alloc]init];
    imagePickerController.delegate = self;
    imagePickerController.allowsEditing = NO;
    
    imagePickerController.sourceType =  UIImagePickerControllerSourceTypeCamera;
    imagePickerController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:imagePickerController animated:YES completion:^{
    }];
    
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
    button.enabled = hide ? NO:YES;
    
}

#pragma mark - UITabBarControllerDelegate

- (BOOL) tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    if (self.selectedIndex == 0)
    {
        de_BrowseTableViewController * vc1 = (de_BrowseTableViewController*)[[[self.viewControllers objectAtIndex:self.selectedIndex] viewControllers] objectAtIndex:0];
        [vc1 viewWillAppear:YES];
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
        
        UINavigationController * nc = [self.viewControllers objectAtIndex:1];
//        de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:originImage toolBarType:BKToolBarTypeEditing];
        de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:[UIImage rotateImage:originImage] andExistingDogEar:nil];
        [nc pushViewController:vc animated:YES];
        
    }];
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        self.selectedIndex = 0;
        
    }];
    
}

@end
