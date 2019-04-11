//
//  BKPasscodeField.m
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import "BKPasscodeField.h"

@interface BKPasscodeField ()

@property (strong, nonatomic) NSMutableString       *mutablePasscode;
@property (strong, nonatomic) NSRegularExpression   *nonDigitRegularExpression;

@end

@implementation BKPasscodeField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize
{
    _maximumLength = 4;
    _dotSize = CGSizeMake(19.0f, 19.0f);
    _dotSpacing = 25.0f;
    _lineHeight = 3.0f;
    _dotColor = [UIColor blackColor];
    
    self.backgroundColor = UIColor.clearColor;
    
    _mutablePasscode = [[NSMutableString alloc] initWithCapacity:4];
    [self addTarget:self action:@selector(didTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSRegularExpression *)nonDigitRegularExpression
{
    if (nil == _nonDigitRegularExpression) {
        _nonDigitRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"[^0-9]+" options:0 error:nil];
    }
    return _nonDigitRegularExpression;
}

- (NSString *)passcode
{
    return self.mutablePasscode;
}

- (void)setPasscode:(NSString *)passcode
{
    if (passcode) {
        if (passcode.length > self.maximumLength) {
            passcode = [passcode substringWithRange:NSMakeRange(0, self.maximumLength)];
        }
        self.mutablePasscode = [NSMutableString stringWithString:passcode];
    }
    else {
        self.mutablePasscode = [NSMutableString string];
    }
    [self setNeedsDisplay];
}

#pragma mark - UIKeyInput

- (BOOL)hasText
{
    return (self.mutablePasscode.length > 0);
}

- (void)insertText:(NSString *)text
{
    if (self.enabled == NO) {
        return;
    }
    
    if (self.keyboardType == UIKeyboardTypeNumberPad) {
        text = [self.nonDigitRegularExpression stringByReplacingMatchesInString:text options:0 range:NSMakeRange(0, text.length) withTemplate:@""];
    }
    
    if (text.length == 0) {
        return;
    }
    
    NSInteger newLength = self.mutablePasscode.length + text.length;
    if (newLength > self.maximumLength) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(passcodeField:shouldInsertText:)]) {
        if (NO == [self.delegate passcodeField:self shouldInsertText:text]) {
            return;
        }
    }
    
    [self.mutablePasscode appendString:text];

    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (void)deleteBackward
{
    if (self.enabled == NO) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(passcodeFieldShouldDeleteBackward:)]) {
        if (NO == [self.delegate passcodeFieldShouldDeleteBackward:self]) {
            return;
        }
    }
    
    if (self.mutablePasscode.length == 0) {
        return;
    }
    
    [self.mutablePasscode deleteCharactersInRange:NSMakeRange(self.mutablePasscode.length - 1, 1)];
    
    [self setNeedsDisplay];
    [self sendActionsForControlEvents:UIControlEventEditingChanged];
}

- (UITextAutocapitalizationType)autocapitalizationType
{
    return UITextAutocapitalizationTypeNone;
}

- (UITextAutocorrectionType)autocorrectionType
{
    return UITextAutocorrectionTypeNo;
}

- (UITextSpellCheckingType)spellCheckingType
{
    return UITextSpellCheckingTypeNo;
}

- (BOOL)enablesReturnKeyAutomatically
{
    return YES;
}

- (UIKeyboardAppearance)keyboardAppearance
{
    return UIKeyboardAppearanceDefault;
}

- (UIReturnKeyType)returnKeyType
{
    return UIReturnKeyDone;
}

- (BOOL)isSecureTextEntry
{
    return YES;
}

#pragma mark - UIView

- (CGSize)contentSize
{
    return CGSizeMake(self.maximumLength * self.dotSize.width + (self.maximumLength - 1) * self.dotSpacing, self.dotSize.height*2.0);
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize contentSize = [self contentSize];
    CGPoint origin = CGPointMake(floorf((self.frame.size.width - contentSize.width)/2.0),
                                 floorf((self.frame.size.height - self.dotSize.height)/2.0));
    
    if (self.disableSecure) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
        
        UIFont *font = [UIFont boldSystemFontOfSize:1.0];
        for (int i = 0; i < 100; i++) {
            font = [UIFont boldSystemFontOfSize:i];
            if (font.lineHeight > self.bounds.size.height) {
                break;
            }
        }
        
        NSDictionary *attributes = @{NSFontAttributeName:font,
                                     NSForegroundColorAttributeName:UIColor.greenColor};
        
        for (NSUInteger i = 0; i < self.maximumLength; i++) {
            if (i < self.mutablePasscode.length) {
                NSAttributedString *character = [[NSAttributedString alloc] initWithString:@"2" attributes:attributes];
                [character drawAtPoint:CGPointMake(origin.x + (self.dotSize.width - character.size.width)/2.0, (self.bounds.size.height - character.size.height)/2.0)];
            }
            else {
                CGRect lineFrame = CGRectMake(origin.x, origin.y + floorf((self.dotSize.height - self.lineHeight)/2.0), self.dotSize.width, self.lineHeight);
                CGContextFillRect(context, lineFrame);
            }
            
            origin.x += (self.dotSize.width + self.dotSpacing);
        }
    }
    else {
        if ([self.imageSource respondsToSelector:@selector(passcodeField:dotImageAtIndex:filled:)]) {
            for (NSUInteger i = 0; i < self.maximumLength; i++) {
                UIImage *image = nil;
                if (i < self.mutablePasscode.length) {
                    image = [self.imageSource passcodeField:self dotImageAtIndex:i filled:YES];
                }
                else {
                    image = [self.imageSource passcodeField:self dotImageAtIndex:i filled:NO];
                }
                
                if (image) {
                    CGRect imageFrame = CGRectMake(origin.x, origin.y, self.dotSize.width, self.dotSize.height);
                    [image drawInRect:imageFrame];
                }
                
                origin.x += (self.dotSize.width + self.dotSpacing);
            }
        }
        else {
            CGContextRef context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, self.dotColor.CGColor);
            
            for (NSUInteger i = 0; i < self.maximumLength; i++) {
                if (i < self.mutablePasscode.length) {
                    CGRect circleFrame = CGRectMake(origin.x, origin.y, self.dotSize.width, self.dotSize.height);
                    CGContextFillEllipseInRect(context, circleFrame);
                }
                else {
                    CGRect lineFrame = CGRectMake(origin.x, origin.y + floorf((self.dotSize.height - self.lineHeight)/2.0), self.dotSize.width, self.lineHeight);
                    CGContextFillRect(context, lineFrame);
                }
                
                origin.x += (self.dotSize.width + self.dotSpacing);
            }
        }
    }
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return [self contentSize];
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Actions

- (void)didTouchUpInside:(id)sender
{
    [self becomeFirstResponder];
}

@end
