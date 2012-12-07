//
//  de_RepeatingLNViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/29/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_RepeatingLNViewController.h"
#import "de_ReminderViewController.h"

@interface de_RepeatingLNViewController ()

@end

@implementation de_RepeatingLNViewController
@synthesize checkedIndexPath = _checkedIndexPath;
@synthesize array = _array;

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
    self.navigationItem.title = @"Set Repeat";
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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
    if (self.array) return 1;
    else return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.array) return [self.array count];
    else return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    // Configure the cell...
    if([self.checkedIndexPath isEqual:indexPath])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    cell.textLabel.text = [self.array objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    de_ReminderViewController * vc = (de_ReminderViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell =[tableView  cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType =UITableViewCellAccessoryNone;
        [vc setRepeatedTimes:0];
    }
    if([self.checkedIndexPath isEqual:indexPath])
    {
        self.checkedIndexPath = nil;
        [vc setRepeatedTimes:0];

    }
    else
    {
        UITableViewCell* cell =[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        [vc setRepeatedTimes:self.checkedIndexPath.row];
    }
}

@end
