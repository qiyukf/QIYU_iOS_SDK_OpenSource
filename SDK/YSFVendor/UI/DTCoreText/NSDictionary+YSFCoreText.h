//
//  NSDictionary+YSFRichText.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 7/21/11.
//  Copyright 2011 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFCompatibility.h"

@class YSFCoreTextParagraphStyle;
@class YSFCoreTextFontDescriptor;

/**
 Convenience methods for editors dealing with Core Text attribute dictionaries.
 */
@interface NSDictionary (YSFCoreText)

/**
 @name Getting State information
 */

/**
 Whether the font in the receiver's attributes is bold.
 @returns `YES` if the text has a bold trait
 */
- (BOOL)ysf_isBold;

/**
 Whether the font in the receiver's attributes is italic.
 @returns `YES` if the text has an italic trait
 */
- (BOOL)ysf_isItalic;

/**
 Whether the receiver's attributes contains underlining.
 @returns `YES` if the text is underlined
 */
- (BOOL)ysf_isUnderline;

/**
 Whether the receiver's attributes contains strike-through.
 @returns `YES` if the text is strike-through
 */
- (BOOL)ysf_isStrikethrough;

/**
 Whether the receiver's attributes contain a YSFTextAttachment
 @returns `YES` if there is an attachment
 */
- (BOOL)ysf_hasAttachment;

/**
 The header level of the receiver
 @returns The header level (1-6) or 0 if no header level is set
 */
- (NSUInteger)ysf_headerLevel;

/**
 @name Getting Style Information
 */

/**
 Retrieves the YSFCoreTextParagraphStyle from the receiver's attributes. This supports both `CTParagraphStyle` as well as `NSParagraphStyle` as a possible representation of the text's paragraph style.
 @returns The paragraph style
 */
- (YSFCoreTextParagraphStyle *)ysf_paragraphStyle;

/**
 Retrieves the YSFCoreTextFontDescriptor from the receiver's attributes. This supports both `CTFont` as well as `UIFont` as a possible representation of the text's font.
 @returns The font descriptor
 */
- (YSFCoreTextFontDescriptor *)ysf_fontDescriptor;

/**
 Retrieves the foreground color. On iOS as UIColor, on Mac as NSColor. This supports both the CT as well as the NS/UIKit method of specifying the color. If no foreground color is defined in the receiver then black is assumed.
 @returns The platform-specific color defined for the foreground
 */
- (YSFColor *)ysf_foregroundColor;

/**
 Retrieves the background color. On iOS as UIColor, on Mac as NSColor. This supports both the YSF as well as the NS/UIKit method of specifying the color. If no background color is defined in the receiver then `nil` is returned
 @returns The platform-specific color defined for the background, or `nil` if none is defined
 */
- (YSFColor *)ysf_backgroundColor;

/**
 The text kerning value
 @returns the kerning value
 */
- (CGFloat)ysf_kerning;

@end
