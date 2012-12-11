//
//  de_DefaultViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DefaultViewController.h"
#import "de_MainTabBarController.h"
#import "de_PhotoViewController.h"

@interface de_DefaultViewController ()

- (void) displayScreen;
- (void) removeScreen;

@property (nonatomic , strong) de_MainTabBarController * bkTabBarVC;

@end

@implementation de_DefaultViewController
@synthesize bkTabBarVC;

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

#pragma mark - 

- (NSMutableArray *) allItems
{
    NSMutableArray * collections = [[NSMutableArray alloc]init];
    NSArray *  categories = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];
    
    for (int c = 0; c < [categories count]; c++)
    {
        NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:[categories objectAtIndex:c]];
        NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        NSArray * copyCollections = [[NSArray arrayWithArray:decodedCollections] copy];
        
        for (DogEarObject * object in copyCollections) [collections addObject:object];
    }
    return collections;
}

- (DogEarObject*) getDogEarObjectWithNotification:(UILocalNotification*)aNotification
{
    NSArray * allItems = [[NSArray alloc]initWithArray:[self allItems]];
    NSDate * date = [aNotification.userInfo objectForKey:@"DogEarObjectInsertedDate"];

    DogEarObject * dogEar = [DogEarObject new];
    
    for (int count = 0 ; count < [allItems count]; count++)
    {
        DogEarObject * object = (DogEarObject*)[allItems objectAtIndex:count];
        if ([object.insertedDate isEqualToDate:date])
        {
            
            dogEar = object;
        }
    }
    return dogEar;
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
    self.bkTabBarVC = [[de_MainTabBarController alloc]init];
    [self presentViewController:self.bkTabBarVC animated:NO completion:^{
    }];
}

- (void) showReminderWithLocalNotification:(UILocalNotification *)aNotification
{
    if (!self.bkTabBarVC) return;
    
    DogEarObject * dogEar = (DogEarObject*)[self getDogEarObjectWithNotification:aNotification];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dogEar.imagePath]];
//    if (dogEar.reminderDate != NULL) dogEar.reminderDate = NULL;
//    if (dogEar.repeatingReminder != NULL) dogEar.repeatingReminder = NULL;
    
    UINavigationController * nc = [self.bkTabBarVC.viewControllers objectAtIndex:0];
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:image andExistingDogEar:dogEar];
    [nc pushViewController:vc animated:YES];
    
    [self.bkTabBarVC setSelectedIndex:0];
}

@end
