//
//  VKontakteActivity.m
//  ZnatokPDD
//
//  Created by Sergey Kiselev on 07.04.14.
//  Copyright (c) 2014 Sergey Kiselev. All rights reserved.
//

#import "VKontakteActivity.h"

static NSString * kAppID = @"4289778";

@implementation VKontakteActivity

#pragma mark - NSObject

- (id)initWithParent:(UIViewController *)parent {
    if ((self = [super init])) {
        self.parent = parent;
    }
    
    return self;
}

#pragma mark - UIActivity

- (NSString *)activityType {
    return @"VKActivityTypeVKontakte";
}

- (NSString *)activityTitle {
    return @"VKontakte";
}

- (UIImage *)_activityImage {
    return [UIImage imageNamed:@"vk_share"];
}

+ (UIActivityCategory)activityCategory {
    return UIActivityCategoryShare;
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems {
    for (UIActivityItemProvider *item in activityItems) {
        if ([item isKindOfClass:[UIImage class]]) {
            return YES;
        }
        else if ([item isKindOfClass:[NSString class]]) {
            return YES;
        }
        else if ([item isKindOfClass:[NSURL class]]) {
            return YES;
        }
    }
    
    return NO;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems {
    for (id item in activityItems) {
        if ([item isKindOfClass:[NSString class]]) {
            self.string = item;
        }
        else if([item isKindOfClass:[UIImage class]]) {
            self.image = item;
        }
        else if([item isKindOfClass:[NSURL class]]) {
            self.URL = item;
        }
    }
}

- (void)performActivity {
    [VKSdk initializeWithDelegate:self andAppId:kAppID];
    if ([VKSdk wakeUpSession]) {
        [self postToWall];
    }
    else {
        [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
    }
}

#pragma mark - Upload

- (void)postToWall {
    [self begin];
    if (self.image) {
        [self uploadPhoto];
    }
    else {
        [self uploadText];
    }
}

- (void)uploadPhoto {
    NSString *userId = [VKSdk getAccessToken].userId;
    VKRequest *request = [VKApi uploadWallPhotoRequest:self.image parameters:[VKImageParameters jpegImageWithQuality:1.f] userId:[userId integerValue] groupId:0];
	[request executeWithResultBlock:^(VKResponse *response) {
	    VKPhoto *photoInfo = [(VKPhotoArray *)response.parsedModel objectAtIndex:0];
	    NSString *photoAttachment = [NSString stringWithFormat:@"photo%@_%@", photoInfo.owner_id, photoInfo.id];
        [self postToWall:@{ VK_API_ATTACHMENTS : photoAttachment,
                            VK_API_FRIENDS_ONLY : @(0),
                            VK_API_OWNER_ID : userId,
                            VK_API_MESSAGE : [NSString stringWithFormat:@"%@ %@", self.string, [self.URL absoluteString]]}];
    } errorBlock: ^(NSError *error) {
	    NSLog(@"Error: %@", error);
        [self end];
	}];
}

- (void)uploadText {
    [self postToWall:@{ VK_API_FRIENDS_ONLY : @(0),
                        VK_API_OWNER_ID : [VKSdk getAccessToken].userId,
                        VK_API_MESSAGE : self.string}];
}

- (void)postToWall:(NSDictionary *)params {
    VKRequest *post = [[VKApi wall] post:params];
    [post executeWithResultBlock:^(VKResponse *response) {
        NSNumber *postId = response.json[@"post_id"];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://vk.com/wall%@_%@", [VKSdk getAccessToken].userId, postId]]];
        [self end];
    } errorBlock: ^(NSError *error) {
        NSLog(@"Error: %@", error);
        [self end];
    }];
}

- (void)begin {
    UIView *view = self.parent.view.window;
    self.HUD = [[MBProgressHUD alloc] initWithView:view];
	[view addSubview:self.HUD];
    self.HUD.mode = MBProgressHUDModeIndeterminate;
    self.HUD.labelText = @"Загрузка...";
	[self.HUD show:YES];
}

- (void)end {
    [self.HUD hide:YES];
    [self activityDidFinish:YES];
}

#pragma mark - vkSdk

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
	VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
	[vc presentIn:self.parent];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:@[VK_PER_WALL, VK_PER_PHOTOS]];
}

- (void)vkSdkReceivedNewToken:(VKAccessToken *)newToken {
    [self postToWall];
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
	[self.parent presentViewController:controller animated:YES completion:nil];
}

- (void)vkSdkDidAcceptUserToken:(VKAccessToken *)token {
    [self postToWall];
}

- (void)vkSdkUserDeniedAccess:(VKError *)authorizationError {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                        message:@"Доступ запрещен"
                                                       delegate:self
                                              cancelButtonTitle:@"Закрыть"
                                              otherButtonTitles:nil];
    [alertView show];
    [self.HUD hide:YES];
}

@end
