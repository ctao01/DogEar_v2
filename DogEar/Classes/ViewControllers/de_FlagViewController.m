//
//  de_FlagViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/29/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_FlagViewController.h"
#import "de_DetailViewController.h"

@interface de_FlagViewController ()
{
    NSArray * flaggedArray;
}

@end

@implementation de_FlagViewController
@synthesize selectedIndexPath = _selectedIndexPath;

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
    if (![[NSUserDefaults standardUserDefaults]objectForKey:@"BKFlaggedItems"])
    {
        flaggedArray = [[NSArray alloc]initWithObjects:@"Casual",@"Somewhat Important",@"Important",@"Very Important",@"Crucial", nil];
        [[NSUserDefaults standardUserDefaults]setObject:flaggedArray forKey:@"BKFlaggedItems"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else flaggedArray = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKFlaggedItems"] copy];
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-content-master"]];
    self.tableView.backgroundView = bgImage;
    self.navigationItem.title = @"Flagged It";
}

- (void) viewWillAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    if([self.selectedIndexPath isEqual:indexPath])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [flaggedArray objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    de_DetailViewController * vc = (de_DetailViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    
    if(self.selectedIndexPath)
    {
        UITableViewCell* uncheckCell =[tableView  cellForRowAtIndexPath:self.selectedIndexPath];
        uncheckCell.accessoryType =UITableViewCellAccessoryNone;
        [vc.dogEar setFlagged:NULL];
    }
    if([self.selectedIndexPath isEqual:indexPath])
    {
        self.selectedIndexPath = nil;
        [vc.dogEar setFlagged:NULL];
    }
    else
    {
        UITableViewCell* cell =[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        self.selectedIndexPath = indexPath;
        [vc.dogEar setFlagged:[NSNumber numberWithInteger:indexPath.row]];
    }
    [self.navigationController popViewControllerAnimated:YES];

}

@end
