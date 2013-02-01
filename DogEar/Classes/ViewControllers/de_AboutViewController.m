//
//  de_AboutViewController.m
//  DogEar
//
//  Created by Joy Tao on 2/1/13.
//  Copyright (c) 2013 Joy Tao. All rights reserved.
//

#import "de_AboutViewController.h"
#import "de_AboutHeaderView.h"

#import "MessageManager.h"
#import "UITextView+EULA.h"

@interface de_AboutViewController ()

@end

@implementation de_AboutViewController

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
    
    de_AboutHeaderView * aboutHeaderView = [[de_AboutHeaderView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 240.0f)];
    self.tableView.tableHeaderView = aboutHeaderView;
    self.title = @"About";
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    
    switch (indexPath.section) {
        case 0:
            cell.textLabel.text = @"Agreement";
            break;
        case 1:
            cell.textLabel.text = @"Email Support";
            break;
        default:
            break;
    }
    cell.backgroundColor = [UIColor colorWithRed:62.0f/255.0f green:153.0f/255.0f blue:166.0f/255.0f alpha:1.0];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
        {
            UIViewController * vc = [[UIViewController alloc]init];
            UITextView * eulaTextView = [[UITextView alloc]EndUserLicenseAgreenment];
            eulaTextView.frame = vc.view.bounds;

            eulaTextView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, 109.0f, 0.0f);
            eulaTextView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0f, 0.0f, 89.0f, 0.0f);
            [vc.view addSubview:eulaTextView];
            
            [self.navigationController pushViewController:vc animated:YES];
            vc.title = @"Agreement";
        }
            
            break;
        case 1:
        {
            MessageManager * composer = [MessageManager sharedComposer];
            [composer reportSupportviaMailComposerFromParent:self];
        }
            break;
        default:
            break;
    }
}

@end
