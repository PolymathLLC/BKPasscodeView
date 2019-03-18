//
//  BKPasscodeViewController.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeViewController.h"
#import "BKShiftingView.h"
#import "AFViewShaker.h"
#import "BKPasscodeUtils.h"

typedef enum : NSUInteger {
    BKPasscodeViewControllerStateUnknown,
    BKPasscodeViewControllerStateCheckPassword,
    BKPasscodeViewControllerStateInputPassword,
    BKPasscodeViewControllerStateReinputPassword
} BKPasscodeViewControllerState;

#define kBKPasscodeOneMinuteInSeconds           (60)
#define kBKPasscodeDefaultKeyboardHeight        (216)

@interface BKPasscodeViewController ()

@property (nonatomic, assign) BKPasscodeViewControllerState currentState;
@property (nonatomic, strong) NSString *oldPasscode;
@property (nonatomic, strong) NSString *theNewPasscode;
@property (nonatomic, strong) NSTimer *lockStateUpdateTimer;

@property (nonatomic, strong) BKShiftingView *shiftingView;
@property (nonatomic, strong) AFViewShaker *viewShaker;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *cancelButton, *skipButton;

@property (nonatomic, assign) CGFloat keyboardHeight;
@property (nonatomic, assign) BOOL promptingTouchID;

@end

@implementation BKPasscodeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // init state
        _type = BKPasscodeViewControllerNewPasscodeType;
        _currentState = BKPasscodeViewControllerStateInputPassword;
        
        // create shifting view
        self.shiftingView = [[BKShiftingView alloc] init];
        self.shiftingView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.shiftingView.currentView = [self instantiatePasscodeInputView];
        
        // title label
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        // cancel button
        self.cancelButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.cancelButton.bounds = CGRectMake(0.0, 0.0, 60.0, 44.0);
        self.cancelButton.hidden = YES;
        [self.cancelButton addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        // cancel button
        self.skipButton = [UIButton buttonWithType:UIButtonTypeSystem];
        self.skipButton.bounds = CGRectMake(0.0, 0.0, 60.0, 44.0);
        self.skipButton.hidden = YES;
        [self.skipButton addTarget:self action:@selector(touchCancel:) forControlEvents:UIControlEventTouchUpInside];
        
        // keyboard notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardWillShowHideNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardWillShowHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveKeyboardDidShowNotification:) name:UIKeyboardDidShowNotification object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveApplicationWillEnterForegroundNotification:) name:UIApplicationWillEnterForegroundNotification object:nil];
        
        self.keyboardHeight = kBKPasscodeDefaultKeyboardHeight;
        self.backgroundColor = UIColor.whiteColor;
        
        self.cancelButton.backgroundColor = UIColor.greenColor;
        self.skipButton.backgroundColor = UIColor.greenColor;
    }
    return self;
}

- (void)setCancelButtonTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color
{
    [self.cancelButton setTitle:title forState:UIControlStateNormal];
    self.cancelButton.titleLabel.font = font;
    self.cancelButton.tintColor = color;
}
    
- (void)setSkipButtonTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color
{
    [self.skipButton setTitle:title forState:UIControlStateNormal];
    self.skipButton.titleLabel.font = font;
    self.skipButton.tintColor = color;
}

- (void)setTitleLabelTitle:(NSString *)title font:(UIFont *)font color:(UIColor *)color
{
    self.titleLabel.text = title;
    self.titleLabel.font = font;
    self.titleLabel.textColor = color;
    
    [self.titleLabel sizeToFit];
    [self configTitleLabelFrame];
}

- (void)dealloc
{
    [self.lockStateUpdateTimer invalidate];
    self.lockStateUpdateTimer = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setType:(BKPasscodeViewControllerType)type
{
    if (_type == type) {
        return;
    }
    
    _type = type;
    
    switch (type) {
        case BKPasscodeViewControllerNewPasscodeType:
            self.currentState = BKPasscodeViewControllerStateInputPassword;
            break;
        default:
            self.currentState = BKPasscodeViewControllerStateCheckPassword;
            break;
    }
}

- (BKPasscodeInputView *)passcodeInputView
{
    if (NO == [self.shiftingView.currentView isKindOfClass:[BKPasscodeInputView class]]) {
        return nil;
    }
    
    return (BKPasscodeInputView *)self.shiftingView.currentView;
}

- (BKPasscodeInputView *)instantiatePasscodeInputView
{
    BKPasscodeInputView *view = [[BKPasscodeInputView alloc] init];
    view.delegate = self;
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    return view;
}

- (void)customizePasscodeInputView:(BKPasscodeInputView *)aPasscodeInputView
{
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.view setBackgroundColor:self.backgroundColor];
    
    [self updatePasscodeInputViewTitle:self.passcodeInputView];
    [self customizePasscodeInputView:self.passcodeInputView];
    
    [self.view addSubview:self.shiftingView];
    [self.view addSubview:self.titleLabel];
    
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.skipButton];
    
    [self lockIfNeeded];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.passcodeInputView.isEnabled) {
        [self startTouchIDAuthenticationIfPossible];
    }
    
    [self.passcodeInputView becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.view endEditing:YES];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGFloat topBarOffset = 0.0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        topBarOffset = [self.topLayoutGuide length];
    }
    
    CGRect frame = CGRectZero;
    
    frame = self.view.bounds;
    frame.origin.y += topBarOffset;
    frame.size.height -= (topBarOffset + self.keyboardHeight);
    self.shiftingView.frame = frame;

    [self configTitleLabelFrame];
}

- (void)configTitleLabelFrame
{
    CGFloat topBarOffset = 0;
    if ([self respondsToSelector:@selector(topLayoutGuide)]) {
        topBarOffset = [self.topLayoutGuide length];
    }
    
    CGRect frame = self.titleLabel.frame;
    frame.origin.x = (self.view.bounds.size.width - frame.size.width)/2.0;
    frame.origin.y = topBarOffset + [self.passcodeInputView labelPasscodeSpace]*1.5;
    self.titleLabel.frame = frame;
}

#pragma mark - Public methods

- (void)setPasscodeStyle:(BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    self.passcodeInputView.passcodeStyle = passcodeStyle;
}

- (BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    return self.passcodeInputView.passcodeStyle;
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    self.passcodeInputView.keyboardType = keyboardType;
}

- (UIKeyboardType)keyboardType
{
    return self.passcodeInputView.keyboardType;
}

- (void)showLockMessageWithLockUntilDate:(NSDate *)lockUntil
{
    NSTimeInterval timeInterval = [lockUntil timeIntervalSinceNow];
    NSUInteger minutes = ceilf(timeInterval / 60.0f);
    
    BKPasscodeInputView *inputView = self.passcodeInputView;
    inputView.enabled = NO;
    
    if (minutes == 1) {
        inputView.title = self.passcodeInputView.language.try_again_minute;
    } else {
        inputView.title = [NSString stringWithFormat:self.passcodeInputView.language.try_again_minutes, minutes];
    }
    
    NSUInteger numberOfFailedAttempts = [self.delegate passcodeViewControllerNumberOfFailedAttempts:self];
    
    [self showFailedAttemptsCount:numberOfFailedAttempts inputView:inputView];
    
    if (self.lockStateUpdateTimer == nil) {
        NSTimeInterval delay = timeInterval + kBKPasscodeOneMinuteInSeconds - (kBKPasscodeOneMinuteInSeconds * (NSTimeInterval)minutes);
        self.lockStateUpdateTimer = [[NSTimer alloc] initWithFireDate:[NSDate dateWithTimeIntervalSinceNow:delay]
                                                             interval:60.f
                                                               target:self
                                                             selector:@selector(lockStateUpdateTimerFired:)
                                                             userInfo:nil
                                                              repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:self.lockStateUpdateTimer forMode:NSDefaultRunLoopMode];
    }
}

- (BOOL)lockIfNeeded
{
    if (self.currentState != BKPasscodeViewControllerStateCheckPassword) {
        return NO;
    }
    
    if (NO == [self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
        return NO;
    }
    
    NSDate *lockUntil = [self.delegate passcodeViewControllerLockUntilDate:self];
    if (lockUntil == nil || [lockUntil timeIntervalSinceNow] < 0) {
        return NO;
    }
    
    [self showLockMessageWithLockUntilDate:lockUntil];
    
    return YES;
}

- (void)updateLockMessageOrUnlockIfNeeded
{
    if (self.currentState != BKPasscodeViewControllerStateCheckPassword) {
        return;
    }
    
    if (NO == [self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
        return;
    }
    
    BKPasscodeInputView *inputView = self.passcodeInputView;
    
    NSDate *lockUntil = [self.delegate passcodeViewControllerLockUntilDate:self];
    
    if (lockUntil == nil || [lockUntil timeIntervalSinceNow] < 0) {
        
        // invalidate timer
        [self.lockStateUpdateTimer invalidate];
        self.lockStateUpdateTimer = nil;
        
        [self updatePasscodeInputViewTitle:inputView];
        inputView.enabled = YES;
        
    } else {
        [self showLockMessageWithLockUntilDate:lockUntil];
    }
}

- (void)lockStateUpdateTimerFired:(NSTimer *)timer
{
    [self updateLockMessageOrUnlockIfNeeded];
}

- (void)startTouchIDAuthenticationIfPossible
{
    [self startTouchIDAuthenticationIfPossible:nil];
}

- (void)startTouchIDAuthenticationIfPossible:(void (^)(BOOL))aCompletionBlock
{
    if (NO == [self canAuthenticateWithTouchID]) {
        if (aCompletionBlock) {
            aCompletionBlock(NO);
        }
        return;
    }
    
    self.promptingTouchID = YES;
    
    [self.touchIDManager loadPasscodeWithCompletionBlock:^(NSString *passcode) {
        
        self.promptingTouchID = NO;
        
        if (passcode) {
            self.passcodeInputView.passcode = passcode;
            [self passcodeInputViewDidFinish:self.passcodeInputView];
        }
        
        if (aCompletionBlock) {
            aCompletionBlock(YES);
        }
    }];
}

#pragma mark - Private methods

- (void)updatePasscodeInputViewTitle:(BKPasscodeInputView *)passcodeInputView
{
    switch (self.currentState) {
        case BKPasscodeViewControllerStateCheckPassword:
            if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                passcodeInputView.title = self.passcodeInputView.language.enter_old_passcode;
            }
            else {
                passcodeInputView.title = self.passcodeInputView.language.enter_your_passcode;
            }
            break;
            
        case BKPasscodeViewControllerStateInputPassword:
            if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                passcodeInputView.title = self.passcodeInputView.language.enter_new_passcode;
            }
            else {
                passcodeInputView.title = self.passcodeInputView.language.enter_a_passcode;
            }
            break;
            
        case BKPasscodeViewControllerStateReinputPassword:
            passcodeInputView.title = self.passcodeInputView.language.re_enter_passcode;
            break;
            
        default:
            break;
    }
    
    passcodeInputView.language = self.passcodeInputView.language;
    
    passcodeInputView.titleFont = self.passcodeInputView.titleFont;
    passcodeInputView.titleColor = self.passcodeInputView.titleColor;
    
    passcodeInputView.messageFont = self.passcodeInputView.messageFont;
    passcodeInputView.messageColor = self.passcodeInputView.messageColor;
    
    passcodeInputView.errorMessageFont = self.passcodeInputView.errorMessageFont;
    passcodeInputView.errorMessageColor = self.passcodeInputView.errorMessageColor;
    passcodeInputView.errorMessageBackgroundColor = self.passcodeInputView.errorMessageBackgroundColor;
    
    passcodeInputView.dotColor = self.passcodeInputView.dotColor;
}

- (void)showFailedAttemptsCount:(NSUInteger)failCount inputView:(BKPasscodeInputView *)aInputView
{
    if (failCount == 0) {
        aInputView.errorMessage = self.passcodeInputView.language.invalid_passcode;
    }
    else if (failCount == 1) {
        aInputView.errorMessage = self.passcodeInputView.language.failed_passcode_attempt;
    }
    else {
        aInputView.errorMessage = [NSString stringWithFormat:self.passcodeInputView.language.failed_passcode_attempt, failCount];
    }
}

- (void)showTouchIDSwitchView
{
    BKTouchIDSwitchView *view = [[BKTouchIDSwitchView alloc] init];
    view.delegate = self;
    view.touchIDSwitch.on = self.touchIDManager.isTouchIDEnabled;
    
    [self.shiftingView showView:view withDirection:BKShiftingDirectionForward];
}

- (BOOL)canAuthenticateWithTouchID
{
    if (NO == [BKTouchIDManager canUseTouchID]) {
        return NO;
    }
    
    if (self.type != BKPasscodeViewControllerCheckPasscodeType) {
        return NO;
    }
    
    if (nil == self.touchIDManager || NO == self.touchIDManager.isTouchIDEnabled) {
        return NO;
    }
    
    if (self.promptingTouchID) {
        return NO;
    }
    
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateInactive) {
        return NO;
    }
    
    return YES;
}

#pragma mark - BKPasscodeInputViewDelegate

- (void)passcodeInputViewDidFinish:(BKPasscodeInputView *)aInputView
{
    NSString *passcode = aInputView.passcode;
    
    switch (self.currentState) {
        case BKPasscodeViewControllerStateCheckPassword:
        {
            NSAssert([self.delegate respondsToSelector:@selector(passcodeViewController:authenticatePasscode:resultHandler:)],
                     @"delegate must implement passcodeViewController:authenticatePasscode:resultHandler:");
            
            [self.delegate passcodeViewController:self authenticatePasscode:passcode resultHandler:^(BOOL succeed) {
                NSAssert([NSThread isMainThread], @"you must invoke result handler in main thread.");
                if (succeed) {
                    if (self.type == BKPasscodeViewControllerChangePasscodeType) {
                        self.oldPasscode = passcode;
                        self.currentState = BKPasscodeViewControllerStateInputPassword;
                        
                        BKPasscodeInputView *newPasscodeInputView = [self.passcodeInputView copy];
                        
                        [self customizePasscodeInputView:newPasscodeInputView];
                        [self updatePasscodeInputViewTitle:newPasscodeInputView];
                        [self.shiftingView showView:newPasscodeInputView withDirection:BKShiftingDirectionForward];
                        
                        [self.passcodeInputView becomeFirstResponder];
                    }
                    else {
                        [self.delegate passcodeViewController:self didFinishWithPasscode:passcode];
                    }
                }
                else {
                    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidFailAttempt:)]) {
                        [self.delegate passcodeViewControllerDidFailAttempt:self];
                    }
                    
                    NSUInteger failCount = 0;
                    
                    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerNumberOfFailedAttempts:)]) {
                        failCount = [self.delegate passcodeViewControllerNumberOfFailedAttempts:self];
                    }
                    
                    [self showFailedAttemptsCount:failCount inputView:aInputView];
                    
                    // reset entered passcode
                    aInputView.passcode = nil;
                    
                    // shake
                    self.viewShaker = [[AFViewShaker alloc] initWithView:aInputView.passcodeField];
                    [self.viewShaker shakeWithDuration:0.5f completion:nil];
                    
                    // lock if needed
                    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerLockUntilDate:)]) {
                        NSDate *lockUntilDate = [self.delegate passcodeViewControllerLockUntilDate:self];
                        if (lockUntilDate != nil) {
                            [self showLockMessageWithLockUntilDate:lockUntilDate];
                        }
                    }
                }
            }];
            
            break;
        }
        case BKPasscodeViewControllerStateInputPassword:
        {
            if (self.type == BKPasscodeViewControllerChangePasscodeType && [self.oldPasscode isEqualToString:passcode]) {
                aInputView.passcode = nil;
                aInputView.message = self.passcodeInputView.language.enter_different_passcode;
            }
            else if (self.type == BKPasscodeViewControllerNewPasscodeType || self.type == BKPasscodeViewControllerChangePasscodeType) {
                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidEnterExistedPasscode:passcode:)] && [self.delegate passcodeViewControllerDidEnterExistedPasscode:self passcode:passcode])
                {
                    self.viewShaker = [[AFViewShaker alloc] initWithView:aInputView.passcodeField];
                    [self.viewShaker shakeWithDuration:0.5f completion:nil];
                    
                    aInputView.passcode = nil;
                    
                    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerExistedPasscodeWarning)]) {
                        aInputView.message = [self.delegate passcodeViewControllerExistedPasscodeWarning];
                    }
                    else {
                        aInputView.message = self.passcodeInputView.language.enter_existed_passcode;
                    }
                }
                else {
                    self.theNewPasscode = passcode;
                    self.currentState = BKPasscodeViewControllerStateReinputPassword;
                    
                    BKPasscodeInputView *newPasscodeInputView = [self.passcodeInputView copy];
                    
                    [self customizePasscodeInputView:newPasscodeInputView];
                    [self updatePasscodeInputViewTitle:newPasscodeInputView];
                    [self.shiftingView showView:newPasscodeInputView withDirection:BKShiftingDirectionForward];
                    
                    [self.passcodeInputView becomeFirstResponder];
                }
            }
            
            break;
        }
        case BKPasscodeViewControllerStateReinputPassword:
        {
            if ([passcode isEqualToString:self.theNewPasscode]) {
                if (self.touchIDManager && [BKTouchIDManager canUseTouchID]) {
                    [self showTouchIDSwitchView];
                }
                else {
                    [self.delegate passcodeViewController:self didFinishWithPasscode:passcode];
                }
            }
            else {
                self.currentState = BKPasscodeViewControllerStateInputPassword;
                
                BKPasscodeInputView *newPasscodeInputView = [self.passcodeInputView copy];
                
                [self customizePasscodeInputView:newPasscodeInputView];
                [self updatePasscodeInputViewTitle:newPasscodeInputView];
                
                newPasscodeInputView.message = self.passcodeInputView.language.passcode_not_match;
                [self.shiftingView showView:newPasscodeInputView withDirection:BKShiftingDirectionBackward];
                [self.passcodeInputView becomeFirstResponder];
            }
            break;
        }
        default:
            break;
    }
}

#pragma mark - BKTouchIDSwitchViewDelegate

- (void)touchIDSwitchViewDidPressDoneButton:(BKTouchIDSwitchView *)view
{
    BOOL enabled = view.touchIDSwitch.isOn;
    
    if (enabled) {
        [self.touchIDManager savePasscode:self.theNewPasscode completionBlock:^(BOOL success) {
            if (success) {
                [self.delegate passcodeViewController:self didFinishWithPasscode:self.theNewPasscode];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidFailTouchIDKeychainOperation:)]) {
                    [self.delegate passcodeViewControllerDidFailTouchIDKeychainOperation:self];
                }
            }
        }];
    }
    else {
        [self.touchIDManager deletePasscodeWithCompletionBlock:^(BOOL success) {
            if (success) {
                [self.delegate passcodeViewController:self didFinishWithPasscode:self.theNewPasscode];
            }
            else {
                if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidFailTouchIDKeychainOperation:)]) {
                    [self.delegate passcodeViewControllerDidFailTouchIDKeychainOperation:self];
                }
            }
        }];
    }
}

#pragma mark - Notifications

- (void)didReceiveKeyboardWillShowHideNotification:(NSNotification *)notification
{
    self.cancelButton.hidden = NO;
    self.skipButton.hidden = !self.canSkip;
    
    self.cancelButton.frame = (CGRect){CGPointMake(0.0, self.view.bounds.size.height - self.cancelButton.bounds.size.height), self.cancelButton.bounds.size};
    self.skipButton.frame = (CGRect){CGPointMake(self.view.bounds.size.width - self.skipButton.bounds.size.width, self.view.bounds.size.height - self.skipButton.bounds.size.height), self.skipButton.bounds.size};
    
    CGRect keyboardRect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    if (SYSTEM_VERSION_LESS_THAN(@"8.0")) {
        UIInterfaceOrientation statusBarOrientation = [[UIApplication sharedApplication] statusBarOrientation];
        self.keyboardHeight = UIInterfaceOrientationIsPortrait(statusBarOrientation) ? CGRectGetHeight(keyboardRect) : CGRectGetWidth(keyboardRect);
    }
    else {
        self.keyboardHeight = CGRectGetHeight(keyboardRect);
    }
    
    [self.view setNeedsLayout];
}

- (void)didReceiveKeyboardDidShowNotification:(NSNotification *)notification
{
    self.cancelButton.frame = (CGRect){CGPointMake(0.0, self.view.bounds.size.height - self.keyboardHeight - self.cancelButton.bounds.size.height), self.cancelButton.bounds.size};
    self.skipButton.frame = (CGRect){CGPointMake(self.view.bounds.size.width - self.skipButton.bounds.size.width, self.view.bounds.size.height - self.keyboardHeight - self.skipButton.bounds.size.height), self.skipButton.bounds.size};
}

- (void)didReceiveApplicationWillEnterForegroundNotification:(NSNotification *)notification
{
    [self startTouchIDAuthenticationIfPossible];
}

#pragma mark - Action

- (void)touchCancel:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidCancel:)]) {
        [self.delegate passcodeViewControllerDidCancel:self];
    }
}
    
    - (void)touchSkip:(id)sender
    {
        if ([self.delegate respondsToSelector:@selector(passcodeViewControllerDidSkip:)]) {
            [self.delegate passcodeViewControllerDidSkip:self];
        }
    }

@end
