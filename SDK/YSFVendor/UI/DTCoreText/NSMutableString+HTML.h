//
//  NSMutableString+HTML.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 01.02.12.
//  Copyright (c) 2012 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Categories needed for modifying mutable strings, as needed for YSFCoreText.
 */
@interface NSMutableString (HTML)

/** 
 Removes the trailing whitespace from the receiver. 
 */
- (void)ysf_removeTrailingWhitespace;

@end
