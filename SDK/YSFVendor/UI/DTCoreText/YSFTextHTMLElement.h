//
//  YSFHTMLElementText.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 26.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "YSFHTMLElement.h"

/**
 Specialized subclass of <YSFHTMLElement> that deals with text. It represents a text node. The text inside a YSFHTMLElement can consist of any number of such text nodes.
 */

@interface YSFTextHTMLElement : YSFHTMLElement

/**
 The text content of the element.
 */
@property (nonatomic, strong) NSString *text;

@end
