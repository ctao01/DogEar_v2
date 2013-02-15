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
#import "AppDelegate.h"

@interface de_DefaultViewController ()
{
    UIActivityIndicatorView *activityIndicator;
}
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
    float height = self.view.frame.size.height;
    NSLog(@"%f",height);
    //    CGRect bgFrame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, height - 20.0f - 44.0f - 49.0f);

//    if (height < 568.0f)
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dogear-bg-splash-new"]];
//    else
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"dogear-bg-splash-568h"]];
    UIImageView *backgroundImage ;
    if (height >= 548.0f)
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-splash-new-568h"]];
    else
        backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-splash-new"]];
    backgroundImage.frame = self.view.bounds;
    [self.view addSubview:backgroundImage];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 44, 44)];
    activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    activityIndicator.center = CGPointMake(self.view.center.x, self.view.center.y + 120.0f);
    [self.view addSubview:activityIndicator];
    [activityIndicator startAnimating];
    
    [self performSelector:@selector(removeScreen) withObject:nil afterDelay:3.0];
}

-(void)removeScreen
{
    //    [self.view removeFromSuperview];
    self.bkTabBarVC = [[de_MainTabBarController alloc]init];
    [self presentViewController:self.bkTabBarVC animated:NO completion:^{
        [activityIndicator stopAnimating];
    }];
}

- (void) showReminderWithLocalNotification:(UILocalNotification *)aNotification
{
    if (!self.bkTabBarVC) return;
    
    if ([UIApplication sharedApplication].applicationIconBadgeNumber>0) 
		[UIApplication sharedApplication].applicationIconBadgeNumber--;
    
    DogEarObject * dogEar = (DogEarObject*)[self getDogEarObjectWithNotification:aNotification];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dogEar.imagePath]];
    
    UINavigationController * nc = [self.bkTabBarVC.viewControllers objectAtIndex:0];
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:image andExistingDogEar:dogEar];
    [nc pushViewController:vc animated:YES];
    
    [self.bkTabBarVC setSelectedIndex:0];
    
    
}

@end
