//
//  QYCustomContentView_Private.h
//  YSFSDK
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYCustomModel.h"
#import "QYCustomMessageProtocol.h"

@interface QYCustomContentView ()

/**
 *  数据模型
 */
@property (nonatomic, strong, readwrite) QYCustomModel *model;

/**
 *  事件代理
 */
@property (nonatomic, weak, readwrite) id<QYCustomContentViewDelegate> delegate;

@end
