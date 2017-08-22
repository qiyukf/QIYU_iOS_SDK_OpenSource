//
//  YSFObjectTextAttachment.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 22.04.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "YSFTextAttachment.h"

/**
 A specialized subclass in the YSFTextAttachment class cluster to represent an generic object
 */

@interface YSFObjectTextAttachment : YSFTextAttachment <YSFTextAttachmentHTMLPersistence>

/**
 The YSFHTMLElement child nodes of the receiver. This array is only used for object tags at the moment.
 */
@property (nonatomic, strong) NSArray *childNodes;

@end
