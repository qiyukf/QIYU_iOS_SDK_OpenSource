//
//  NSMutableAttributedString+HTML.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 4/14/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import "YSFCoreTextConstants.h"

@class YSFCoreTextParagraphStyle, YSFCoreTextFontDescriptor;

/**
 Methods for appending `NSString` instances to mutable attributed strings
 */
@interface NSMutableAttributedString (HTML)

/** 
 Appends a string with the same attributes as this string to this string. 
 
 If the last character of the receiver contains a placeholder for a <YSFTextAttachment> it is removed from the appended string. Also fields (e.g. list prefixes) are not extended
 @param string The string to be appended to this string. */
- (void)ysf_appendString:(NSString *)string;

/** 
 Appends a string with a given paragraph style and font to this string. 
 @param string The string to be appended to this string.
 @param paragraphStyle Paragraph style to be attributed to the appended string. 
 @param fontDescriptor Font descriptor to be attributed to the appended string. */
- (void)ysf_appendString:(NSString *)string withParagraphStyle:(YSFCoreTextParagraphStyle *)paragraphStyle fontDescriptor:(YSFCoreTextFontDescriptor *)fontDescriptor;

/**
 Adds the paragraph terminator `\n` and makes sure that the previous font and paragraph styles extend to include it
 */
- (void)ysf_appendEndOfParagraph;

/**
 @name Working with Custom HTML Attributes
 */

/**
 Adds the custom HTML attributes with the given value on the given range, optionally replacing occurrences of an attribute with the same name.
 @param name The name of the custom HTML attribute
 @param value The value to set for the custom attribute
 @param range The range to add the custom attribute for
 @param replaceExisting `YES` if ranges that have an attribute with the same name should be replaced. With `NO` the attribute is only added for ranges where there is no attribute with the given name
 */
- (void)ysf_addHTMLAttribute:(NSString *)name value:(id)value range:(NSRange)range replaceExisting:(BOOL)replaceExisting;

/**
 Adds the custom HTML attributes with the given value from the given range.
 @param name The name of the custom HTML attribute
 @param range The range to add the custom attribute for
 */
- (void)ysf_removeHTMLAttribute:(NSString *)name range:(NSRange)range;

@end
