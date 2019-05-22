//
//  BKPasscodeInputView.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeInputView.h"

#import "BKPasscodeUtils.h"

@interface BKPasscodeInputView () {
    BOOL _isKeyboardTypeSet;
}

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *messageLabel;
@property (nonatomic, strong) UILabel *errorMessageLabel;
@property (nonatomic, strong) UIControl *passcodeField;

@end

@implementation BKPasscodeInputView

@synthesize maximumLength = _maximumLength;
@synthesize keyboardType = _keyboardType;
@synthesize passcodeField = _passcodeField;

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    
    _enabled = YES;
    _passcodeStyle = BKPasscodeInputViewNumericPasscodeStyle;
    _keyboardType = UIKeyboardTypeNumberPad;
    _maximumLength = 0;
    _language = [[LanguageSettings alloc] init];
    
    _titleLabel = [[UILabel alloc] init];
    [[self class] configureTitleLabel:_titleLabel];
    [self addSubview:_titleLabel];
    
    _messageLabel = [[UILabel alloc] init];
    [[self class] configureMessageLabel:_messageLabel];
    [self addSubview:_messageLabel];
    
    _errorMessageLabel = [[UILabel alloc] init];
    [[self class] configureErrorMessageLabel:_errorMessageLabel];
    _errorMessageLabel.hidden = YES;
    [self addSubview:_errorMessageLabel];
}
    
- (CGRect)titleFrame
{
    return self.titleLabel.frame;
}

+ (void)configureTitleLabel:(UILabel *)aLabel
{
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.numberOfLines = 2;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.font = [UIFont boldSystemFontOfSize:15.0f];
}

+ (void)configureMessageLabel:(UILabel *)aLabel
{
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.font = [UIFont systemFontOfSize:15.0f];
}

+ (void)configureErrorMessageLabel:(UILabel *)aLabel
{
    aLabel.backgroundColor = [UIColor clearColor];
    aLabel.numberOfLines = 0;
    aLabel.textAlignment = NSTextAlignmentCenter;
    aLabel.lineBreakMode = NSLineBreakByWordWrapping;
    aLabel.backgroundColor = [UIColor colorWithRed:0.63 green:0.2 blue:0.13 alpha:1];
    aLabel.textColor = [UIColor whiteColor];
    aLabel.font = [UIFont systemFontOfSize:15.0f];
    
    aLabel.layer.cornerRadius = 10.0f;
    aLabel.layer.masksToBounds = YES;
}

- (void)setPasscodeStyle:(BKPasscodeInputViewPasscodeStyle)passcodeStyle
{
    if (_passcodeStyle != passcodeStyle) {
        _passcodeStyle = passcodeStyle;

        if (_passcodeField) {
            _passcodeField = nil;
            [self passcodeField];
        }
    }
}

- (UIControl *)passcodeField
{
    if (_passcodeField == nil) {
        switch (_passcodeStyle) {
            case BKPasscodeInputViewNumericPasscodeStyle:
            {
                if (_maximumLength == 0) {
                    _maximumLength = kDefaultNumericPasscodeMaximumLength;
                }
                
                if (NO == _isKeyboardTypeSet) {
                    _keyboardType = UIKeyboardTypeNumberPad;
                }
                
                BKPasscodeField *passcodeField = [[BKPasscodeField alloc] init];
                passcodeField.delegate = self;
                passcodeField.keyboardType = _keyboardType;
                passcodeField.maximumLength = _maximumLength;
                passcodeField.dotColor = _dotColor;
                passcodeField.disableSecure = _disableSecure;
                [passcodeField addTarget:self action:@selector(passcodeControlEditingChanged:) forControlEvents:UIControlEventEditingChanged];
                [self setPasscodeField:passcodeField];
                
                break;
            }
                
            case BKPasscodeInputViewNormalPasscodeStyle:
            {
                if (_maximumLength == 0) {
                    _maximumLength = kDefaultNormalPasscodeMaximumLength;
                }
                
                if (NO == _isKeyboardTypeSet) {
                    _keyboardType = UIKeyboardTypeASCIICapable;
                }
                
                UITextField *textField = [[UITextField alloc] init];
                textField.delegate = self;
                textField.borderStyle = UITextBorderStyleRoundedRect;
                textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
                textField.autocorrectionType = UITextAutocorrectionTypeNo;
                textField.spellCheckingType = UITextSpellCheckingTypeNo;
                textField.enablesReturnKeyAutomatically = YES;
                textField.keyboardType = _keyboardType;
                textField.secureTextEntry = YES;
                textField.font = [UIFont systemFontOfSize:25.0f];
                textField.clearButtonMode = UITextFieldViewModeWhileEditing;
                textField.returnKeyType = UIReturnKeyDone;
                
                [self setPasscodeField:textField];
                break;
            }
        }
    }
    
    return _passcodeField;
}

- (void)setPasscodeField:(UIControl *)passcodeField
{
    if (_passcodeField != passcodeField) {
        [_passcodeField removeFromSuperview];
        _passcodeField = passcodeField;
        
        if (_passcodeField) {
            [self addSubview:_passcodeField];
        }
        
        [self setNeedsLayout];
    }
}

- (void)setMaximumLength:(NSUInteger)maximumLength
{
    _maximumLength = maximumLength;
    
    if ([self.passcodeField isKindOfClass:[BKPasscodeField class]]) {
        [(BKPasscodeField *)self.passcodeField setMaximumLength:maximumLength];
    }
}

- (void)setDisableSecure:(BOOL)disableSecure
{
    _disableSecure = disableSecure;
    
    if ([self.passcodeField isKindOfClass:[BKPasscodeField class]]) {
        [(BKPasscodeField *)self.passcodeField setDisableSecure:disableSecure];
    }
}

- (void)setDotColor:(UIColor *)dotColor
{
    _dotColor = dotColor;
    
    if ([self.passcodeField isKindOfClass:[BKPasscodeField class]]) {
        [(BKPasscodeField *)self.passcodeField setDotColor:dotColor];
    }
}

- (void)setKeyboardType:(UIKeyboardType)keyboardType
{
    _isKeyboardTypeSet = YES;
    _keyboardType = keyboardType;
    [(id<UITextInputTraits>)self.passcodeField setKeyboardType:keyboardType];
}

- (void)setTitle:(NSString *)title
{
    self.titleLabel.text = title;
    [self setNeedsLayout];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

- (void)setMessage:(NSString *)message
{
    self.messageLabel.text = message;
    self.messageLabel.hidden = NO;
    
    self.errorMessageLabel.text = nil;
    self.errorMessageLabel.hidden = YES;
    
    [self setNeedsLayout];
}

- (NSString *)message
{
    return self.messageLabel.text;
}

- (void)setErrorMessage:(NSString *)errorMessage
{
    self.errorMessageLabel.text = errorMessage;
    self.errorMessageLabel.hidden = NO;
    
    self.messageLabel.text = nil;
    self.messageLabel.hidden = YES;
    
    [self setNeedsLayout];
}

- (NSString *)errorMessage
{
    return self.errorMessageLabel.text;
}

- (NSString *)passcode
{
    switch (self.passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
            return [(BKPasscodeField *)self.passcodeField passcode];
        case BKPasscodeInputViewNormalPasscodeStyle:
            return [(UITextField *)self.passcodeField text];
    }
}

- (void)setPasscode:(NSString *)passcode
{
    switch (self.passcodeStyle) {
        case BKPasscodeInputViewNumericPasscodeStyle:
            [(BKPasscodeField *)self.passcodeField setPasscode:passcode];
            break;
        case BKPasscodeInputViewNormalPasscodeStyle:
             [(UITextField *)self.passcodeField setText:passcode];
             break;
    }
}

- (void)clearPasscode
{
    self.passcode = nil;
}

- (void)resetPasscode
{
    if (self.disableSecure) {
        [self performSelector:@selector(clearPasscode) withObject:nil afterDelay:0.5];
    }
    else {
        [self clearPasscode];
    }
}

#pragma mark - Customizations

- (UIFont *)titleFont
{
    return self.titleLabel.font;
}

- (void)setTitleFont:(UIFont *)font
{
    self.titleLabel.font = font;
}

- (UIColor *)titleColor
{
    return self.titleLabel.textColor;
}

- (void)setTitleColor:(UIColor *)color
{
    self.titleLabel.textColor = color;
}

- (UIFont *)messageFont
{
    return self.messageLabel.font;
}

- (void)setMessageFont:(UIFont *)font
{
    self.messageLabel.font = font;
}

- (UIColor *)messageColor
{
    return self.messageLabel.textColor;
}

- (void)setMessageColor:(UIColor *)color
{
    self.messageLabel.textColor = color;
}

- (UIFont *)errorMessageFont
{
    return self.errorMessageLabel.font;
}

- (void)setErrorMessageFont:(UIFont *)font
{
    self.errorMessageLabel.font = font;
}

- (UIColor *)errorMessageColor
{
    return self.errorMessageLabel.textColor;
}

- (void)setErrorMessageColor:(UIColor *)color
{
    self.errorMessageLabel.textColor = color;
}

- (UIColor *)errorMessageBackgroundColor
{
    return self.errorMessageLabel.backgroundColor;
}

- (void)setErrorMessageBackgroundColor:(UIColor *)color
{
    self.errorMessageLabel.backgroundColor = color;
}

#pragma mark - UIView

- (CGFloat)labelPasscodeSpace
{
    return UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]) ? kLabelPasscodeSpacePortrait : kLabelPasscodeSpaceLandscape;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // layout passcode control to center
    [self.passcodeField sizeToFit];
    
    if ([self.passcodeField isKindOfClass:[UITextField class]]) {
        self.passcodeField.frame = CGRectMake(0, 0, self.frame.size.width - kTextLeftRightSpace * 2.0f, CGRectGetHeight(self.passcodeField.frame) + 10.0f);
    }
    self.passcodeField.center = CGPointMake(CGRectGetWidth(self.frame) * 0.5f, CGRectGetHeight(self.frame) * 0.5f);
    
    CGFloat maxTextWidth = self.frame.size.width - (kTextLeftRightSpace * 2.0f);
    CGFloat labelPasscodeSpace = [self labelPasscodeSpace];
    CGRect rect = CGRectZero;

    // layout title label
    _titleLabel.frame = CGRectMake(kTextLeftRightSpace, 0, maxTextWidth, self.frame.size.height);
    [_titleLabel sizeToFit];
    
    rect = _titleLabel.frame;
    rect.origin.x = floorf((self.frame.size.width - CGRectGetWidth(rect)) * 0.5f);
    rect.origin.y = CGRectGetMinY(self.passcodeField.frame) - labelPasscodeSpace - CGRectGetHeight(_titleLabel.frame);
    _titleLabel.frame = rect;
    
    // layout message label
    if (!_messageLabel.hidden) {
        _messageLabel.frame = CGRectMake(kTextLeftRightSpace, CGRectGetMaxY(self.passcodeField.frame) + labelPasscodeSpace, maxTextWidth, self.frame.size.height);
        [_messageLabel sizeToFit];
        
        rect = _messageLabel.frame;
        rect.origin.x = floorf((self.frame.size.width - CGRectGetWidth(rect)) * 0.5f);
        _messageLabel.frame = rect;
    }
    
    // layout error message label
    if (!_errorMessageLabel.hidden) {
        _errorMessageLabel.frame = CGRectMake(0, CGRectGetMaxY(self.passcodeField.frame) + labelPasscodeSpace,
                                              maxTextWidth - kErrorMessageLeftRightPadding * 2.0f,
                                              self.frame.size.height);
        [_errorMessageLabel sizeToFit];
        
        rect = _errorMessageLabel.frame;
        rect.size.width += (kErrorMessageLeftRightPadding * 2.0f);
        rect.size.height += (kErrorMessageTopBottomPadding * 2.0f);
        rect.origin.x = floorf((self.frame.size.width - rect.size.width) * 0.5f);
        _errorMessageLabel.frame = rect;
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return [self.passcodeField canBecomeFirstResponder];
}

- (BOOL)becomeFirstResponder
{
    return [self.passcodeField becomeFirstResponder];
}

- (BOOL)canResignFirstResponder
{
    return [self.passcodeField canResignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self.passcodeField becomeFirstResponder];
}

#pragma mark - Actions

- (void)passcodeControlEditingChanged:(id)sender
{
    if (![self.passcodeField isKindOfClass:[BKPasscodeField class]]) {
        return;
    }
    
    BKPasscodeField *passcodeField = (BKPasscodeField *)self.passcodeField;
    
    if (passcodeField.passcode.length == passcodeField.maximumLength) {
        if ([self.delegate respondsToSelector:@selector(passcodeInputViewDidFinish:)]) {
            [self.delegate passcodeInputViewDidFinish:self];
        }
    }
}

#pragma mark - BKPasscodeFieldDelegate

- (BOOL)passcodeField:(BKPasscodeField *)aPasscodeField shouldInsertText:(NSString *)aText
{
    return self.isEnabled;
}

- (BOOL)passcodeFieldShouldDeleteBackward:(BKPasscodeField *)aPasscodeField
{
    return self.isEnabled;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (self.isEnabled == NO) {
        return NO;
    }
    
    NSUInteger length = textField.text.length - range.length + string.length;
    if (length > self.maximumLength) {
        return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (self.isEnabled == NO) {
        return NO;
    }
    
    if ([self.delegate respondsToSelector:@selector(passcodeInputViewDidFinish:)]) {
        [self.delegate passcodeInputViewDidFinish:self];
        return NO;
    } else {
        return YES; // default behavior
    }
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    BKPasscodeInputView *view = [[[self class] alloc] initWithFrame:self.bounds];
    view.delegate = self.delegate;
    view.autoresizingMask = self.autoresizingMask;
    view.passcodeStyle = self.passcodeStyle;
    view.keyboardType = self.keyboardType;
    view.maximumLength = self.maximumLength;
    view.dotColor = self.dotColor;
    view.disableSecure = self.disableSecure;
    
    return view;
}

@end

@implementation LanguageSettings

- (id)init
{
    self = [super init];
    if (self) {
        _enter_old_passcode = NSLocalizedStringFromTable(@"Enter your old passcode", @"BKPasscodeView", @"기존 암호 입력");
        _enter_your_passcode = NSLocalizedStringFromTable(@"Enter your passcode", @"BKPasscodeView", @"암호 입력");
        
        _enter_new_passcode = NSLocalizedStringFromTable(@"Enter your new passcode", @"BKPasscodeView", @"새로운 암호 입력");
        _enter_a_passcode = NSLocalizedStringFromTable(@"Enter a passcode", @"BKPasscodeView", @"암호 입력");
        
        _re_enter_passcode = NSLocalizedStringFromTable(@"Re-enter your passcode", @"BKPasscodeView", @"암호 재입력");
        
        _invalid_passcode = NSLocalizedStringFromTable(@"Invalid Passcode", @"BKPasscodeView", @"잘못된 암호");
        _failed_passcode_attempt = NSLocalizedStringFromTable(@"1 Failed Passcode Attempt", @"BKPasscodeView", @"1번의 암호 입력 시도 실패");
        _failed_passcode_attempts = NSLocalizedStringFromTable(@"%d Failed Passcode Attempts", @"BKPasscodeView", @"%d번의 암호 입력 시도 실패");
        
        _enter_different_passcode = NSLocalizedStringFromTable(@"Enter a different passcode. Cannot re-use the same passcode.", @"BKPasscodeView", @"다른 암호를 입력하십시오. 동일한 암호를 다시 사용할 수 없습니다.");
        _enter_existed_passcode = NSLocalizedStringFromTable(@"Enter a different passcode. Cannot re-use the same passcode.", @"BKPasscodeView", @"다른 암호를 입력하십시오. 동일한 암호를 다시 사용할 수 없습니다.");
        _passcode_not_match = NSLocalizedStringFromTable(@"Passcodes did not match.\nTry again.", @"BKPasscodeView", @"암호가 일치하지 않습니다.\n다시 시도하십시오.");
        
        _try_again_minute = NSLocalizedStringFromTable(@"Try again in 1 minute", @"BKPasscodeView", @"1분 후에 다시 시도");
        _try_again_minutes = NSLocalizedStringFromTable(@"Try again in %d minutes", @"BKPasscodeView", @"%d분 후에 다시 시도");
    }
    return self;
}

@end
