//
//  YSFCoreTextLayoutFrame.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 1/24/11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#elif TARGET_OS_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

#import "YSFCoreTextConstants.h"

@class YSFCoreTextLayoutLine;
@class YSFTextBlock;

/**
 A handler block that is called whenever a text block attributed is encountered during text drawing
 */
typedef void (^YSFCoreTextLayoutFrameTextBlockHandler)(YSFTextBlock *textBlock, CGRect frame, CGContextRef context, BOOL *shouldDrawDefaultBackground);

/**
 The drawing options for YSFCoreTextLayoutFrame
 */
typedef NS_ENUM(NSUInteger, YSFCoreTextLayoutFrameDrawingOptions)
{
	/**
	 The default method for drawing draws links and attachments. Links are drawn non-highlighted
	 */
	YSFCoreTextLayoutFrameDrawingDefault              = 1<<0,
	
	/**
	 Links are not drawn, e.g. if they are displayed via custom buttons
	 */
	YSFCoreTextLayoutFrameDrawingOmitLinks            = 1<<1,
	
	/**
	 Text attachments are omitted from drawing, e.g. if they are displayed via custom views
	 */
	YSFCoreTextLayoutFrameDrawingOmitAttachments      = 1<<2,
	
	/**
	 If links are drawn they are displayed with the highlighted variant
	 */
	YSFCoreTextLayoutFrameDrawingDrawLinksHighlighted = 1<<3
} ;


@class YSFCoreTextLayouter;

/**
 This class represents a single frame of text and basically wraps CTFrame. It provides an array of text lines that fit in the given rectangle.
 
 Both styles of layouting are supported: open ended (suitable for scroll views) and limited to a given rectangle. To use the open-ended style specify `CGFLOAT_HEIGHT_UNKNOWN` for the <frame> height when creating a layout frame.
 
 The array of lines is built lazily the first time it is accessed or - for open-ended frames - when the frame property is being queried.
 */
@interface YSFCoreTextLayoutFrame : NSObject 
{
	CGRect _frame;

	NSArray *_lines;
	NSArray *_paragraphRanges;

	NSArray *_textAttachments;
	NSAttributedString *_attributedStringFragment;
}


/**
 @name Creating Layout Frames
 */


/**
 Creates a Layout Frame with the given frame using the attributed string loaded into the layouter.
 
 @param frame The rectangle specifying origin and size of available for text. Specify `CGFLOAT_WIDTH_UNKNOWN` to not limit the width. Specify `CGFLOAT_HEIGHT_UNKNOWN` to not limit the height.
 @param layouter A reference to the layouter for this text box.
 */
- (id)initWithFrame:(CGRect)frame layouter:(YSFCoreTextLayouter *)layouter;


/**
 Creates a Layout Frame with the given frame using the attributed string loaded into the layouter.
 
 @param frame The rectangle specifying origin and size of available for text. Specify `CGFLOAT_WIDTH_UNKNOWN` to not limit the width. Specify `CGFLOAT_HEIGHT_UNKNOWN` to not limit the height.
 @param layouter A reference to the layouter for the receiver. Note: The layouter owns the attributed string.
 @param range The range within the attributed string to layout into the receiver.
 */
- (id)initWithFrame:(CGRect)frame layouter:(YSFCoreTextLayouter *)layouter range:(NSRange)range;


/**
 @name Getting Information
 */


/**
 The string range that is visible i.e. fits into the given rectangle. For open-ended frames this is typically the entire string. For frame-contrained layout frames it is the substring that fits.
  */
- (NSRange)visibleStringRange;


/**
 This is a copy of the attributed string owned by the layouter of the receiver.
*/
- (NSAttributedString *)attributedStringFragment;


/**
 An array that maps glyphs with string indices.
 */
- (NSArray *)stringIndices;


/**
 The frame rectangle for the layout frame.
 */
 @property (nonatomic, assign, readonly) CGRect frame;


/**
 Calculates the frame that is covered by the text content.
 
 The result is calculated by enumerating over all lines and creating a union over all their frames. This is different than the frame property since this gets calculated.
 @returns The area that is covered by the text content.
 @note The width depends on how many glyphs Core Text was able to fit into a line. A line that gets broken might not have glyphs all the way to the margin. The y origin is always adjusted to be the same as frame since the first line might have some leading. The height is the minimum height that fits all layout lines.
 */
- (CGRect)intrinsicContentFrame;


/**
 @name Drawing
 */


/**
 Draws the receiver into the given graphics context.

 @warning This method is deprecated, use -[YSFCoreTextLayoutFrame drawInContext:options:] instead
 @param context A graphics context to draw into
 @param drawImages Whether images should be drawn together with the text. If you specify `NO` then space is left blank where images would go and you have to add your own views to display these images.
 @param drawLinks Whether hyperlinks should be drawn together with the text. If you specify `NO` then space is left blank where links would go and you have to add your own views to display these images.
 */
- (void)drawInContext:(CGContextRef)context drawImages:(BOOL)drawImages drawLinks:(BOOL)drawLinks __attribute__((deprecated("use -[YSFCoreTextLayoutFrame drawInContext:options:] instead")));


/**
 Draws the receiver into the given graphics context.
 
 @param context A graphics context to draw into
 @param options The drawing options. See YSFCoreTextLayoutFrameDrawingOptions for available options.
 */
- (void)drawInContext:(CGContextRef)context options:(YSFCoreTextLayoutFrameDrawingOptions)options;


/**
 Set a custom handler to be executed before text belonging to a text block is drawn. Of type <YSFCoreTextLayoutFrameTextBlockHandler>.
*/
@property (nonatomic, copy) YSFCoreTextLayoutFrameTextBlockHandler textBlockHandler;


/**
 @name Working with Glyphs
 */


/**
 Retrieves the index of the text line that contains the given glyph index.
 
 @param index The index of the glyph
 @returns The index of the line containing this glyph
 */
- (NSInteger)lineIndexForGlyphIndex:(NSInteger)index;


/**
 Retrieves the frame of the glyph at the given glyph index.
 
 @param index The index of the glyph
 @returns The frame of this glyph
 */
- (CGRect)frameOfGlyphAtIndex:(NSInteger)index;


/**
 @name Working with Text Lines
 */


/**
 The text lines that belong to the receiver.
 */
@property (nonatomic, strong, readonly) NSArray *lines;


/**
 The text lines that are visible inside the given rectangle. Also incomplete lines are included.
 
 @param rect The rectangle
 @returns An array, sorted from top to bottom, of lines at least partially visible
 */
- (NSArray *)linesVisibleInRect:(CGRect)rect; 


/**
 The text lines that are visible inside the given rectangle. Only fully visible lines are included.
 
 @param rect The rectangle
 @returns An array, sorted from top to bottom, of lines fully visible
 */
- (NSArray *)linesContainedInRect:(CGRect)rect;


/**
 The layout line that contains the given string index.
 
 @param index The string index
 @returns The layout line that this index belongs to
 */
- (YSFCoreTextLayoutLine *)lineContainingIndex:(NSUInteger)index;


/**
 Determins if the given line is the first in a paragraph.
 
 This is needed for example to determine whether paragraphSpaceBefore needs to be applied before it.
 @param line The Line
 @returns `YES` if the given line is the first in a paragraph
 */
- (BOOL)isLineFirstInParagraph:(YSFCoreTextLayoutLine *)line;


/**
 Determins if the given line is the last in a paragraph.
 
 This is needed for example to determine whether paragraph spacing needs to be applied after it.
 @param line The Line
 @returns `YES` if the given line is the last in a paragraph
 */
- (BOOL)isLineLastInParagraph:(YSFCoreTextLayoutLine *)line;


/**
 Finds the appropriate baseline origin for a line to position it at the correct distance from a previous line.
 
 Support Layout options are:
 
 - YSFCoreTextLayoutFrameLinePositioningAlgorithmWebKit,
 - YSFCoreTextLayoutFrameLinePositioningAlgorithmLegacy
 
 @param line The line
 @param previousLine The line after which to position the line.
 @param options The layout options to employ for positioning lines
 @returns The correct baseline origin for the line.
 */
- (CGPoint)baselineOriginToPositionLine:(YSFCoreTextLayoutLine *)line afterLine:(YSFCoreTextLayoutLine *)previousLine options:(YSFCoreTextLayoutFrameLinePositioningOptions)options;

/**
 Finds the appropriate baseline origin for a line to position it at the correct distance from a previous line using the YSFCoreTextLayoutFrameLinePositioningOptionAlgorithmLegacy algorithm.
 
 @warning This method is deprecated, use -[baselineOriginToPositionLine:afterLine:algorithm:] instead
 @param line The line
 @param previousLine The line after which to position the line.
 @returns The correct baseline origin for the line.
 */
- (CGPoint)baselineOriginToPositionLine:(YSFCoreTextLayoutLine *)line afterLine:(YSFCoreTextLayoutLine *)previousLine __attribute__((deprecated("use use -[baselineOriginToPositionLine:afterLine:algorithm:] instead")));;

/**
 The ratio to decide when to create a justified line
 */
@property (nonatomic, readwrite) CGFloat justifyRatio;

/**
 @name Text Attachments
 */


/**
 The array of all <YSFTextAttachment> instances that belong to the receiver.
 @returns All text attachments of the receiver.
 */
- (NSArray *)textAttachments;


/**
 The array of all YSFTextAttachment instances that belong to the receiver which also match the specified predicate.
 
 @param predicate A predicate that uses properties of <YSFTextAttachment> to reduce the returned array
 @returns A filtered array of text attachments.
 */
- (NSArray *)textAttachmentsWithPredicate:(NSPredicate *)predicate;


/** 
 @name Getting Paragraph Info
 */


/** 
 Finding which paragraph a given string index belongs to.
 
 @param stringIndex The index in the string to look for
 @returns The index of the paragraph, numbered from 0
 */
- (NSUInteger)paragraphIndexContainingStringIndex:(NSUInteger)stringIndex;


/** 
 Determines the paragraph range (of paragraph indexes) that encompass the entire given string Range.
 
 @param stringRange The string range for which the paragraph range is sought for
 @returns The range of paragraphs that fully enclose the string range
 */
- (NSRange)paragraphRangeContainingStringRange:(NSRange)stringRange;


/**
 The text lines that belong to the specified paragraph.
 
 @param index The index of the paragraph
 @returns An array, sorted from top to bottom, of lines in this paragraph
 */
- (NSArray *)linesInParagraphAtIndex:(NSUInteger)index;


/**
 An array of `NSRange` values encapsulated in `NSValue` instances. Each range is the string range contained in the corresponding paragraph.
*/
@property (nonatomic, strong, readonly) NSArray *paragraphRanges;


/**
 @name Debugging
 */


/**
 Switches on the debug drawing mode where individual glyph runs, baselines, et cetera get individually marked.

 @param debugFrames if the debug drawing should occur
 */
+ (void)setShouldDrawDebugFrames:(BOOL)debugFrames;


/**
 @returns the current value of the debug frame drawing
 */
+ (BOOL)shouldDrawDebugFrames;

/**
 @name Truncation
 */


/**
 Maximum number of lines to display before truncation.  Default is 0 which indicates no limit.
 */
@property(nonatomic, assign) NSInteger numberOfLines;


/**
 Line break mode used to indicate how truncation should occur
 */
@property(nonatomic, assign) NSLineBreakMode lineBreakMode;


/**
 Optional attributed string to use as truncation indicator.  If nil, will use "…" w/ attributes taken from text being truncated
 */
@property(nonatomic, strong)NSAttributedString *truncationString;


@end
