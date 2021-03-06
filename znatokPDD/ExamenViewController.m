//
//  ExamenViewController.m
//  ZnatokPDD
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
    if (_timer) {
        return;
    }
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
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание"
                                                        message:@"Время, отведенное на тестирование закончилось.\n Ваш результат не будет сохранен."
                                                       delegate:self
                                              cancelButtonTitle:nil
                                              otherButtonTitles:@"ОК", nil];
        alert.tag = 2;
        [alert show];
    }
}

- (void)updateLabel {
    NSString *minutes = [NSString stringWithFormat:@"%d", remainingTicks / 60];
    NSString *seconds = [NSString stringWithFormat:@"%d", remainingTicks % 60];
    NSUInteger myMinute = [minutes intValue];
    NSUInteger mySecond = [seconds intValue];
    if (myMinute < 10) {
        minutes = [NSString stringWithFormat:@"0%d", remainingTicks / 60];
    }
    if (mySecond < 10) {
        seconds = [NSString stringWithFormat:@"0%d", remainingTicks % 60];
    }
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
    _startDate = [_date timeIntervalSince1970];
    //генерация номеров билетов для вопросов экзамена
    _randomNumbers = [[NSMutableArray alloc] init];
    for (int i = 0; i < 20; i++) {
        NSUInteger randomNumber;
        randomNumber = arc4random()%(40 - 1 + 1) + 1;
        [_randomNumbers addObject:[NSNumber numberWithUnsignedLong:randomNumber]];
    }
    //добавление контроллеров в массив
    self.pageController = [[UIPageViewController alloc] initWithTransitionStyle:UIPageViewControllerTransitionStyleScroll navigationOrientation:UIPageViewControllerNavigationOrientationHorizontal options:nil];
    [[self.pageController view] setFrame:[[self view] bounds]];
    ExamenChildViewController *initialViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = [NSArray arrayWithObject:initialViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
    [self addChildViewController:self.pageController];
    [[self view] addSubview:[self.pageController view]];
    [self.pageController didMoveToParentViewController:self];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        //добавление шапки из названия контроллера и таймера
        self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(260, 7, 60, 30)];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(660, 7, 110, 30)];
            self.theLabel.font = [UIFont systemFontOfSize:30.0f];
        }
        _timer = nil;
        [self.navigationController.navigationBar addSubview:theLabel];
        [self.navigationItem setTitle:@"Экзамен"];
        //отключение жеста свайпа от левого края экрана
        if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
            self.navigationController.interactivePopGestureRecognizer.delegate = nil;
        }
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorDefault"]];
        UILabel *labelback = [[UILabel alloc] init];
        [labelback setText:@"Прервать"];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            labelback.font = [UIFont systemFontOfSize:30.0f];
        }
        [labelback sizeToFit];
        int space = 6;
        labelback.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + space, labelback.frame.origin.y, labelback.frame.size.width, labelback.frame.size.height);
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
               labelback.frame = CGRectMake(imageView.frame.origin.x + imageView.frame.size.width + space, labelback.frame.origin.y - 9, labelback.frame.size.width, labelback.frame.size.height);
        }
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
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            UILabel *bigLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 1, 30)];
            bigLabel.text = @"Экзамен";
            bigLabel.font = [UIFont systemFontOfSize:30.0];
            self.navigationItem.titleView = bigLabel;
        }
        CGRect appFrame = [[UIScreen mainScreen] bounds];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            CGRect f = CGRectMake(0, 936, 768, 20);
            _pageControl = [[PageControl alloc] initWithFrame:f];
        } else {
            if (appFrame.size.height > 480) {
                CGRect f = CGRectMake(0, 480 , 320, 20);
                _pageControl = [[PageControl alloc] initWithFrame:f];
            } else {
                CGRect f = CGRectMake(0, 392 , 320, 20);
                _pageControl = [[PageControl alloc] initWithFrame:f];
            }
        }
        _pageControl.numberOfPages = 20;
        _pageControl.currentPage = 0;
        [self.view addSubview:_pageControl];
    } else {
        UIButton *customBackButton = [UIButton buttonWithType:101];
        [customBackButton setTitle:@"Прервать" forState:UIControlStateNormal];
        [customBackButton addTarget:self
                             action:@selector(confirmCancel) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        [self.navigationItem setLeftBarButtonItem:myBackButton];
        self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(250, 8, 66, 30)];
        self.theLabel.backgroundColor = [UIColor clearColor];
        self.theLabel.textColor = [UIColor whiteColor];
        self.theLabel.font = [UIFont systemFontOfSize:20.0f];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            self.theLabel = [[UILabel alloc] initWithFrame:CGRectMake(680, 7, 80, 30)];
            self.theLabel.font = [UIFont boldSystemFontOfSize:20.0f];
            self.theLabel.textColor = [UIColor grayColor];
            self.theLabel.backgroundColor = [UIColor clearColor];
        }
        _timer = nil;
        [self.navigationItem setTitle:@"Экзамен"];
        [self.navigationController.navigationBar addSubview:theLabel];
        CGRect appFrame = [[UIScreen mainScreen] bounds];
        if (UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPad) {
            CGRect f = CGRectMake(0, 956 , 768, 20);
            _pageControl = [[PageControl alloc] initWithFrame:f];
        } else {
            if (appFrame.size.height > 480) {
                CGRect f = CGRectMake(0, 500 , 320, 20);
                _pageControl = [[PageControl alloc] initWithFrame:f];
            } else {
                CGRect f = CGRectMake(0, 412 , 320, 20);
                _pageControl = [[PageControl alloc] initWithFrame:f];
            }
        }
        _pageControl.numberOfPages = 20;
        _pageControl.currentPage = 0;
        [self.view addSubview:_pageControl];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionAnsweredRight:) name:@"AnsweredRight" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(questionAnsweredWrong:) name:@"AnsweredWrong" object:nil];
}

- (void)questionAnsweredRight:(id)object {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self nextTap];
        _pageControl.currentPage++;
    });
}

- (void)questionAnsweredWrong:(id)object {
    double delayInSeconds = 0.5;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self nextTap];
        _pageControl.currentPage++;
    });
}

- (void)alertView:(UIAlertView *)alertView willDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (alertView.tag) {
        case 1:
            if (buttonIndex) {
                [self.navigationController popToRootViewControllerAnimated:YES];
            }
            break;
        case 2: {
            [self.navigationController popViewControllerAnimated:YES];
        }
            break;
    }
    
}

- (void)confirmCancel {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Внимание"
                                                    message:@"Вы действительно хотите \n выйти из тестирования? \n Ваш прогресс не будет сохранен."
                                                   delegate:self
                                          cancelButtonTitle:@"Нет"
                                          otherButtonTitles:@"Да, выйти", nil];
    alert.tag = 1;
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
    childViewController.startDate = _startDate;
    childViewController.randomNumbers = _randomNumbers;
    childViewController.timer = _timer;
    childViewController.remainingTicks = remainingTicks;
    _currentIndex = (int)index;
    return childViewController;
}

- (void)nextTap {
	if (_currentIndex == kBiletQuestionNumber - 1) {
        return;
	} else {
		_currentIndex += 1;
	}
	
	ExamenChildViewController *toViewController = (ExamenChildViewController *)[self viewControllerAtIndex:_currentIndex];
	[_pageController setViewControllers:[NSArray arrayWithObject:toViewController] direction:UIPageViewControllerNavigationDirectionForward animated:YES completion:nil];
}

@end
