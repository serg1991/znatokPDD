//
//  ThemeChildViewController.h
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 29.03.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <sqlite3.h>
#import "ResultViewController.h"

@interface ThemeChildViewController : UIViewController

@property (assign, nonatomic) int index;
@property (nonatomic) sqlite3 *pdd_ab;
@property (nonatomic) sqlite3 *pdd_ab_stat;
@property (weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic) int themeNumber;
@property (nonatomic) int themeCount;
@property (nonatomic, retain) NSMutableArray *themeName;
@property (nonatomic, retain) NSMutableArray *mainArray;
@property (nonatomic, retain) NSMutableArray *rightAnswersArray;
@property (nonatomic, retain) NSMutableArray *wrongAnswersSelectedArray;
@property (nonatomic, retain) NSMutableArray *wrongAnswersArray;
@property (nonatomic) NSTimeInterval startDate;
@property (nonatomic) NSTimeInterval finishDate;
@property (nonatomic, retain) NSTimer *flashTimer;

@end
