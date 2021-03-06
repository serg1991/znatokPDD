//
//  SettingsViewController.m
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 28.01.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()

@end

@implementation SettingsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UINavigationBarBackIndicatorDefault"]];
        UILabel *labelback = [[UILabel alloc] init];
        [labelback setText:@"Меню"];
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
            bigLabel.text = @"Настройки";
            bigLabel.font = [UIFont systemFontOfSize:30.0];
            self.navigationItem.titleView = bigLabel;
        }
    } else {
        UIButton *customBackButton = [UIButton buttonWithType:101];
        [customBackButton setTitle:@"Меню" forState:UIControlStateNormal];
        [customBackButton addTarget:self
                             action:@selector(confirmCancel) forControlEvents:UIControlEventTouchUpInside];
        UIBarButtonItem *myBackButton = [[UIBarButtonItem alloc] initWithCustomView:customBackButton];
        [self.navigationItem setLeftBarButtonItem:myBackButton];
    }
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    BOOL vibration = [settings boolForKey:@"needVibro"];
    BOOL comment = [settings boolForKey:@"showComment"];
    [_vibroSwitch setOn:vibration];
    [_commentSwitch setOn:comment];
}

- (void)confirmCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)shareWithFriends:(id)sender {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Проверьте свое интернет-соединение!"
                                                       delegate:self
                                              cancelButtonTitle:@"ОК"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"There IS NO internet connection");
    } else {
        VKontakteActivity *vkontakteActivity = [[VKontakteActivity alloc] initWithParent:self];
        NSArray *shareItems = @[@"Подготовка к экзамену в ГАИ! #ЗнатокПДД для iPhone\n", [UIImage imageNamed:@"logo_share.png"],[NSURL URLWithString:@"http://itunes.apple.com/app/id865961195"]];
        UIActivityViewController *activityVC = [[UIActivityViewController alloc]
                                                initWithActivityItems:shareItems
                                                applicationActivities:@[vkontakteActivity]];
        [activityVC setValue:@"Подготовься к экзамену в ГАИ!" forKey:@"subject"];
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
            activityVC.excludedActivityTypes = @[UIActivityTypeAddToReadingList, UIActivityTypeAirDrop, UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToFlickr, UIActivityTypePostToTencentWeibo, UIActivityTypePostToVimeo, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
        } else {
            activityVC.excludedActivityTypes = @[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePostToWeibo, UIActivityTypePrint, UIActivityTypeSaveToCameraRoll];
        }
        [self presentViewController:activityVC animated:YES completion:nil];
    }
}

- (IBAction)vibroSwitchCnahged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_vibroSwitch.isOn forKey:@"needVibro"];
    [defaults synchronize];
}

- (IBAction)commentSwitchChanged:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:_commentSwitch.isOn forKey:@"showComment"];
    [defaults synchronize];
}

- (IBAction)sendDevMail:(id)sender {
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Проверьте свое интернет-соединение!"
                                                       delegate:self
                                              cancelButtonTitle:@"ОК"
                                              otherButtonTitles:nil];
        [alert show];
        NSLog(@"There IS NO internet connection");
    } else {
        if ([MFMailComposeViewController canSendMail]) {
            NSString *emailTitle = @"Знаток ПДД - письмо разработчику";
            NSString *messageBody = [NSString stringWithFormat:@"Мой вопрос: \n \n \n Мое устройство - %@. \n Версия прошивки - %@.", [UIDevice currentDevice].model, [[UIDevice currentDevice] systemVersion]];
            NSArray *toRecipents = [NSArray arrayWithObject:@"kiselev.serge@inbox.ru"];
            MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
            mc.mailComposeDelegate = self;
            [mc setSubject:emailTitle];
            [mc setMessageBody:messageBody isHTML:NO];
            [mc setToRecipients:toRecipents];
            [self presentViewController:mc animated:YES completion:NULL];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Вы не можете отправлять email-сообщения. Убедитесь, что в настройках почты подключен аккаунт."
                                                           delegate:self
                                                  cancelButtonTitle:@"ОК"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    switch (result) {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
