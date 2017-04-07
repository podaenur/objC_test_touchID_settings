//
//  RegistrationViewController.m
//  objC_test_touchID_settings
//
//  Created by Evgeniy Akhmerov on 30/08/16.
//  Copyright © 2016 E-legion. All rights reserved.
//

@import LocalAuthentication;

#import "RegistrationViewController.h"
#import "Constants.h"

@interface RegistrationViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passCodeField;
@property (nonatomic, assign) BOOL canEvaluatePolicy;
@property (nonatomic, strong) LAContext *context;
@property (weak, nonatomic) IBOutlet UILabel *errorInfoLabel;
@property (nonatomic, assign) NSInteger errorCode;

@end

@implementation RegistrationViewController

#pragma mark - Life cycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  self.errorCode = NSNotFound;
  
  self.errorInfoLabel.text = nil;
  
  self.context = [[LAContext alloc] init];
  NSError *error = nil;
  self.canEvaluatePolicy = [self.context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error];
  
  if (error) {
    dispatch_async(dispatch_get_main_queue(), ^{
      self.errorInfoLabel.text = [error description];
    });
    NSLog(@"1. %@", [error description]);
    
    if ([error.domain isEqualToString:LAErrorDomain]) {
      self.errorCode = error.code;
    }
  }
}

#pragma mark - Actions

- (IBAction)onSave:(id)sender {
  if (self.passCodeField.text.length > 0) {
    [[NSUserDefaults standardUserDefaults] setObject:self.passCodeField.text forKey:kPassCodeKey];
    if ([[NSUserDefaults standardUserDefaults] synchronize]) {
      [self.passCodeField resignFirstResponder];
      
      [self askUserTouchID];
    }
  }
}

#pragma mark - Private

- (void)askUserTouchID {
//  if (self.canEvaluatePolicy) {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil
                                                                        message:@"would you like to use Touch ID?"
                                                                 preferredStyle:(UIAlertControllerStyleAlert)];
    
    UIAlertAction *success = [UIAlertAction actionWithTitle:@"Yes"
                                                      style:UIAlertActionStyleDefault
                                                    handler:^(UIAlertAction * _Nonnull action) {

                                                      if (self.errorCode == LAErrorTouchIDNotEnrolled) {
                                                          NSURL *settingsURL = [NSURL URLWithString:@"prefs:root=TOUCHID_PASSCODE"];
                                                          if ([[UIApplication sharedApplication] canOpenURL:settingsURL]) {
                                                              [self zeroCountFingers];
                                                          } else {
                                                              NSLog(@"Can't fallthrough to touch ID settings");
                                                          }
                                                      } else {
                                                        [self method];
                                                      }
                                                    }];
    
    UIAlertAction *failure = [UIAlertAction actionWithTitle:@"No"
                                                      style:UIAlertActionStyleDestructive
                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                      [self.navigationController popToRootViewControllerAnimated:YES];
                                                    }];
    
    [controller addAction:success];
    [controller addAction:failure];
    
    [self presentViewController:controller animated:YES completion:nil];
//  }
}

- (void)method {
  NSString *reasonString = @"Biometric will concatinate with passcode";
  
  [self.context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics
               localizedReason:reasonString
                         reply:^(BOOL success, NSError * _Nullable error) {
                           if (success) {
                             // тут момент когда приложили отпечаток и он распознался
                             NSLog(@"Ololo");
                           } else {
                             dispatch_async(dispatch_get_main_queue(), ^{
                               self.errorInfoLabel.text = [error description];
                             });
                             NSLog(@"2. %@", [error description]);
                             // если пользователь вместо отпечатка решил ввести пароль, то прилетела ошибка Error Domain=com.apple.LocalAuthentication Code=-3 "Fallback authentication mechanism selected."
                           }
                         }];
}

- (void)zeroCountFingers {
  UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Yours iPhone haven't any fingers."
                                                                      message:@"Do you want to add it?"
                                                               preferredStyle:(UIAlertControllerStyleAlert)];
  
  UIAlertAction *success = [UIAlertAction actionWithTitle:@"Yes"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                    NSString *text = @"prefs:root=TOUCHID_PASSCODE";
                                                    NSURL* url = [NSURL URLWithString:text];
                                                    [[UIApplication sharedApplication] openURL:url];
                                                  }];
  
  UIAlertAction *failure = [UIAlertAction actionWithTitle:@"No"
                                                    style:UIAlertActionStyleDestructive
                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                    [self.navigationController popToRootViewControllerAnimated:YES];
                                                  }];
  
  [controller addAction:success];
  [controller addAction:failure];
  
  [self presentViewController:controller animated:YES completion:nil];
}

@end
