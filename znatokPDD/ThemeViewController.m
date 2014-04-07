//
//  ThemeViewController.m
//  diplom
//
//  Created by Sergey Kiselev on 29.03.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "ThemeViewController.h"

@interface ThemeViewController ()

@end

@implementation ThemeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDate *date = [[NSDate alloc] init];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"dd.MM.yyyy HH:mm:ss"];
    _dateString = [dateFormatter stringFromDate:date];
    NSDictionary *options = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) ? [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey: UIPageViewControllerOptionSpineLocationKey] : nil;
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    ThemeChildViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 22)];
    label.font = [UIFont systemFontOfSize: 18.0f];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = [NSString stringWithFormat:@"Тема №%lu", (unsigned long)_themeNumber + 1];
    self.navigationItem.titleView = label;
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorDefault"]];
    UILabel *labelback = [[UILabel alloc] init];
    [labelback setText:@"Прервать"];
    [labelback sizeToFit];
    int space = 6;
    labelback.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + space, labelback.frame.origin.y, labelback.frame.size.width, labelback.frame.size.height);
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelback.frame.size.width + imageView.frame.size.width + space, imageView.frame.size.height)];
    view.bounds = CGRectMake(view.bounds.origin.x + 8, view.bounds.origin.y - 1, view.bounds.size.width, view.bounds.size.height);
    [view addSubview:imageView];
    [view addSubview:labelback];
    UIButton *button = [[UIButton alloc] initWithFrame:view.frame];
    [button addTarget:self action:@selector(confirmCancel) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:button];
    [UIView animateWithDuration:0.33 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
        labelback.alpha = 0.0;
        CGRect orig = labelback.frame;
        labelback.frame = CGRectMake(labelback.frame.origin.x + 25, labelback.frame.origin.y, labelback.frame.size.width, labelback.frame.size.height);
        labelback.alpha = 1.0;
        labelback.frame = orig;
    } completion:nil];
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithCustomView:view];
    self.navigationItem.leftBarButtonItem = backButton;
    
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)confirmCancel {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание"
                                                    message:@"Вы действительно хотите \n выйти из тестирования? \n Ваш прогресс не будет сохранен."
                                                   delegate:self
                                          cancelButtonTitle:@"Нет"
                                          otherButtonTitles:@"Да, выйти", nil];
    [alert show];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (ThemeChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    ThemeChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ThemeChildViewController"];
    childViewController.index = index;
    childViewController.themeNumber = _themeNumber;
    childViewController.rightAnswersArray = _rightArray;
    childViewController.wrongAnswersArray = _wrongArray;
    childViewController.wrongAnswersSelectedArray = _wrongSelectedArray;
    childViewController.startDate = _dateString;
    childViewController.themeCount = [[_themeCount objectAtIndex:_themeNumber]integerValue];
    
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(ThemeChildViewController *)viewController index];
    if (index == 0) {
        return nil;
    }
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(ThemeChildViewController *)viewController index];
    index++;
    if (index == [[_themeCount objectAtIndex:_themeNumber]integerValue])
        
        return nil;
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    return [[_themeCount objectAtIndex:_themeNumber]integerValue];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    return 0;
}

@end