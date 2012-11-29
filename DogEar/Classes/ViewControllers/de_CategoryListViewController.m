//
//  BKCategoryTableViewController.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/23/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_CategoryListViewController.h"
#import "de_DetailViewController.h"

@interface de_CategoryListViewController ()
{
    NSMutableArray * collections;
}

@property (nonatomic , retain) NSIndexPath * checkedIndexPath;;
@end

@implementation de_CategoryListViewController
//@synthesize collections = _collections;
@synthesize categoryString = _categoryString;

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
    
    UIBarButtonItem * editButton = [[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(editTable:)];
    self.navigationItem.rightBarButtonItem = editButton;
    
    self.editing = NO;
    collections = [[NSMutableArray alloc]initWithArray:[[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"]];
//    self. checkedIndexPath = [NSIndexPath indexPathForRow:self.selectedCategory inSection:0];
    self.navigationItem.title = @"Categoty";
}

//JT- TODO: Fix up pre-select

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.categoryString != NULL)
    {
        NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"];
        self. checkedIndexPath = [NSIndexPath indexPathForRow:[array indexOfObject:self.categoryString] inSection:0];
    }
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSUserDefaults standardUserDefaults]setObject:collections forKey:@"BKCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) editTable:(id)sender{
	if(self.editing)
	{
		[super setEditing:NO animated:NO];
		[self.tableView setEditing:NO animated:NO];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Edit"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStylePlain];
	}
	else
	{
		[super setEditing:YES animated:YES];
		[self.tableView setEditing:YES animated:YES];
		[self.tableView reloadData];
		[self.navigationItem.rightBarButtonItem setTitle:@"Done"];
		[self.navigationItem.rightBarButtonItem setStyle:UIBarButtonItemStyleDone];
	}
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSArray * array = [[NSUserDefaults standardUserDefaults]objectForKey:@"BKCategory"];
    int count = [collections count];
	if(self.editing) count++;
	return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    
    if(!self.editing && [self.checkedIndexPath isEqual:indexPath])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    
    int count = 0;
	if(self.editing && indexPath.row != 0)
		count = 1;
	
    // Set up the cell...
	if(indexPath.row == ([collections count]) && self.editing){
		cell.textLabel.text = @"add new row";
		return cell;
	}
    
	cell.textLabel.text = [collections objectAtIndex:indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Table view delegate

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

- (UITableViewCellEditingStyle) tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.editing == NO || !indexPath) return UITableViewCellEditingStyleNone;
    // Determine the editing style based on whether the cell is a placeholder for adding content or already
    // existing content. Existing content can be deleted.
   
    if (self.editing && indexPath.row == ([collections count])) {
		return UITableViewCellEditingStyleInsert;
	} else {
		return UITableViewCellEditingStyleDelete;
	}
    return UITableViewCellEditingStyleNone;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        NSString * key = [collections objectAtIndex:indexPath.row];
        
        [collections removeObjectAtIndex:indexPath.row];    //J-Comment: Delete
        
        [[NSUserDefaults standardUserDefaults]setObject:collections forKey:@"BKCategory"];
        NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
        [dict removeObjectForKey:key];  //JT-Comment: Dictionary remove object for key
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"BKDataCollections"];
        [[NSUserDefaults standardUserDefaults] synchronize];
		[self.tableView reloadData];
        
    }
    else if (editingStyle == UITableViewCellEditingStyleInsert)
    {
        UIAlertView * newCategoryView = [[UIAlertView alloc]initWithTitle:@"Add Catagory" message:@"Category Name" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Save", nil];
        newCategoryView.alertViewStyle = UIAlertViewStylePlainTextInput;
        [newCategoryView show];
    }
}


// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString *item = [collections objectAtIndex:fromIndexPath.row];
	[collections removeObject:item];
	[collections insertObject:item atIndex:toIndexPath.row];
    [[NSUserDefaults standardUserDefaults]setObject:collections forKey:@"BKCategory"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    de_DetailViewController * vc = (de_DetailViewController*)[self.navigationController.viewControllers objectAtIndex:[self.navigationController.viewControllers count]-2];
    
    if(self.checkedIndexPath)
    {
        UITableViewCell* uncheckCell =[tableView  cellForRowAtIndexPath:self.checkedIndexPath];
        uncheckCell.accessoryType =UITableViewCellAccessoryNone;
        [vc.dogEar setCategory:nil];
    }
    if([self.checkedIndexPath isEqual:indexPath])
        self.checkedIndexPath = nil;
    else
    {
        UITableViewCell* cell =[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType =UITableViewCellAccessoryCheckmark;
        self.checkedIndexPath = indexPath;
        [vc.dogEar setCategory:cell.textLabel.text];
    }

}


#pragma mark - UIAlertView Delegate Method

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSString *title = [alertView buttonTitleAtIndex:buttonIndex];
    if([title isEqualToString:@"Save"])
    {
        NSString * categoryName = [[alertView textFieldAtIndex:0] text];
        [collections insertObject:categoryName atIndex:[collections count]];
        [[NSUserDefaults standardUserDefaults]setObject:collections forKey:@"BKCategory"];
 
        NSMutableDictionary * dict = [[[NSUserDefaults standardUserDefaults]objectForKey:@"BKDataCollections"] mutableCopy];
        NSArray * newArray = [[NSArray alloc]init];
        NSData * encodedObjects = [NSKeyedArchiver archivedDataWithRootObject:newArray];
        
        [dict setObject:encodedObjects forKey:categoryName];
        //JT-Note: Dictionary add object(NSData) for key
        
        [[NSUserDefaults standardUserDefaults]setObject:dict forKey:@"BKDataCollections"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        [self.tableView reloadData];
        
    }
}

@end
