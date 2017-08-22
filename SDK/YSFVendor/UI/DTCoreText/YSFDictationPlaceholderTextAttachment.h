//
//  YSFDictationPlaceholderTextAttachment.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 06.02.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "YSFTextAttachment.h"

/**
 This is a special subclass of YSFTextAttachment used to represent the dictation placeholder.
 
 When encountering such an element YSFAttributedTextContentView does not call the delegate to provide a subclass but automatically creates and adds a YSFDictationPlaceholderView.
 */

@interface YSFDictationPlaceholderTextAttachment : YSFTextAttachment

/**
 The string that inserting the dictation placeholder replaced, used for Undoing
 */
@property (nonatomic, retain) NSAttributedString *replacedAttributedString;

@end
