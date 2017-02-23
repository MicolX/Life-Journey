//
//  LJPasswordViewController.m
//  Life Journey
//
//  Created by Michael_Xiong on 24/11/2016.
//  Copyright © 2016 Michael_Hong. All rights reserved.
//

#import "LJPasswordViewController.h"
#import "passwordStore.h"

#define MAX_LENGTH                                  4
#define IMAGE_UNENTERED                             [UIImage imageNamed:@"unentered"]
#define IMAGE_ENTERED                               [UIImage imageNamed:@"entered"]

@interface LJPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *textField;
@property (weak, nonatomic) IBOutlet UIImageView *ImageViewone;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewTwo;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewThree;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewFour;
@property (weak, nonatomic) IBOutlet UILabel *hint;
@property (nonatomic, strong) NSString *password;
@property (nonatomic)BOOL isChangeMode;
@property (nonatomic)BOOL isSwitchOn;
@property (nonatomic)BOOL forInitial;
@property (nonatomic)NSInteger length;
@property (nonatomic)BOOL touchIDIsTemporarilyOff;//this is for当用户取消touchid选择输入密码时，暂时关闭touchid已防止反复弹出，等密码试图dismiss时再重新打开

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewOneLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewTwoLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewThreeLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewFourLeading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageViewWidth;


@end

@implementation LJPasswordViewController

- (instancetype)initWithSwitchOn:(BOOL)switcha changeMode:(BOOL)change forInitial:(BOOL)initial
{
    if (self = [super init]) {
        
        self.isChangeMode = change;
        self.isSwitchOn = switcha;
        self.forInitial = initial;
        self.touchIDIsTemporarilyOff = NO;
        self.length = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.textField addTarget:self
                       action:@selector(textFieldChanged)
             forControlEvents:UIControlEventEditingChanged];
    [self.textField becomeFirstResponder];
    self.ImageViewone.image = IMAGE_UNENTERED;
    self.imageViewTwo.image = IMAGE_UNENTERED;
    self.imageViewThree.image = IMAGE_UNENTERED;
    self.imageViewFour.image = IMAGE_UNENTERED;
    if (self.isSwitchOn && !self.isChangeMode && !self.forInitial) {
        self.hint.text = NSLocalizedString(@"Please set your password", nil);
    } else {
        self.hint.text = NSLocalizedString(@"Please enter your password", nil);
    }
    
    //touchID
    if ([[passwordStore sharedStore] touchIDEnabled] && !self.isChangeMode) {
        [self authenticateUser];
    }

}


- (void)viewWillDisappear:(BOOL)animated
{
    [self.textField resignFirstResponder];
}

- (void)textFieldChanged
{
    switch (self.textField.text.length) {
        case 0:
            if (![self checkIfTextLengthIsIncreasing]) {
                self.ImageViewone.image = IMAGE_UNENTERED;
            }
            
        case 1:
            if ([self checkIfTextLengthIsIncreasing]) {
                self.ImageViewone.image = IMAGE_ENTERED;
            } else {
                self.imageViewTwo.image = IMAGE_UNENTERED;
            }
            
            break;
            
        case 2:
            if ([self checkIfTextLengthIsIncreasing]) {
                self.imageViewTwo.image = IMAGE_ENTERED;
            } else {
                self.imageViewThree.image = IMAGE_UNENTERED;
            }
            break;
        
        case 3:
            if ([self checkIfTextLengthIsIncreasing]) {
                self.imageViewThree.image = IMAGE_ENTERED;
            } else {
                self.imageViewThree.image = IMAGE_UNENTERED;
            }
            break;
            
        case 4:
            self.imageViewFour.image = IMAGE_ENTERED;
            self.password = self.textField.text;
            
            //for initial
            if (self.forInitial) {
                if ([[passwordStore sharedStore] verify:self.password]) {
                    [self dismissViewControllerAnimated:YES completion:NULL];
                    if (self.touchIDIsTemporarilyOff) {
                        [[passwordStore sharedStore] setTouchIDEnabled:YES];
                    }
                    break;
                } else {
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    [self shakeAnimation];
                    self.textField.text = @"";
                    self.length = 0;
                    self.ImageViewone.image = IMAGE_UNENTERED;
                    self.imageViewTwo.image = IMAGE_UNENTERED;
                    self.imageViewThree.image = IMAGE_UNENTERED;
                    self.imageViewFour.image = IMAGE_UNENTERED;
                    break;
                }
            }
            
            //change password
            if (self.isChangeMode) {
                
                //verify password
                if ([[passwordStore sharedStore] verify:self.password]) {
                    
                    //password is right
                    self.textField.text = @"";
                    self.length = 0;
                    self.hint.text = NSLocalizedString(@"Please enter your new password", nil);
                    self.isChangeMode = NO;
                    self.ImageViewone.image = IMAGE_UNENTERED;
                    self.imageViewTwo.image = IMAGE_UNENTERED;
                    self.imageViewThree.image = IMAGE_UNENTERED;
                    self.imageViewFour.image = IMAGE_UNENTERED;
                    break;
                    
                } else { //password is wrong, dismiss
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:NSLocalizedString(@"Wrong password", nil) preferredStyle:UIAlertControllerStyleAlert];
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
                        [self dismissViewControllerAnimated:YES completion:NULL];
                    }]];
                    [self presentViewController:alert animated:YES completion:NULL];
                    break;
                }
            }
            
            //turn off password
            if (!self.isSwitchOn) {
                
                //verify password
                if ([[passwordStore sharedStore] verify:self.password]) {

                    //correct, dismiss and set password to nil
                    [[passwordStore sharedStore] setThePassword:nil];
                    [self dismissViewControllerAnimated:YES completion:NULL];
                } else {
                    //wrong, dismiss
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil
                                                                                   message:NSLocalizedString(@"Wrong password", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    
                    [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                              style:UIAlertActionStyleCancel
                                                            handler:^(UIAlertAction *action){
                                                                [self dismissViewControllerAnimated:YES completion:NULL];
                                                            }]];
                    [self presentViewController:alert animated:YES completion:NULL];
                }
            } else {
                [[passwordStore sharedStore] setThePassword:self.password];
                [self dismissViewControllerAnimated:YES completion:NULL];
            }
            break;
            
        default:
            break;
    }
}

     
- (BOOL)checkIfTextLengthIsIncreasing
{
    if (self.textField.text.length > self.length) {
        self.length = self.textField.text.length;
        return YES;
    } else {
        self.length = self.textField.text.length;
        return NO;
    }
}

- (void)shakeAnimation
{
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    //设置抖动幅度
    shake.fromValue = @+0.1;
    shake.toValue = @-0.1;
    shake.duration = 0.1;
    shake.autoreverses = YES;
    shake.repeatCount = 4;
    [self.ImageViewone.layer addAnimation:shake forKey:@"imageViewOne"];
    [self.imageViewTwo.layer addAnimation:shake forKey:@"imageViewTwo"];
    [self.imageViewThree.layer addAnimation:shake forKey:@"imageViewThree"];
    [self.imageViewFour.layer addAnimation:shake forKey:@"imageViewFour"];
}

- (void)authenticateUser
{
    //initialize context
    LAContext *context = [[LAContext alloc] init];
    
    //error object
    NSError *error = nil;
    NSString *result = NSLocalizedString(@"Authentication is needed to access your journals.", nil);
    
    //use canEvaluatePolicy to see if the device support for this status
    if ([context canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:&error]) {
        //touchID is supported
        [context evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:result reply:^(BOOL success, NSError *error){
           //success
            if (success) {
                [[passwordStore sharedStore] setAuthenticationPassed:YES];
                self.ImageViewone.image = IMAGE_ENTERED;
                self.imageViewTwo.image = IMAGE_ENTERED;
                self.imageViewThree.image = IMAGE_ENTERED;
                self.imageViewFour.image = IMAGE_ENTERED;
                if (!self.isSwitchOn) {
                    [[passwordStore sharedStore] setThePassword:nil];
                    [[passwordStore sharedStore] setTouchIDEnabled:NO];
                }
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                if (error.code == kLAErrorUserFallback || error.code == kLAErrorUserCancel) {
                    [[passwordStore sharedStore] setTouchIDEnabled:NO];
                    self.touchIDIsTemporarilyOff = YES;
                }
            }
        }];
    }
}

- (void)updateViewConstraints
{
    [self autoArrangeBoxWithConstraint:@[self.imageViewOneLeading,
                                         self.imageViewTwoLeading,
                                         self.imageViewThreeLeading,
                                         self.imageViewFourLeading]
                                 width:self.imageViewWidth.constant];
    
    [super updateViewConstraints];
}

- (void)autoArrangeBoxWithConstraint:(NSArray *)constraintArray width:(CGFloat)width
{
    CGFloat step = (self.view.frame.size.width - (width * constraintArray.count)) / (constraintArray.count + 1);
    for (int i = 0; i < constraintArray.count; i++) {
        NSLayoutConstraint *constraint = constraintArray[i];
        constraint.constant = step * (i + 1) + width * i;
    }
}


@end
