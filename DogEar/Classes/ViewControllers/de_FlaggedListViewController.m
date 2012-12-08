//
//  de_FlaggedListViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/30/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_FlaggedListViewController.h"
#import "de_ListTableViewController.h"

@interface de_FlaggedListViewController ()
{
    NSArray * flaggedItems;
}
@property (nonatomic , retain) NSArray * flaggedCollections;
@end

@implementation de_FlaggedListViewController
@synthesize flaggedCollections = _flaggedCollections;

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
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"BKFlaggedItems"])
        flaggedItems = [[[NSUserDefaults standardUserDefaults] objectForKey:@"BKFlaggedItems"] copy];
    else
    {
        flaggedItems = [[NSArray alloc]initWithObjects:@"Casual",@"Somewhat Important",@"Important",@"Very Important",@"Crucial", nil];
        [[NSUserDefaults standardUserDefaults]setObject:flaggedItems forKey:@"BKFlaggedItems"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    self.navigationItem.title = @"Flagged";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.flaggedCollections = [NSArray arrayWithArray: [self collections]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSMutableArray *) collections
{
    NSMutableArray * collections = [[NSMutableArray alloc]init];
    NSArray * categories = [[NSArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];

    for (int c = 0; c < [categories count]; c++)
    {
        NSData * data = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] objectForKey:[categories objectAtIndex:c]];
        NSMutableArray * decodedCollections = [NSMutableArray arrayWithArray:[NSKeyedUnarchiver unarchiveObjectWithData: data]];
        NSArray * copyCollections = [[NSArray arrayWithArray:decodedCollections] copy];
        
        for (DogEarObject * object in copyCollections)
        {
            if (object.flagged != nil)  [collections addObject:object];
        }
    }
    return collections;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [flaggedItems count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    cell.textLabel.text = [flaggedItems objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    return cell;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    de_ListTableViewController * vc = [[de_ListTableViewController alloc]init];
    
//    NSMutableArray * temp = [[NSMutableArray alloc]init];
//    
//    for (DogEarObject * object in [self.flaggedCollections copy])
//    {
//        if ((object.flagged != nil) && (object.flagged == [NSNumber numberWithInteger:indexPath.row]))
//        {
//            [temp addObject:object];
//        }
//    }
//    vc.collections = temp;
    vc.navigationItem.title = [flaggedItems objectAtIndex:indexPath.row];
    vc.flaggedCollections = self.flaggedCollections;
    [self.navigationController pushViewController:vc animated:YES];


}

@end
