//
//  BKPasscodeUtils.h
//  BKPasscodeViewDemo
//
//  Created by Byungkook Jang on 2014. 10. 4..
//  Copyright (c) 2014년 Byungkook Jang. All rights reserved.
//

/*
 *  System Versioning Preprocessor Macros
 */

#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kLabelPasscodeSpacePortrait     (30.0f)
#define kLabelPasscodeSpaceLandscape    (10.0f)

#define kTextLeftRightSpace             (20.0f)

#define kErrorMessageLeftRightPadding   (10.0f)
#define kErrorMessageTopBottomPadding   (5.0f)

#define kDefaultNumericPasscodeMaximumLength        (4)
#define kDefaultNormalPasscodeMaximumLength         (20)
