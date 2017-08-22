//
//  YSFHTMLElementStylesheet.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 29.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "YSFHTMLElement.h"

@class YSFCSSStylesheet;

/**
 This is a specialized subclass of <YSFHTMLElement> representing a style block.
 */
@interface YSFStylesheetHTMLElement : YSFHTMLElement

/**
 Parses the text children and assembles the resulting stylesheet.
 */
- (YSFCSSStylesheet *)stylesheet;

@end
