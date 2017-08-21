// unicode characters

#import <Foundation/Foundation.h>

#define UNICODE_OBJECT_PLACEHOLDER @"\ufffc"
#define UNICODE_LINE_FEED @"\u2028"

// unicode spaces (see http://www.cs.tut.fi/~jkorpela/chars/spaces.html)

#define UNICODE_SPACE @"\u0020"
#define UNICODE_NON_BREAKING_SPACE @"\u00a0"
#define UNICODE_OGHAM_SPACE_MARK @"\u1680"
#define UNICODE_MONGOLIAN_VOWEL_SEPARATOR @"\u180e"
#define UNICODE_EN_QUAD @"\u2000"
#define UNICODE_EM_QUAD @"\u2001"
#define UNICODE_EN_SPACE @"\u2002"
#define UNICODE_EM_SPACE @"\u2003"
#define UNICODE_THREE_PER_EM_SPACE @"\u2004"
#define UNICODE_FOUR_PER_EM_SPACE @"\u2005"
#define UNICODE_SIX_PER_EM_SPACE @"\u2006"
#define UNICODE_FIGURE_SPACE @"\u2007"
#define UNICODE_PUNCTUATION_SPACE @"\u2008"
#define UNICODE_THIN_SPACE @"\u2009"
#define UNICODE_HAIR_SPACE @"\u200a"
#define UNICODE_ZERO_WIDTH_SPACE @"\u200b"
#define UNICODE_NARROW_NO_BREAK_SPACE @"\u202f"
#define UNICODE_MEDIUM_MATHEMATICAL_SPACE @"\u205f"
#define UNICODE_IDEOGRAPHIC_SPACE @"\u3000"
#define UNICODE_ZERO_WIDTH_NO_BREAK_SPACE @"\ufeff"

// standard options

#if TARGET_OS_IPHONE
extern NSString * const YSFNSBaseURLDocumentOption;
extern NSString * const YSFNSTextEncodingNameDocumentOption;
extern NSString * const YSFNSTextSizeMultiplierDocumentOption;

#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_7_0
extern NSString * const YSFNSAttachmentAttributeName;
#endif

#endif

// custom options

extern NSString * const YSFMaxImageSize;
extern NSString * const YSFDefaultFontFamily;
extern NSString * const YSFDefaultFontName;
extern NSString * const YSFDefaultFontSize;
extern NSString * const YSFDefaultTextColor;
extern NSString * const YSFDefaultLinkColor;
extern NSString * const YSFDefaultLinkDecoration;
extern NSString * const YSFDefaultLinkHighlightColor;
extern NSString * const YSFDefaultTextAlignment;
extern NSString * const YSFDefaultLineHeightMultiplier;
extern NSString * const YSFDefaultLineHeightMultiplier;
extern NSString * const YSFDefaultFirstLineHeadIndent;
extern NSString * const YSFDefaultHeadIndent;
extern NSString * const YSFDefaultStyleSheet;
extern NSString * const YSFUseiOS6Attributes;
extern NSString * const YSFWillFlushBlockCallBack;
extern NSString * const YSFProcessCustomHTMLAttributes;
extern NSString * const YSFIgnoreInlineStylesOption;
extern NSString * const YSFDocumentPreserveTrailingSpaces;


// attributed string attribute constants

extern NSString * const YSFTextListsAttribute;
extern NSString * const YSFAttachmentParagraphSpacingAttribute;
extern NSString * const YSFLinkAttribute;
extern NSString * const YSFLinkHighlightColorAttribute;
extern NSString * const YSFAnchorAttribute;
extern NSString * const YSFGUIDAttribute;
extern NSString * const YSFHeaderLevelAttribute;
extern NSString * const YSFStrikeOutAttribute;
extern NSString * const YSFBackgroundColorAttribute;
extern NSString * const YSFShadowsAttribute;
extern NSString * const YSFHorizontalRuleStyleAttribute;
extern NSString * const YSFTextBlocksAttribute;
extern NSString * const YSFFieldAttribute;
extern NSString * const YSFCustomAttributesAttribute;
extern NSString * const YSFAscentMultiplierAttribute;
extern NSString * const YSFBackgroundStrokeColorAttribute;
extern NSString * const YSFBackgroundStrokeWidthAttribute;
extern NSString * const YSFBackgroundCornerRadiusAttribute;

// field constants

extern NSString * const YSFListPrefixField;

// iOS 6 compatibility
extern BOOL ysf___useiOS6Attributes;

// exceptions
extern NSString * const YSFCoreTextFontDescriptorException;

// macros

#define IS_WHITESPACE(_c) (_c == ' ' || _c == '\t' || _c == 0xA || _c == 0xB || _c == 0xC || _c == 0xD || _c == 0x85)

// types

/**
 YSFHTMLElement display style
 */
typedef NS_ENUM(NSUInteger, YSFHTMLElementDisplayStyle)
{
	/**
	 The element is inline text
	 */
	YSFHTMLElementDisplayStyleInline = 0, // default
	
	/**
	 The element is not displayed
	 */
	YSFHTMLElementDisplayStyleNone,
	
	/**
	 The element is a block
	 */
	YSFHTMLElementDisplayStyleBlock,
	
	/**
	 The element is an item in a list
	 */
	YSFHTMLElementDisplayStyleListItem,
	
	/**
	 The element is a table
	 */
	YSFHTMLElementDisplayStyleTable,
};

/**
 YSFHTMLElement floating style
 */
typedef NS_ENUM(NSUInteger, YSFHTMLElementFloatStyle)
{
	/**
	 The element does not float
	 */
	YSFHTMLElementFloatStyleNone = 0,
	
	
	/**
	 The element should float left-aligned
	 */
	YSFHTMLElementFloatStyleLeft,
	
	
	/**
	 The element should float right-aligned
	 */
	YSFHTMLElementFloatStyleRight
};

/**
 YSFHTMLElement font variants
 */
typedef NS_ENUM(NSUInteger, YSFHTMLElementFontVariant)
{
	/**
	 The element inherits the font variant
	 */
	YSFHTMLElementFontVariantInherit = 0,
	
	/**
	 The element uses the normal font variant
	 */
	YSFHTMLElementFontVariantNormal,
	
	/**
	 The element should display in small caps
	 */
	YSFHTMLElementFontVariantSmallCaps
};

/**
 The algorithm that YSFCoreTextLayoutFrame uses for positioning lines
 */
typedef NS_ENUM(NSUInteger, YSFCoreTextLayoutFrameLinePositioningOptions)
{
	/**
	 The line positioning algorithm is similar to how Safari positions lines
	 */
	YSFCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit = 1,
	
	/**
	 The line positioning algorithm is how it was before the implementation of YSFCoreTextLayoutFrameLinePositioningOptionAlgorithmWebKit
	 */
	YSFCoreTextLayoutFrameLinePositioningOptionAlgorithmLegacy = 2
};

// layouting

// the value to use if the width is unknown
#define CGFLOAT_WIDTH_UNKNOWN 16777215.0f

// the value to use if the height is unknown
#define CGFLOAT_HEIGHT_UNKNOWN 16777215.0f

