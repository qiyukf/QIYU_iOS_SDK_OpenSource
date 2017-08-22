//
//  YSFAccessibilityViewProxy.h
//  YSFCoreText
//
//  Created by Austen Green on 5/6/13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFTextAttachment.h"

@protocol YSFAccessibilityViewProxyDelegate;

/**
 UIView proxy for YSFAttributedTextContentView custom subviews for text attachments.
 */

@interface YSFAccessibilityViewProxy : NSProxy
/**
 The delegate for the proxy
 */
@property (nonatomic, unsafe_unretained, readonly) id<YSFAccessibilityViewProxyDelegate> delegate;

/**
 The text attachment represented by the proxy
 */
@property (nonatomic, strong, readonly) YSFTextAttachment *textAttachment;

/**
 Creates a text attachment proxy for use with the VoiceOver system.
 @param textAttachment The <YSFTextAttachment> that will be represented by a view.
 @param delegate An object conforming to <YSFAccessibilityViewProxyDelegate> that will provide a view when needed by the proxy.
 @returns A new proxy object
 */

- (id)initWithTextAttachment:(YSFTextAttachment *)textAttachment delegate:(id<YSFAccessibilityViewProxyDelegate>)delegate;

@end

/**
 Protocol to provide custom views for accessibility elements representing a YSFTextAttachment.
 */
@protocol YSFAccessibilityViewProxyDelegate
@required
/**
 Provides a view for an attachment, e.g. an imageView for images
 
 @param attachment The <YSFTextAttachment> that the requested view should represent
 @param proxy The frame that the view should use to fit on top of the space reserved for the attachment.
 @returns The sender requesting the view.
 */

- (UIView *)viewForTextAttachment:(YSFTextAttachment *)attachment proxy:(YSFAccessibilityViewProxy *)proxy;
@end
