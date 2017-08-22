//
//  YSFHTMLAttributedStringBuilder.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 21.01.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "YSFDTHTMLParser.h"

@class YSFHTMLElement;

/**
 The block that gets executed whenever an element is flushed to the output string
 */
typedef void(^YSFHTMLAttributedStringBuilderWillFlushCallback)(YSFHTMLElement *);


/**
 Class for building an `NSAttributedString` from an HTML document.
 */
@interface YSFHTMLAttributedStringBuilder : NSObject <YSFHTMLParserDelegate>

/**
 @name Creating an Attributed String Builder
 */

/**
 Initializes and returns a new `NSAttributedString` object from the HTML contained in the given object and base URL.
 
 Options can be:
 
 - YSFMaxImageSize: the maximum CGSize that a text attachment can fill
 - YSFDefaultFontFamily: the default font family to use instead of Times New Roman
 - YSFDefaultFontName: the default font face to use instead of Times New Roman
 - YSFDefaultFontSize: the default font size to use instead of 12
 - YSFDefaultTextColor: the default text color
 - YSFDefaultLinkColor: the default color for hyperlink text
 - YSFDefaultLinkDecoration: the default decoration for hyperlinks
 - YSFDefaultLinkHighlightColor: the color to show while the hyperlink is highlighted
 - YSFDefaultTextAlignment: the default text alignment for paragraphs
 - YSFDefaultLineHeightMultiplier: The multiplier for line heights
 - YSFDefaultFirstLineHeadIndent: The default indent for left margin on first line
 - YSFDefaultHeadIndent: The default indent for left margin except first line
 - YSFDefaultListIndent: The amount by which lists are indented
 - YSFDefaultStyleSheet: The default style sheet to use
 - YSFUseiOS6Attributes: use iOS 6 attributes for building (UITextView compatible)
 - YSFWillFlushBlockCallBack: a block to be executed whenever content is flushed to the output string
 - YSFIgnoreInlineStylesOption: All inline style information is being ignored and only style blocks used
 
 @param data The data in HTML format from which to create the attributed string.
 @param options Specifies how the document should be loaded. Contains values described in NSAttributedString(HTML).
 @param docAttributes Currently not in use.
 @returns Returns an initialized object, or `nil` if the data can’t be decoded.
 */
- (id)initWithHTML:(NSData *)data options:(NSDictionary *)options documentAttributes:(NSDictionary * __autoreleasing*)docAttributes;


/**
 @name Generating Attributed Strings
 */

/**
  Creates the attributed string when called the first time.
 @returns An `NSAttributedString` representing the HTML document passed in the initializer.
 */
- (NSAttributedString *)generatedAttributedString;


/**
 This block is called before the element is written to the output attributed string
 */
@property (nonatomic, copy) YSFHTMLAttributedStringBuilderWillFlushCallback willFlushCallback;

/**
 Setting this property to `YES` causes the tree of parse nodes to be preserved until the end of the generation process. This allows to output the HTML structure of the document for debugging.
 */
@property (nonatomic, assign) BOOL shouldKeepDocumentNodeTree;

@end
