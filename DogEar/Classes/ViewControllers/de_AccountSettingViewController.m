//
//  de_AccountSettingViewController.m
//  DogEar
//
//  Created by Joy Tao on 12/2/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import "de_AccountSettingViewController.h"
#import "TwitterManager.h"

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
    UIImageView * bgImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"dogear-bg-master"]];
    self.tableView.backgroundView = bgImage;
    
    self.navigationItem.title = @"Account Connection";
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
    [activityIndicator startAnimating];

    if (button.tag == 0)
    {
        if (    [[NSUserDefaults standardUserDefaults] objectForKey:@"DGFacebookSession_Token"])
        {
            if ( [FBSession.activeSession isOpen])
            {
                [FBSession.activeSession closeAndClearTokenInformationWithSeccess:nil];
                [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"DGFacebookSession_Token"];
                [[NSUserDefaults standardUserDefaults]synchronize];
            }
        }
        else
            [FBSession openActiveSessionWithAllowLoginUI:YES success:^(FBSession *session, FBSessionState status, NSError *error) {
                button.on = [FBSession.activeSession isOpen];
                
                [[NSUserDefaults standardUserDefaults]setObject:session.accessToken forKey:@"DGFacebookSession_Token"];
                [[NSUserDefaults standardUserDefaults]synchronize];
                
            }  failure:^(FBSession *session, FBSessionState status, NSError *error) {
                button.on = NO;
            }];
        [activityIndicator stopAnimating];

    }
    
    else if (button.tag == 1)
    {
        if ([[NSUserDefaults standardUserDefaults]boolForKey:@"Twitter_Account"]== NO)
        {
            TwitterManager * twitter  = [TwitterManager sharedManager];
            [twitter connectToTwitterAccount];
            [NSTimer scheduledTimerWithTimeInterval:1.5f target:self selector:@selector(checkTwitterConnection) userInfo:nil repeats:NO];

        }
        else
        {
            NSLog(@"%i",[[NSUserDefaults standardUserDefaults]boolForKey:@"Twitter_Account"]);

            [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"Twitter_Account"];
            [[NSUserDefaults standardUserDefaults]synchronize];
//            [button setOn:[[NSUserDefaults standardUserDefaults]boolForKey:@"Twitter_Account"]== YES?YES:NO animated:YES];

        }
    }

}

- (void) checkTwitterConnection
{
    UITableViewCell * twitterCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    UISwitch * twitterSwitch = (UISwitch*) twitterCell.accessoryView;
    UIAlertView * alertview;
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"Twitter_Account"] == NO)
    {
        twitterSwitch.on = NO;
         alertview = [[UIAlertView alloc]initWithTitle:@"DogEar Warning" message:@"Ceonnect to Twitter account failed. You can check Twitter Account in Settings." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    }
    else
    {
        twitterSwitch.on = YES;
        alertview = [[UIAlertView alloc]initWithTitle:@"DogEar" message:@"Connect to Twitter account successfully." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil];
    }
    
    [activityIndicator stopAnimating];
    [alertview show];

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
//        toggle.on = [[NSUserDefaults standardUserDefaults]objectForKey:@"FACEBOOK_ACCESS_TOKEN"]? YES:NO;
        toggle.on = [[NSUserDefaults standardUserDefaults]objectForKey:@"DGFacebookSession_Token"]?YES:NO;
        toggle.tag = indexPath.row;
    }
    else if (indexPath.row == 1)
    {
        cell.textLabel.text = @"Twitter";
        UISwitch * toggle = (UISwitch*)cell.accessoryView;
        toggle.on = [[NSUserDefaults standardUserDefaults]boolForKey:@"Twitter_Account"]== YES?YES:NO;
        toggle.tag = indexPath.row;
    }
    
    // Configure the cell...
    
    return cell;
}



@end
