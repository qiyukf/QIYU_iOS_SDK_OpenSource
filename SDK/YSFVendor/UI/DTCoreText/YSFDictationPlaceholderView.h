//
//  YSFDictationPlaceholderView.h
//  YSFRichTextEditor
//
//  Created by Oliver Drobnik on 05.02.13.
//  Copyright (c) 2013 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 A dictation placeholder to display in editors between the time the recording is complete until a recognized response is received.
 */

@interface YSFDictationPlaceholderView : UIView

/**
 Creates an appropriately sized YSFDictationPlaceholderView with 3 animated purple dots
 */
+ (YSFDictationPlaceholderView *)placeholderView;

/**
 The context of the receiver. This can be any object, for example the selection range to replace with the dictation result text
 */
@property (nonatomic, strong) id context;

@end
