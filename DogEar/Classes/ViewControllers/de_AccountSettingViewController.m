//
//  de_AccountSettingViewController.m
//  DogEar
//
//  Created by Joy Tao on 12/2/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_AccountSettingViewController.h"

#define DEVICE_OS 
@interface de_AccountSettingViewController ()
{
    UIActivityIndicatorView * activityIndicator;
}

//@property (nonatomic , strong) ACAccountStore * accountStore;

@end

@implementation de_AccountSettingViewController
//@synthesize accountStore = _accountStore;

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
    self.title = @"Account Setting";
    activityIndicator = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activityIndicator.frame = CGRectMake(0.0f, 0.0f, 60.0f, 60.0f);
    activityIndicator.center = self.view.center;
    [self.view addSubview:activityIndicator];


}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -

- (void) buttonTapped:(id)sender
{
    UISwitch * button = (UISwitch*)sender;
    ACAccountStore * accountStore = [[ACAccountStore alloc]init];
    if (button.tag == 0)
    {
        
    }
    
    else if (button.tag == 1)
    {
        ACAccountType * twitterType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

        if (button.on)
        {
            [activityIndicator startAnimating];

            if (![[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Account"])
            {
                [accountStore requestAccessToAccountsWithType:twitterType
                                                      options:nil
                                                   completion:^(BOOL granted, NSError * error)
                {
                    if (granted)
                    {
                        NSArray * accounts = [accountStore accountsWithAccountType:twitterType];
                        if ([accounts count] > 0)
                        {
                            ACAccount * twitterAccount = [accounts lastObject];
                            [[NSUserDefaults standardUserDefaults]setObject:twitterAccount.identifier forKey:@"Twitter_Account"];
                            [[NSUserDefaults standardUserDefaults]setObject:twitterAccount.username forKey:@"Twitter_Username"];
                            
                            [[NSUserDefaults standardUserDefaults]synchronize];
                            [button setOn:NO animated:YES];
                            

                        }
                        else
                        {
                            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"No Twiiter Account" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                            [alertView show];
                            [button setOn:YES animated:YES];

                        }
                    }
                    else
                    {
                        UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"Twitter Authorization" message:@"Please log into Twitter Account in the Settings please, then try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                        [alertView show];
                        [button setOn:YES animated:YES];

                    }
                    [self.tableView reloadData];
                    [activityIndicator stopAnimating];

                }];
                
            }

        }
        else
        {
            if ([[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Account"])
            {
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Twitter_Account"];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"Twitter_Username"];
                [[NSUserDefaults standardUserDefaults]synchronize];

            }
            [button setOn:YES animated:YES];
            [self.tableView reloadData];

        }
    }

}

#pragma mark - UIAlertView Delegate Method



#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = (UITableViewCell*)[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    
    UISwitch * toggle = [[UISwitch alloc]initWithFrame:CGRectZero];
    [toggle addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventValueChanged];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryView = toggle;
    
    if (indexPath.row == 0)
    {
        cell.textLabel.text = @"Facebook";
        UISwitch * toggle = (UISwitch*)cell.accessoryView;
        toggle.on = [[NSUserDefaults standardUserDefaults]objectForKey:@"Facebook_Account"]?YES:NO;
        toggle.tag = indexPath.row;
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Twitter";
        cell.detailTextLabel.text = [[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Account"] ? [[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Username"]:nil;

        UISwitch * toggle = (UISwitch*)cell.accessoryView;
        toggle.on = [[NSUserDefaults standardUserDefaults]objectForKey:@"Twitter_Account"]?YES:NO;
        toggle.tag = indexPath.row;
    }
    
    // Configure the cell...
    
    return cell;
}



@end
