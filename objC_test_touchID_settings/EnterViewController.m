//
//  EnterViewController.m
//  objC_test_touchID_settings
//
//  Created by Evgeniy Akhmerov on 30/08/16.
//  Copyright © 2016 E-legion. All rights reserved.
//

@import LocalAuthentication;

#import "EnterViewController.h"
#import "Constants.h"

@interface EnterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passCodeField;
@property (nonatomic, copy) NSString *savedPassCode;
@property (nonatomic, assign) BOOL canEvaluatePolicy;
@property (nonatomic, strong) LAContext *context;

@end

@implementation EnterViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.savedPassCode = [[NSUserDefaults standardUserDefaults] objectForKey:kPassCodeKey];
  
  self.context = [[LAContext alloc] init];
  NSError *error = nil;
  self.canEvaluatePolicy = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
  
  if (error) {
    NSLog(@"3. %@", [error description]);
  }
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  if (self.canEvaluatePolicy) {
    NSString *reasonString = @"Touch your finger to confirm";
    
    [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
                 localizedReason:reasonString
                           reply:^(BOOL success, NSError * _Nullable error) {
                             if (success) {
                               NSLog(@"Alalala");
                             } else {
                               NSLog(@"4. %@", [error description]);
                             }
                           }];
  }
}

#pragma mark - Custom Accessors

#pragma mark - Actions

- (IBAction)onClear:(id)sender {
  [[NSUserDefaults standardUserDefaults] removeObjectForKey:kPassCodeKey];
  
  [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)onEditingChanged:(UITextField *)sender {
  if (sender.text.length == self.savedPassCode.length) {
    [self resignFirstResponder];
    [self validatePassCode:sender.text];
  }
}

#pragma mark - Public

#pragma mark - Private

- (void)validatePassCode:(NSString *)inputed {
  BOOL result = [inputed isEqualToString:self.savedPassCode];
  
  UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"PASSCODE"
                                                                      message:result ? @"success" : @"failure"
                                                               preferredStyle:(UIAlertControllerStyleAlert)];
  UIAlertAction *close = [UIAlertAction actionWithTitle:@"Close"
                                                  style:result ? UIAlertActionStyleDefault : UIAlertActionStyleDestructive
                                                handler:nil];
  [controller addAction:close];
  [self presentViewController:controller animated:YES completion:^{
    self.passCodeField.text = nil;
  }];
}

- (void)askUserValidateFinger {
  
}

#pragma mark - Segue
#pragma mark - Animations
#pragma mark - Protocol conformance
#pragma mark - Notifications handlers
#pragma mark - Gestures handlers
#pragma mark - KVO
#pragma mark - NSCopying
#pragma mark - NSObject

@end
