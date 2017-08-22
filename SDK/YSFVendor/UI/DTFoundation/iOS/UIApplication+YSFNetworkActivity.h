//
//  UIApplication+YSFNetworkActivity.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 5/21/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Enhancement for `UIApplication` to properly count active network sessions and show the network activity indicator whenever there are more than 0 active sessions.
 */
@interface UIApplication (YSFNetworkActivity)

/**
 Increments the number of active network operations
 */
- (void)ysf_pushActiveNetworkOperation;

/**
 Decrements the number of active network operations
 */
- (void)ysf_popActiveNetworkOperation;

@end
