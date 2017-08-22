//
//  YSFHTMLElementA.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 21.03.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import "YSFHTMLElement.h"

/**
 Specialized subclass of <YSFHTMLElement> that represents a hyperlink.
 */
@interface YSFAnchorHTMLElement : YSFHTMLElement

/**
 Foreground text color of the receiver when highlighted
 */
@property (nonatomic, strong) YSFColor *highlightedTextColor;

@end
