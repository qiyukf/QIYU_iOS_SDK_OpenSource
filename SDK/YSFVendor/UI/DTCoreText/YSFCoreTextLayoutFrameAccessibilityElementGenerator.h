//
//  YSFCoreTextLayoutFrameAccessibilityElementGenerator.h
//  YSFCoreText
//
//  Created by Austen Green on 3/13/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YSFAccessibilityElement.h"

@class YSFCoreTextLayoutFrame, YSFTextAttachment;

/**
 A block that provides accessibility information for the passed text attachments
 */
typedef id(^YSFAttachmentViewProvider)(YSFTextAttachment *textAttachment);

/**
 Generates an array of objects conforming to the UIAccessibility informal protocol based on a <YSFCoreTextLayoutFrame>.
 */
@interface YSFCoreTextLayoutFrameAccessibilityElementGenerator : NSObject

/**
 The designated initializer. The YSFAttachmentViewProvider block may be used to provide custom subviews in place of a static accessibility element.
 @param frame The <YSFCoreTextLayoutFrame> to generate accessibility elements for.
 @param view The logical superview of the elements - the view that owns the local coordinate system for drawing the frame.
 @param block A callback block which takes a <YSFTextAttachment> object and returns an object that conforms to the UIAccessibility informal protocol.
 @returns Returns an array of objects conforming to the UIAccessibility informal protocol, suitable for presentation for the VoiceOver system.
 */

- (NSArray *)accessibilityElementsForLayoutFrame:(YSFCoreTextLayoutFrame *)frame view:(UIView *)view attachmentViewProvider:(YSFAttachmentViewProvider)block;

@end
