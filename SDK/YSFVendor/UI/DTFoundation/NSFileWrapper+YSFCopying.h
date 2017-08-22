//
//  NSFileWrapper+YSFCopying.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 10/19/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Methods for copying file wrappers.
 */
@interface NSFileWrapper (YSFCopying)

/**
 Creates a copy of the receiver by deep copying all contained sub filewrappers.
 */
- (NSFileWrapper *)ysf_fileWrapperByDeepCopying;

@end
