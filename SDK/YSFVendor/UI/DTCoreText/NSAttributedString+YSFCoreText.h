//
//  NSAttributedString+YSFCoreText.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 2/1/12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSFCSSListStyle;
@class YSFTextBlock;

/**
 Convenience Methods that mimics similar methods available on Mac
 */
@interface NSAttributedString (YSFCoreText)

/**
 @name Working with Text Attachments
 */

/**
 Retrieves the YSFTextAttachment objects that match the given predicate.
 
 With this method you can for example find all images that have a certain URL.
 
 @param predicate The predicate to apply for filtering or `nil` to not filter by attachment
 @param theClass The class that attachments need to have, or `nil` for all attachments regardless of class
 @returns The filtered array of attachments
 */
- (NSArray *)ysf_textAttachmentsWithPredicate:(NSPredicate *)predicate class:(Class)theClass;

/**
 @name Calculating Ranges
 */


/**
 Returns the index of the item at the given location within the list.
 
 @param list The text list.
 @param location The location of the item.
 @returns Returns the index within the list.
*/
- (NSInteger)ysf_itemNumberInTextList:(YSFCSSListStyle *)list atIndex:(NSUInteger)location;


/**
 Returns the range of the given text list that contains the given location.
 
 @param list The text list.
 @param location The location in the text.
 @returns The range of the given text list containing the location.
 */
- (NSRange)ysf_rangeOfTextList:(YSFCSSListStyle *)list atIndex:(NSUInteger)location;

/**
 Returns the range of the given text block that contains the given location.
 
 @param textBlock The text block.
 @param location The location in the text.
 @returns The range of the given text block containing the location.
 */
- (NSRange)ysf_rangeOfTextBlock:(YSFTextBlock *)textBlock atIndex:(NSUInteger)location;

/**
 Returns the range of the given href anchor.
 
 @param anchorName The name of the anchor.
 @returns The range of the given anchor.
 */
- (NSRange)ysf_rangeOfAnchorNamed:(NSString *)anchorName;

/**
 Returns the range of the hyperlink at the given index.
 
 @param location The location to query
 @param URL The URL that is found at this location or `NULL` if this is not needed
 @returns The range of the given hyperlink.
 */
- (NSRange)ysf_rangeOfLinkAtIndex:(NSUInteger)location URL:(NSURL * __autoreleasing*)URL;

/**
 Returns the range of a field at the given index. 
 
 @param location The location of the field
 @returns The range of the field. If there is no field at this location it returns {NSNotFound, 0}.
 */
- (NSRange)ysf_rangeOfFieldAtIndex:(NSUInteger)location;

#ifndef COVERAGE
// exclude method from coverage testing, those are just convenience methods

/**
 @name Converting to Other Representations
 */

/**
 Encodes the receiver into a generic HTML representation.
 
 @returns An HTML string.
 */
- (NSString *)ysf_htmlString;


/**
 Encodes the receiver into a generic HTML fragment representation. Styles are inlined and no html or head tags are included.
 
 @returns An HTML string.
 */
- (NSString *)ysf_htmlFragment;

/**
 Converts the receiver into plain text.
 
 This is different from the `string` method of `NSAttributedString` by also erasing placeholders for text attachments.

 @returns The receiver converted to plain text.
 */
- (NSString *)ysf_plainTextString;

#endif

/**
 @name Creating Special Attributed Strings
 */


/**
 Create a prefix for a paragraph in a list
 
 @param listCounter The value for the list item.
 @param listStyle The list style
 @param listIndent The amount in px to indent the list
 @param attributes The attribute dictionary for the text to be prefixed
 @returns An attributed string with the list prefix
 */
+ (NSAttributedString *)ysf_prefixForListItemWithCounter:(NSUInteger)listCounter listStyle:(YSFCSSListStyle *)listStyle listIndent:(CGFloat)listIndent attributes:(NSDictionary *)attributes;

@end
