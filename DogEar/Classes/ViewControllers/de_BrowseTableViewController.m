//
//  de_CategoryTableViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/26/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

/* JT-TODO:
 - UISearchBar
*/

#import "de_BrowseTableViewController.h"
#import "de_ListTableViewController.h"
#import "de_FlaggedListViewController.h"
#import "de_PhotoViewController.h"


@interface de_BrowseTableViewController ()
{
    NSArray * categories;
    
}
@property (nonatomic , strong) NSArray * allItems;
@property (nonatomic , strong) NSArray * searchItems;
@property (nonatomic , strong) UISearchDisplayController * vcSearchDispay;
@end

@implementation de_BrowseTableViewController
@synthesize allItems, searchItems;
@synthesize vcSearchDispay;

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

    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-master"]];
    self.tableView.backgroundView = bgImage;
    
    UISearchBar * searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 44.0f)];
    searchBar.barStyle = UIBarStyleBlackTranslucent;
    searchBar.tintColor = [UIColor colorWithRed:129.0/255.0f green:129.0/255.0f blue:130.0/255.0f alpha:.80];
    searchBar.showsSearchResultsButton = YES;
    self.tableView.tableHeaderView = searchBar;
    
    self.vcSearchDispay = [[UISearchDisplayController alloc]initWithSearchBar:searchBar contentsController:self];
    self.vcSearchDispay.searchResultsDataSource = self;
    self.vcSearchDispay.searchResultsDelegate = self;
    self.vcSearchDispay.delegate = self;
    
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
     self.navigationItem.title = @"Browse Dog Ears";
    
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-instructions"]];
    backgroundImage.tag = 999;
    backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        //JT-Notes: Has Launch App - Read Category Array 
        
        UIImageView *image = (UIImageView *)[self.view viewWithTag:999];
        if (image) [image removeFromSuperview];
        categories = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];
    }
    else
    {
        // JT-Notes: First Time Launch App - Create Category Array and Data Dictionary 
        
        [self.view addSubview:backgroundImage];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        
        NSArray * array = [NSArray arrayWithObjects:@"Articles",@"Magazine",@"Sports",@"Fashion", nil];
        [[NSUserDefaults standardUserDefaults] setObject:array forKey:@"BKCategory"];
        
        NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
        
        for (int count = 0; count < [array count]; count ++)
        {
            NSArray * dataArray = [[NSArray alloc]init];
            NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:dataArray];
            [dict setObject:encodedObjects forKey:[array objectAtIndex:count]];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:dict forKey:@"BKDataCollections"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    [self.tableView reloadData];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    self.navigationItem.title = @"Browse";
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
    
    for (int c = 0; c < [categories count]; c++)
    {
        NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:[categories objectAtIndex:c]];
        NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        NSArray * copyCollections = [[NSArray arrayWithArray:decodedCollections] copy];
        
        for (DogEarObject * object in copyCollections) [collections addObject:object];
    }
    return collections;
}

- (void) filterContentForSearchText:(NSString*)searchText andScope:(NSString*)scope
{
    self.allItems = [[NSArray alloc]initWithArray:[self allItems]];   
    NSPredicate * resultPredict = [NSPredicate predicateWithFormat:@"SELF.title contains[cd] %@",searchText];
    self.searchItems = [self.allItems filteredArrayUsingPredicate:resultPredict];
}

#pragma mark - UISearchDisplay Delegate

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString andScope:nil];
    return YES;
}

- (BOOL) searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    [self filterContentForSearchText:[controller.searchBar text] andScope:nil];
    return YES;
    
}

#pragma mark - Table View Data Source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([tableView isEqual: self.vcSearchDispay.searchResultsTableView])
        return 1;
    else return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual: self.vcSearchDispay.searchResultsTableView])
        return [self.searchItems count];
    
    else
    {
        if (section == 0) return 1;
        else if (section == 1) return [categories count];
        else return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    // Configure the cell...
    if ([tableView isEqual:self.vcSearchDispay.searchResultsTableView])
        cell.textLabel.text = [(DogEarObject*)[self.searchItems objectAtIndex:indexPath.row] title];
    
    else {
        if (indexPath.section == 0) cell.textLabel.text = @"Flagged Dog Ears";
        else if (indexPath.section == 1 )
            cell.textLabel.text = [categories objectAtIndex:indexPath.row];
    }
    return cell;    
}

#pragma mark - Table View Delegate Method

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //JT-TODO: Read Collections of Selected Row
    
    if ([tableView isEqual:self.vcSearchDispay.searchResultsTableView])
    {
        DogEarObject * selectedDogEar = (DogEarObject*)[self.searchItems objectAtIndex:indexPath.row];
        UIImage * image = [UIImage imageWithData:[NSData dataWithContentsOfFile:selectedDogEar.imagePath]];
        de_PhotoViewController * vc = [[de_PhotoViewController alloc]initWithImage:[[UIImage alloc] initWithCGImage:image.CGImage scale:1.0 orientation:[selectedDogEar.imageOrientation integerValue] ] andExistingDogEar:selectedDogEar];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        if (indexPath.section == 0)
        {
//            NSMutableArray * collections = [[NSMutableArray alloc]init];
//            
//            for (int c = 0; c < [categories count]; c++)
//            {
//                NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:[categories objectAtIndex:c]];
//                NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
//                NSArray * copyCollections = [[NSArray arrayWithArray:decodedCollections] copy];
//                
//                for (DogEarObject * object in copyCollections)
//                {
//                    if (object.flagged != nil)  [collections addObject:object];
//                }
//            }
//            NSLog(@"%i",[collections count]);
            
            de_FlaggedListViewController * vc = [[de_FlaggedListViewController alloc]initWithStyle:UITableViewStyleGrouped];
//            vc.flaggedCollections = collections;
            [self.navigationController pushViewController:vc animated:YES];

        }
        else if (indexPath.section == 1)
        {
//            NSString * keyString = [categories objectAtIndex:indexPath.row];
//            NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:keyString];
//            NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
//
            de_ListTableViewController * vc = [[de_ListTableViewController alloc]init];

            [self.navigationController pushViewController:vc animated:YES];

//            vc.navigationItem.title = [NSString stringWithFormat:@"Category:%@",keyString];
            vc.navigationItem.title = [categories objectAtIndex:indexPath.row];

//            vc.collections = decodedCollections;
        }
    }
}

@end
