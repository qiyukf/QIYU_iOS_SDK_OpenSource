//
//  NSAttributedString+YSFDebug.h
//  YSFCoreText
//
//  Created by Oliver Drobnik on 29.04.13.
//  Copyright (c) 2013 Drobnik.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 The *YSFDebug* category contains methods for debugging and dumping attributed strings
 */
@interface NSAttributedString (YSFDebug)

- (void)ysf_dumpRangesOfAttribute:(id)attribute;

@end
