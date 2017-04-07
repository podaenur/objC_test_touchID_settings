//
//  ViewController.m
//  objC_test_touchID_settings
//
//  Created by Евгений Ахмеров on 8/29/16.
//  Copyright © 2016 E-legion. All rights reserved.
//

#import "ViewController.h"
#import "Constants.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *registrationButton;
@property (weak, nonatomic) IBOutlet UIButton *enterButton;

@end

@implementation ViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  [self styleView:self.registrationButton];
  [self styleView:self.enterButton];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  
  NSString *savedPassCode = [[NSUserDefaults standardUserDefaults] objectForKey:kPassCodeKey];
  self.registrationButton.enabled = (savedPassCode.length < 1);
  self.enterButton.enabled = (savedPassCode.length > 0);
}

#pragma mark - Actions

- (IBAction)onPush:(id)sender {
    NSString *text = @"prefs:root=TOUCHID_PASSCODE";
    NSURL* url = [NSURL URLWithString:text];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Private

- (void)styleView:(UIView *)view {
  view.layer.cornerRadius = 5.f;
  view.clipsToBounds = YES;
  view.layer.borderWidth = 2.f;
  view.layer.borderColor = view.tintColor.CGColor;
}

@end
