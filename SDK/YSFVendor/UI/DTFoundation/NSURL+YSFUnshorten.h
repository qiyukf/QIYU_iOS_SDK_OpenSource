//
//  NSURL+YSFUnshorten.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 6/2/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/** Method for getting the full length URL for a shortened one. 
 
For example:
 
 NSURL *url = [NSURL URLWithString:@"buff.ly/L4uGoza"];
 
 [url unshortenWithCompletion:^(NSURL *url) {
 NSLog(@"Unshortened: %@", url);
 }];

 */

typedef void (^NSURLUnshortenCompletionHandler)(NSURL *);

@interface NSURL (YSFUnshorten)

/**
 Unshortens the receiver and returns the long URL via the completion handler.
 
 Results are cached and therefore a subsequent call for the same receiver will return instantly if the result is still present in the cache.
 @param completion The completion handler
 */
- (void)ysf_unshortenWithCompletion:(NSURLUnshortenCompletionHandler)completion;

@end
