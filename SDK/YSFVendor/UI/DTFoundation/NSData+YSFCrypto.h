//
//  NSData+YSFCrypto.h
//  YSFFoundation
//
//  Created by Stefan Gugarel on 10/3/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Useful cryptography methods.
 */

@interface NSData (YSFCrypto)

/**-------------------------------------------------------------------------------------
 @name Generating HMAC Hashes
 ---------------------------------------------------------------------------------------
 */

/**
 Generates a HMAC from the receiver using the SHA1 algorithm
 @param key The encryption key
 @returns The encrypted hash
 */
- (NSData *)ysf_encryptedDataUsingSHA1WithKey:(NSData *)key;


/**-------------------------------------------------------------------------------------
 @name Digest Hashes
 ---------------------------------------------------------------------------------------
 */

/**
 Generate an MD5 checksum from the receiver
 @returns An `NSData` containing the md5 digest.
 */
-(NSData *)ysf_dataWithMD5Hash;

/**
 Generate an SHA1 checksum from the receiver
 @returns An `NSData` containing the SHA digest.
 */
- (NSData *)ysf_dataWithSHA1Hash;

@end
