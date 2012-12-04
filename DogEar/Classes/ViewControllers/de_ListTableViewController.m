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
#import "UIImageView+WebCache.h"
#import "SDImageCache.h"

@interface de_ListTableViewController ()

@end

@implementation de_ListTableViewController
@synthesize collections;

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
//    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-master"]];
//    self.tableView.backgroundView = bgImage;
    
    UISegmentedControl * segmentControl = [[UISegmentedControl alloc]initWithItems:[NSArray arrayWithObjects:@"Most Recent", @"Most Important", nil]];
    segmentControl.frame = CGRectMake(0.0f, 5.0f, 200.0f, 30.0f);
    segmentControl.center = CGPointMake(self.view.center.x, segmentControl.center.y);
    [segmentControl addTarget:self action:@selector(didChangeSegmentControl:) forControlEvents:UIControlEventValueChanged];
    segmentControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentControl.selectedSegmentIndex = 0;
    
    UIView * view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    [view addSubview:segmentControl];
    
    UIViewController * vc = (UIViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    if ([vc isMemberOfClass:[de_BrowseTableViewController class]])self.tableView.tableHeaderView = view;
    else if ([vc isMemberOfClass:[de_FlaggedListViewController class]]) self.tableView.tableHeaderView = nil;
    self.tableView.showsHorizontalScrollIndicator = YES;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 44.0f, 0.0f);
    
    [[SDImageCache sharedImageCache] clearMemory];
    [[SDImageCache sharedImageCache] clearDisk];
    [[SDImageCache sharedImageCache] cleanDisk];
}


- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"insertedDate" ascending:FALSE];
    [self.collections sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    [self.tableView reloadData];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    /*static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    DogEarObject * dogEar = (DogEarObject*)[self.collections objectAtIndex:indexPath.row];
    cell.textLabel.text = dogEar.title;
    cell.detailTextLabel.text = [NSString mediumStyleDateAndShortStyleTimeWithDate:dogEar.insertedDate];
    
    UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:dogEar.imagePath]];
    UIImage * orienteImg = [[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:[dogEar.imageOrientation integerValue]];
    cell.imageView.image = orienteImg;*/
    
    static NSString * CellIdentifier = @"CustomCell";
    de_CustomTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[de_CustomTableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    DogEarObject * dogEar = (DogEarObject*)[self.collections objectAtIndex:indexPath.row];
    cell.deTitleLabel.text = dogEar.title;
    cell.deSubtitleLabel.text =[ NSString mediumStyleDateAndShortStyleTimeWithDate:dogEar.insertedDate];
    NSLog(@"%@",dogEar.imagePath);
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
    de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:[[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:[selectedDogEar.imageOrientation integerValue] ] andExistingDogEar:selectedDogEar];
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
        [self.collections removeObjectAtIndex:indexPath.row];
        NSArray * array = [NSArray arrayWithObjects:indexPath, nil];
        [self.tableView deleteRowsAtIndexPaths:array withRowAnimation:UITableViewRowAnimationFade];
}

- (void)tableView:(UITableView *)tableView didEndEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    [self.tableView reloadData];
    NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:self.collections];
    NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
    
    [dict setObject:encodedObjects forKey:self.navigationItem.title];
    [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
