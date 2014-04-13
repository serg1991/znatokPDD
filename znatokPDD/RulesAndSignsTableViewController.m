//
//  RulesAndSignsTableViewController.m
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 13.04.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "RulesAndSignsTableViewController.h"

@interface RulesAndSignsTableViewController ()

@end

@implementation RulesAndSignsTableViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorDefault"]];
    UILabel *label = [[UILabel alloc] init];
    [label setText:@"Меню"];
    [label sizeToFit];
    int space = 6;
    label.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + space, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, label.frame.size.width + imageView.frame.size.width + space, imageView.frame.size.height)];
    view.bounds = CGRectMake(view.bounds.origin.x + 8, view.bounds.origin.y - 1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:label];
    UIButton *button = [[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(confirmCancel) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        label.alpha = 0.0;
        CGRect orig = label.frame;
        label.frame = CGRectMake(label.frame.origin.x + 25, label.frame.origin.y, label.frame.size.width, label.frame.size.height);
        label.alpha = 1.0;
        label.frame = orig;
    } completion:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = backButton;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

- (void)confirmCancel {
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    return 1;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 4;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/
@end
