//
//  de_ReminderViewController.h
//  DogEar
//
//  Created by Joy Tao on 11/28/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface de_ReminderViewController : UITableViewController 
@property (nonatomic , strong) NSDate * selectedDate;
@property (nonatomic ) NSInteger  repeatedTimes;

@end
