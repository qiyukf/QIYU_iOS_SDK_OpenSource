//
//  NSString+YSFURLEncoding.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 4/16/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 A collection of useful additions for `NSString` to deal with URL encoding.
 */

@interface NSString (YSFURLEncoding)

/**-------------------------------------------------------------------------------------
 @name Encoding Strings for URLs
 ---------------------------------------------------------------------------------------
 */


/** Encoding suitable for use in URLs.
 
 stringByAddingPercentEscapes does not replace serveral characters which are problematics in URLs.
 
 @return The encoded version of the receiver.
 */
- (NSString *)ysf_stringByURLEncoding;

@end
