//
//  BKPasscodeInputView.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BKPasscodeField.h"

typedef enum : NSUInteger {
    BKPasscodeInputViewNumericPasscodeStyle,
    BKPasscodeInputViewNormalPasscodeStyle,
} BKPasscodeInputViewPasscodeStyle;

@protocol BKPasscodeInputViewDelegate;
@class LanguageSettings;

@interface BKPasscodeInputView : UIView <UITextFieldDelegate, BKPasscodeFieldDelegate, NSCopying>

@property (nonatomic, weak) id<BKPasscodeInputViewDelegate> delegate;

@property (nonatomic) BKPasscodeInputViewPasscodeStyle passcodeStyle;
@property (nonatomic) UIKeyboardType keyboardType;
@property (nonatomic) NSUInteger maximumLength;

@property (nonatomic, strong) LanguageSettings *language;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) UIFont *messageFont;
@property (nonatomic, strong) UIColor *messageColor;

@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, strong) UIFont *errorMessageFont;
@property (nonatomic, strong) UIColor *errorMessageColor;
@property (nonatomic, strong) UIColor *errorMessageBackgroundColor;

@property (nonatomic, getter = isEnabled) BOOL enabled;
@property (nonatomic, strong) NSString *passcode;

@property (nonatomic, strong, readonly) UIControl *passcodeField;
@property (nonatomic, strong) UIColor *dotColor;

+ (void)configureTitleLabel:(UILabel *)aLabel;
+ (void)configureMessageLabel:(UILabel *)aLabel;
+ (void)configureErrorMessageLabel:(UILabel *)aLabel;

- (CGFloat)labelPasscodeSpace;

@end

@protocol BKPasscodeInputViewDelegate <NSObject>

/**
 * Tells the delegate that maximum length of passcode is entered or user tapped Done button in the keyboard (in case of BKPasscodeInputViewNormalPasscodeStyle).
 */
- (void)passcodeInputViewDidFinish:(BKPasscodeInputView *)aInputView;

@end

@interface LanguageSettings : NSObject

@property (nonatomic, strong) NSString *enter_old_passcode;
@property (nonatomic, strong) NSString *enter_your_passcode;

@property (nonatomic, strong) NSString *enter_new_passcode;
@property (nonatomic, strong) NSString *enter_a_passcode;

@property (nonatomic, strong) NSString *re_enter_passcode;

@property (nonatomic, strong) NSString *invalid_passcode;
@property (nonatomic, strong) NSString *failed_passcode_attempt;
@property (nonatomic, strong) NSString *failed_passcode_attempts;

@property (nonatomic, strong) NSString *enter_different_passcode;
@property (nonatomic, strong) NSString *enter_existed_passcode;
@property (nonatomic, strong) NSString *passcode_not_match;

@property (nonatomic, strong) NSString *try_again_minute;
@property (nonatomic, strong) NSString *try_again_minutes;

- (id)init;

@end
