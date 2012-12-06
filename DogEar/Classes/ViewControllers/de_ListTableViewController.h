//
//  BKCategoryViewController.h
//  BKDogEar_v2
//
//  Created by Joy Tao on 11/19/12.
//  Copyright (c) 2012 Joy Tao. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface de_ListTableViewController : UIViewController <UITableViewDataSource , UITableViewDelegate>

@property (nonatomic ,strong) NSMutableArray * collections;
@property (nonatomic ,strong) NSMutableArray * flaggedCollections;


@end
