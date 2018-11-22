//
//  QYCustomSessionViewController.h
//  QYSDK
//
//  Created by Netease on 2018/11/19.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYSessionViewController.h"

/**
 *  QYSessionViewController的分类，扩展自定义视图相关接口
 */
@interface QYSessionViewController (CustomView)

/**
 *  注册聊天界面顶部悬停视图
 *
 *  @param hoverView 顶部悬停视图
 *  @param height 视图高度
 *  @param insets 视图边距，默认UIEdgeInsetsZero；top表示视图与导航栏底部距离，bottom设置无效，left/right分别表示距离屏幕左右边距
 */
- (void)registerTopHoverView:(UIView *)hoverView height:(CGFloat)height marginInsets:(UIEdgeInsets)insets;

/**
 *  销毁聊天界面顶部悬停视图
 */
- (void)destroyTopHoverViewWithAnmation:(BOOL)animated duration:(NSTimeInterval)duration;

@end
