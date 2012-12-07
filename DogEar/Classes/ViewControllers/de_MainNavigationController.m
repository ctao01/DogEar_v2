//
//  de_MainNavigationController.m
//  DogEar
//
//  Created by Joy Tao on 12/7/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_MainNavigationController.h"
#import "de_NavigationBar.h"
@interface de_MainNavigationController ()

@end

@implementation de_MainNavigationController



- (id)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    if (self)
    {
        de_NavigationBar * navigationBar = [[de_NavigationBar alloc]init];
        [self setValue:navigationBar forKey:@"navigationBar"];
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:62.0f/255.0f green:153.0f/255.0f blue:166.0f/255.0f alpha:1.0]];

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
