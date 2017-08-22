//
//  NSString+YSFUtilities.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 4/16/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/** 
 A collection of utility additions for `NSString`.
 */

@interface NSString (YSFUtilities)

/**-------------------------------------------------------------------------------------
 @name Working with Identifiers
 ---------------------------------------------------------------------------------------
 */

/** Creates a new string that contains a generated UUID. 
 
 @return The path to the app's Caches folder.
 */
+ (NSString *)ysf_stringWithUUID;


/**-------------------------------------------------------------------------------------
 @name Working with Checksums
 ---------------------------------------------------------------------------------------
 */

/** creates an MD5 checksum 
 
 @return returns an MD5 hash for the receiver.
 */
- (NSString *)ysf_md5Checksum;



@end
