//
//  BKCategoryViewController.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/19/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_ListTableViewController.h"
#import "de_PhotoViewController.h"

#import "de_BrowseTableViewController.h"
#import "de_FlaggedListViewController.h"

#import "de_CustomTableViewCell.h"
#import "de_NavigationBar.h"

#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface de_ListTableViewController ()

- (void) refreshDogEarDataAccrodingToCategory;
- (void) refreshDogEarDataAccrodingToFlagged;

@property (nonatomic , retain) UISegmentedControl * segmentControl;
@end

@implementation de_ListTableViewController
@synthesize collections;
@synthesize segmentControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-content-master"]];
    self.tableView.backgroundView = bgImage;
    
    self.segmentControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Most Recent", @"Most Important", nil]];
    segmentControl.frame = CGRectMake(0.0f, 5.0f, 200.0f, 30.0f);
    segmentControl.center = CGPointMake(self.view.center.x, segmentControl.center.y);
    [segmentControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    segmentControl.tintColor = [UIColor colorWithRed:62.0f/255.0f green:153.0f/255.0f blue:166.0f/255.0f alpha:1.0];
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [view addSubview:segmentControl];
    
    UIViewController * vc = (UIViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    if ([vc isMemberOfClass:[de_BrowseTableViewController class]]){
       
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:@"Rename" style:UIBarButtonItemStyleBordered target:self action:@selector(editCategories)];
        self.tableView.tableHeaderView = view;
    }
    else if ([vc isMemberOfClass:[de_FlaggedListViewController class]]) self.tableView.tableHeaderView = nil;
    self.tableView.showsHorizontalScrollIndicator = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 44.0f, 0.0f);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);
    
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] cleanDisk];
    [[SDImageCache sharedImageCache] clearMemory];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    UIViewController * vc = [self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    if ([vc class] == [de_FlaggedListViewController class])
        [self refreshDogEarDataAccrodingToFlagged];
    else if ([vc class] == [de_BrowseTableViewController class])
        [self refreshDogEarDataAccrodingToCategory];

    
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[self.segmentControl selectedSegmentIndex]==0 ? @"insertedDate":@"flagged" ascending:FALSE];
    [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) editCategories
{
    UIAlertView * newCategoryView = [[UIAlertView alloc]initWithTitle:@"Category Name" message:@"Change Category Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Done", nil];
    newCategoryView.alertViewStyle = UIAlertViewStylePlainTextInput;
    [newCategoryView show];
    
}

#pragma mark - Cacnel Notification

- (void) cancelExistingNotificationWithObject:(DogEarObject*)object
{
    NSArray *localNotifications = [[UIApplication sharedApplication] scheduledLocalNotifications];
    for (UILocalNotification *notification in localNotifications)
    {
        NSDictionary * dict = notification.userInfo;
        if (dict)
        {
            NSDate * insertedDate = [dict objectForKey:@"DogEarObjectInsertedDate"];
            if ([insertedDate isEqualToDate:object.insertedDate])
                [[UIApplication sharedApplication] cancelLocalNotification:notification];
        }
    }
}

#pragma mark - Refresh Current Items

- (void) refreshDogEarDataAccrodingToCategory
{
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:self.navigationItem.title];
    
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
    self.collections = decodedCollections;
}

- (void) refreshDogEarDataAccrodingToFlagged
{
    NSArray * flaggedItems = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"BKFlaggedItems"]];
    NSMutableArray * flaggedCollections = [[NSMutableArray alloc]initWithArray:[self refreshAllFlaggedItems]];
    NSMutableArray * temp = [[NSMutableArray alloc]init];
    for (DogEarObject * object in [flaggedCollections copy])
    {
        if ((object.flagged != nil) && (object.flagged == [NSNumber numberWithInteger:[flaggedItems indexOfObject:self.navigationItem.title]]))
        {
            [temp addObject:object];
        }
    }
    NSLog(@"%i",[temp count]);
    self.collections = temp;
    
}

- (NSMutableArray *) refreshAllFlaggedItems
{
    NSMutableArray * flaggedCollections = [[NSMutableArray alloc]init];
    NSArray * categories = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];
    
    for (int c = 0; c < [categories count]; c++)
    {
        NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:[categories objectAtIndex:c]];
        NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        NSArray * copyCollections = [[NSArray arrayWithArray:decodedCollections] copy];
        
        for (DogEarObject * object in copyCollections)
        {
            if (object.flagged != nil)  [flaggedCollections addObject:object];
        }
    }
    return flaggedCollections;
}


#pragma mark - Private Getter / Setter

- (NSMutableArray*) decodedCollectionsWithCategory:(NSString*)category
{
    
    NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:category];
    NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
    
    return decodedCollections;
}

- (void) updateDogEarDataCollectionWithSelectedCollections:(NSMutableArray*)array withCategory:(NSString*)category
{
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:array];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    [dict setObject:encodedObjects forKey:category];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSLog(@"updateDogEarDataCollectionWithSelectedCollections");
}

#pragma mark - UISegmentControl Action Method

- (void)didChangeSegmentControl:(UISegmentedControl *)control
{
    switch (control.selectedSegmentIndex) {
        case 0:
        {
            //JT- TODO: Array Sort By Date
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertedDate" ascending:FALSE];
            [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
            break;
        case 1:
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"flagged" ascending:FALSE];
            [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        }
            break;
            
        default:
            break;
    }
    [self.tableView reloadData];
}

#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex)
    {
        NSString * newName = [[alertView textFieldAtIndex:0] text];
        NSMutableArray * categories = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];
        
        [categories insertObject:newName atIndex:[categories count]];
        
        NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:self.navigationItem.title];
         NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
        [dict setObject:data forKey:newName];
        
        [categories removeObject:self.navigationItem.title];
        
        [[NSUserDefaults standardUserDefaults]setObject:categories forKey:@"BKCategory"];
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"BKDataCollections"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.navigationItem.title = newName;
        [self refreshDogEarDataAccrodingToCategory];
        [self.tableView reloadData];
    }
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.collections) return 1;
    else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.collections) return [self.collections count];
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"CustomCell";
    de_CustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[de_CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    DogEarObject * dogEar = (DogEarObject*)[self.collections objectAtIndex:indexPath.row];
    cell.deTitleLabel.text = dogEar.title;
    cell.deSubtitleLabel.text =[ NSString mediumStyleDateAndShortStyleTimeWithDate:dogEar.insertedDate];
    if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
    {
        [cell.dePhotoImageView setImageWithURL:[NSURL fileURLWithPath:dogEar.imagePath]
                       placeholderImage:[UIImage imageNamed:@"dogear-default"]];
    }
    else {
        [cell.dePhotoImageView setImageWithURL:[NSURL fileURLWithPath:dogEar.imagePath]
                       placeholderImage:[UIImage imageNamed:@"dogear-default"]
                                options:SDWebImageLazyLoad];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - Table View Delegate Method

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    DogEarObject * selectedDogEar = (DogEarObject*)[self.collections objectAtIndex:indexPath.row];
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:selectedDogEar.imagePath]];
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:image andExistingDogEar:selectedDogEar];
    [self.navigationController pushViewController:vc animated:YES];
   
}

 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    DogEarObject * selectedDogEar = (DogEarObject*)[self.collections objectAtIndex:indexPath.row];

    NSMutableArray * decodedObjects = [[NSMutableArray alloc]initWithArray:[self decodedCollectionsWithCategory:selectedDogEar.category]];

    for (int d = 0; d < [decodedObjects count]; d++)
    {
        DogEarObject * object = [decodedObjects objectAtIndex:d];
        if ([object.title isEqualToString:selectedDogEar.title] && [object.insertedDate isEqualToDate:selectedDogEar.insertedDate])
        {
            [self cancelExistingNotificationWithObject:object];
            [decodedObjects removeObject:object];
        }
    }
    NSLog(@"category:%i",[decodedObjects count]);

    
//    [decodedObjects removeObject:selectedDogEar];

    [self updateDogEarDataCollectionWithSelectedCollections:decodedObjects withCategory:selectedDogEar.category];

    [self.collections removeObjectAtIndex:indexPath.row];
    NSArray * array = [NSArray arrayWithObjects:indexPath, nil];
    [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView reloadData];

}


#pragma mark -
#pragma mark Table cell image support


// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.collections count] > 0)
    {
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            de_CustomTableViewCell *cell = (de_CustomTableViewCell*) [[self tableView] cellForRowAtIndexPath:indexPath];
            [cell.dePhotoImageView startDownloadWithOptions:SDWebImageLazyLoad];
            
        }
    }
}

#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}

@end
