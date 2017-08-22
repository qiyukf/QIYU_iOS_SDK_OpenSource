//
//  YSFHTMLParserTextNode.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 26.12.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import "YSFHTMLParserNode.h"

/**
 Specialized sub class of <YSFHTMLParserNode> that represents text inside a node
 */
@interface YSFHTMLParserTextNode : YSFHTMLParserNode

/**
 Designated initializer with the characters that make up the text.
 @param characters The characters of the string
 @returns The initialized text node
 */
- (id)initWithCharacters:(NSString *)characters;

/**
 Returns the receivers character contents
 */
@property (nonatomic, readonly) NSString *characters;

@end
