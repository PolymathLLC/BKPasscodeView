//
//  BKPasscodeField.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 4. 20..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BKPasscodeFieldDelegate;
@protocol BKPasscodeFieldImageSource;

@interface BKPasscodeField : UIControl <UIKeyInput>

// delegate
@property (nonatomic, weak) id<BKPasscodeFieldDelegate> delegate;
@property (nonatomic, weak) id<BKPasscodeFieldImageSource> imageSource;

// passcode
@property (nonatomic, strong) NSString *passcode;

// configurations
@property (nonatomic, assign) NSUInteger maximumLength;
@property (nonatomic, assign) UIKeyboardType keyboardType;

@property (nonatomic, assign) BOOL disableSecure;

@property (nonatomic, strong) UIColor *dotColor;
@property (nonatomic, assign) CGSize dotSize;
@property (nonatomic, assign) CGFloat lineHeight;
@property (nonatomic, assign) CGFloat dotSpacing;

@end


@protocol BKPasscodeFieldDelegate <NSObject>

@optional
/**
 * Ask the delegate that whether passcode field accepts text.
 * If you want to accept entering text, return YES.
 */
- (BOOL)passcodeField:(BKPasscodeField *)aPasscodeField shouldInsertText:(NSString *)aText;

/**
 * Ask the delegate that whether passcode can be deleted.
 * If you want to accept deleting passcode, return YES.
 */
- (BOOL)passcodeFieldShouldDeleteBackward:(BKPasscodeField *)aPasscodeField;

@end


@protocol BKPasscodeFieldImageSource <NSObject>

@optional

/**
 * Ask the image source for a image to display passcode digit at index.
 * If you don't implement this, default shape (line for blank digit and circule for filled digit) will be displayed.
 */
- (UIImage *)passcodeField:(BKPasscodeField *)aPasscodeField dotImageAtIndex:(NSInteger)aIndex filled:(BOOL)aFilled;

@end
