//
//  BKSettingViewController.m
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/16/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_SettingViewController.h"
#import "de_AccountSettingViewController.h"

@interface de_SettingViewController ()

@end

@implementation de_SettingViewController

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
    return 4;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier ];
    if (cell == nil) cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"About";
            break;
        case 1:
            cell.textLabel.text = @"Notification";
            break;
        case 2:
            cell.textLabel.text = @"Facebook/Twitter";
            break;
        case 3:
            cell.textLabel.text = @"How To Use";
            break;
        default:
            break;
    }
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = (UITableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
   
    if (indexPath.row == 2)
    {
        de_AccountSettingViewController * vc = [[de_AccountSettingViewController alloc]initWithStyle:UITableViewStyleGrouped];
        [self.navigationController pushViewController:vc animated:YES];
    }
    
    else if (indexPath.row == 3)
    {
        UIViewController * vc = [[UIViewController alloc]init];
        UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dogear-bg-instructions"]];
        backgroundImage.contentMode = UIViewContentModeScaleAspectFit;
        [vc.view addSubview:backgroundImage];
        [vc.navigationItem setTitle:cell.textLabel.text];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
        
}

@end
