//
//  ExamenViewController.m
//  diplom
//
//  Created by Sergey Kiselev on 20.03.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "ExamenViewController.h"

@interface ExamenViewController ()

@end

@implementation ExamenViewController

@synthesize theLabel;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (_timer)
        return;
    remainingTicks = 1200;
    [self updateLabel];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(handleTimerTick) userInfo:nil repeats:YES];
}

- (void)handleTimerTick {
    remainingTicks--;
    [self updateLabel];
    if (remainingTicks <= 0) {
        [_timer invalidate];
        _timer = nil;
    }
}

- (void)updateLabel {
    NSString *minutes = [NSString stringWithFormat:@"%d", remainingTicks / 60];
    NSString *seconds = [NSString stringWithFormat:@"%d", remainingTicks % 60];
    NSUInteger myMinute = [minutes intValue];
    NSUInteger mySecond = [seconds intValue];
    if (myMinute < 10)
        minutes = [NSString stringWithFormat:@"0%d", remainingTicks / 60];
    if (mySecond < 10)
        seconds = [NSString stringWithFormat:@"0%d", remainingTicks % 60];
    theLabel.text =  [NSString stringWithFormat:@"%@ : %@", minutes, seconds];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:(BOOL)animated];
    [_timer invalidate];
    [self.theLabel removeFromSuperview];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    //дата начала решения билета
    _date = [[NSDate alloc] init];
    _ti = [_date timeIntervalSince1970];
    //генерация номеров билетов для вопросов экзамена
    _randomNumbers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        NSUInteger randomNumber;
        randomNumber = arc4random()%(40 - 1 + 1) + 1;
        [_randomNumbers addObject:[NSNumber numberWithUnsignedLong:randomNumber]];
    }
    //добавление контроллеров в массив
    NSDictionary *options = (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) ? [NSDictionary dictionaryWithObject: [NSNumber numberWithInteger:UIPageViewControllerSpineLocationMid] forKey: UIPageViewControllerOptionSpineLocationKey] : nil;
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:options];
    self.pageController.dataSource = self;
    [[self.pageController view] setFrame:[[self view] bounds]];
    ExamenChildViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    //добавление шапки из названия контроллера и таймера
    self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 6, 100, 30)];
    _timer = nil;
    [self.navigationItem setTitle:@"Экзамен"];
    [self.navigationController.navigationBar addSubview:theLabel];
    //отключение жеста свайпа от левого края экрана
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

- (ExamenChildViewController *)viewControllerAtIndex:(NSUInteger)index {
    ExamenChildViewController *childViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ExamenChildViewController"];
    childViewController.index = index;
    childViewController.rightAnswersArray = _rightArray;
    childViewController.wrongAnswersArray = _wrongArray;
    childViewController.wrongAnswersSelectedArray = _wrongSelectedArray;
    childViewController.startDate = _ti;
    childViewController.randomNumbers = _randomNumbers;
    childViewController.timer = _timer;
    childViewController.remainingTicks = remainingTicks;
    
    return childViewController;
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController {
    NSUInteger index = [(ExamenChildViewController *)viewController index];
    if (index == 0) {
        return nil;
    }
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController {
    NSUInteger index = [(ExamenChildViewController *)viewController index];
    index++;
    if (index == 20)
        
        return nil;
    
    return [self viewControllerAtIndex:index];
}

- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController {
    
    return 20;
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController {
    
    return 0;
}

@end