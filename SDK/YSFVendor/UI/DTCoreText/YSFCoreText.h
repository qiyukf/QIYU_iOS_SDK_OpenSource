#import <Foundation/Foundation.h>

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#elif TARGET_OS_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

// global constants
#import "YSFCoreTextMacros.h"
#import "YSFCoreTextConstants.h"
#import "YSFCompatibility.h"

#import "YSFColor+Compatibility.h"
#import "YSFImage+HTML.h"

// common utilities
#if TARGET_OS_IPHONE
#import "YSFCoreTextFunctions.h"
#endif

#import "YSFColorFunctions.h"

// common classes
#import "YSFCSSListStyle.h"
#import "YSFTextBlock.h"
#import "YSFCSSStylesheet.h"
#import "YSFCoreTextFontDescriptor.h"
#import "YSFCoreTextParagraphStyle.h"
#import "YSFHTMLAttributedStringBuilder.h"
#import "YSFHTMLElement.h"
#import "YSFAnchorHTMLElement.h"
#import "YSFBreakHTMLElement.h"
#import "YSFListItemHTMLElement.h"
#import "YSFHorizontalRuleHTMLElement.h"
#import "YSFStylesheetHTMLElement.h"
#import "YSFTextAttachmentHTMLElement.h"
#import "YSFTextHTMLElement.h"
#import "YSFHTMLWriter.h"
#import "NSCharacterSet+YSFHTML.h"
#import "NSCoder+YSFCompatibility.h"
#import "NSDictionary+YSFCoreText.h"
#import "NSAttributedString+YSFHTML.h"
#import "NSAttributedString+YSFSmallCaps.h"
#import "NSAttributedString+YSFCoreText.h"
#import "NSMutableAttributedString+YSFHTML.h"
#import "NSMutableString+YSFHTML.h"
#import "NSScanner+YSFHTML.h"
#import "NSString+YSFCSS.h"
#import "NSString+YSFHTML.h"
#import "NSString+YSFParagraphs.h"

// parsing classes
#import "YSFHTMLParserNode.h"
#import "YSFHTMLParserTextNode.h"

// text attachment cluster
#import "YSFTextAttachment.h"
#import "YSFDictationPlaceholderTextAttachment.h"
#import "YSFIframeTextAttachment.h"
#import "YSFImageTextAttachment.h"
#import "YSFObjectTextAttachment.h"
#import "YSFVideoTextAttachment.h"

// TARGET_OS_IPHONE is both tvOS and iOS
#if TARGET_OS_IPHONE

#import "YSFLazyImageView.h"
#import "YSFLinkButton.h"

#import "YSFNSAttributedStringRunDelegates.h"

#import "YSFAttributedLabel.h"
#import "YSFAttributedTextCell.h"
#import "YSFAttributedTextContentView.h"
#import "YSFAttributedTextView.h"
#import "YSFCoreTextFontCollection.h"
#import "YSFCoreTextGlyphRun.h"
#import "YSFCoreTextLayoutFrame.h"
#import "YSFCoreTextLayoutFrame+Cursor.h"
#import "YSFCoreTextLayoutLine.h"
#import "YSFCoreTextLayouter.h"

#import "YSFDictationPlaceholderView.h"

#import "UIFont+YSFCoreText.h"

#import "YSFAccessibilityElement.h"
#import "YSFAccessibilityViewProxy.h"
#import "YSFCoreTextLayoutFrameAccessibilityElementGenerator.h"

#endif

