//
//  UIWebView+YSFFoundation.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 25.05.12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Some convenient functions that can be also achieved if you know JavaScript, but are way more easy to remember like this.
 */

@interface UIWebView (YSFFoundation)

/**
 Getting the current document's title
 @returns A string with the document title
 */
- (NSString *)ysf_documentTitle;

@end
