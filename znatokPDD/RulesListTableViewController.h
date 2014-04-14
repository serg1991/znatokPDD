//
//  RulesListTableViewController.h
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 31.01.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RulesDetailViewController.h"

@interface RulesListTableViewController : UITableViewController

@property (nonatomic, strong) NSArray *ruleNumbers;
@property (nonatomic, strong) NSArray *ruleDetail;

@end
