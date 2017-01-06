//
//  YSFSessionTipCell.h
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

@class YSFTimestampModel;

@interface YSFSessionTimestampCell : UITableViewCell

@property (strong, nonatomic) UILabel *timeLabel;

- (void)refreshData:(YSFTimestampModel *)data;

@end
