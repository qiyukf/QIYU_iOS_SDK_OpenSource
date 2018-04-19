//
//  UITableView+YSFKit.h
//  NIMDemo
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIScrollView (YSF)

- (void)ysf_scrollToBottom:(BOOL)animation;
-(BOOL)ysf_isInBottom;
@end
