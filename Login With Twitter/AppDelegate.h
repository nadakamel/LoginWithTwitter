//
//  AppDelegate.h
//  Login With Twitter
//
//  Created by Nada Kamel Abdelhady on 4/27/15.
//  Copyright (c) 2015 Nada Kamel Abdelhady. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>
#import <Twitter/Twitter.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)getTwitterAccountOnCompletion:(void(^)(ACAccount *))completionHandler;

@end

