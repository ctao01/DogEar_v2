//
//  de_DetailViewController.m
//  DogEar
//
//  Created by Joy Tao on 11/27/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_DetailViewController.h"
#import "de_DetailHeaderView.h"
#import "de_CategoryListViewController.h"

@interface de_DetailViewController ()
@property (nonatomic) BOOL isEditing;
@end

@implementation de_DetailViewController
@synthesize action = _action;
@synthesize isEditing = _isEditing;
@synthesize dogear = _dogear;

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
    
    self.dogear = [DogEarObject new];

    CGRect bounds = [[UIScreen mainScreen]bounds];
    de_DetailHeaderView * headerView = [[de_DetailHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, bounds.size.width, 110.0f)];
    headerView.center = CGPointMake(self.view.center.x, headerView.center.y);
    headerView.vcParent = self;
    if (self.action == DogEarActionEditing) headerView.allowEditing = YES;
    else if (self.action == DogEarActionViewing) headerView.allowEditing = NO;
    
    self.tableView.tableHeaderView = headerView;
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.action == DogEarActionEditing)
    {
        NSIndexPath * path = [NSIndexPath indexPathForRow:0 inSection:0];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:path];
        
        if (![cell.detailTextLabel.text isEqualToString:@""])
        {
            UIBarButtonItem * saveItem = [[UIBarButtonItem alloc]initWithTitle:@"Add" style:UIBarButtonItemStyleBordered target:self action:@selector(addDogEar)];
            self.navigationItem.rightBarButtonItem = saveItem;
        }
        else
            self.navigationItem.rightBarButtonItem = nil;
    }
    else
    {
        self.isEditing = NO;
        
        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStyleBordered target:self action:@selector(edit:)];
        self.navigationItem.rightBarButtonItem = editItem;
        
        self.tableView.userInteractionEnabled = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIBarButtonItem (UINavigationBar)

- (void) edit:(id)sender
{
    if (self.isEditing)
    {
        self.tableView.userInteractionEnabled = NO;

        //JT-TODO: Done Feature
        
        [self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
        
        self.navigationItem.leftBarButtonItem = nil;
        self.isEditing = NO;
        
    }
    else
    {
        self.tableView.userInteractionEnabled = YES;

        
        [self.navigationItem.rightBarButtonItem setTitle:@"Done"];
        [self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
        
        UIBarButtonItem * cancelItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelEditing)];
        self.navigationItem.leftBarButtonItem = cancelItem;
        
        self.isEditing = YES;
    }
}

#pragma mark - 

- (void) addDogEar
{
    if (self.tabBarController.selectedIndex == 0)[self.navigationController popToRootViewControllerAnimated:YES];
    else [self.tabBarController setSelectedIndex:0];
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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // TODO: NSDictionary
    
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"Category";
//            cell.detailTextLabel.text = self.dogEar.category ? self.dogEar.category : @"";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        case 1:
            cell.textLabel.text = @"Reminder";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case 2:
            cell.textLabel.text = @"Flagged";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            break;
        case 3:
            cell.textLabel.text = @"Print";
            break;
            
        default:
            break;
    }

    
    return cell;
}

#pragma mark - UITableView Delegate Method
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
    if (indexPath.row == 0)
    {
        de_CategoryListViewController * tv = [[de_CategoryListViewController alloc]initWithStyle:UITableViewStylePlain];
        tv.categoryString = cell.detailTextLabel.text;
        [self.navigationController pushViewController:tv animated:YES];
        
    }
    /*else if (indexPath.row == 1)
    {
        BKReminderViewController * vc = [[BKReminderViewController alloc]initWithStyle:UITableViewStyleGrouped];
        UINavigationController * nc = [[UINavigationController alloc]initWithRootViewController:vc];
        [self.navigationController presentModalViewController:nc animated:YES];
    }*/
}

@end
