//
//  de_DefaultViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DefaultViewController.h"
#import "de_MainTabBarController.h"

@interface de_DefaultViewController ()

- (void) displayScreen;
- (void) removeScreen;

@end

@implementation de_DefaultViewController

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
	[self displayScreen];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - SplashScreen / Welcome Screen

-(void) displayScreen
{
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dogear-bg-splash"]];
    [self performSelector:@selector(removeScreen) withObject:nil afterDelay:3.0];
}

-(void)removeScreen
{
    //    [self.view removeFromSuperview];
    de_MainTabBarController * bkTabBarVC = [[de_MainTabBarController alloc]init];
    [self presentViewController:bkTabBarVC animated:NO completion:^{
        
    }];
}

@end
