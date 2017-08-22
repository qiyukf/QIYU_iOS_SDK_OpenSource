//
//  NSMutableArray+YSFMoving.h
//  YSFFoundation
//
//  Created by Oliver Drobnik on 9/27/12.
//  Copyright (c) 2012 Cocoanetics. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Methods that add convenient moving methods to `NSMutableArray`.
 */

@interface NSMutableArray (YSFMoving)

/**
 Moves the object at the specified indexes to the new location.
 
 @param indexes The indexes of the objects to move.
 @param idx The index in the mutable array at which to insert the objects.
 */
- (void)ysf_moveObjectsAtIndexes:(NSIndexSet *)indexes toIndex:(NSUInteger)idx;

@end
