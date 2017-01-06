//
//  NIMTimestampModel.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFCellLayoutConfig.h"

@interface YSFTimestampModel : NSObject

@property (nonatomic,assign) CGFloat height;

/**
 *  时间戳
 */
@property (nonatomic, assign) NSTimeInterval messageTime;

@end
