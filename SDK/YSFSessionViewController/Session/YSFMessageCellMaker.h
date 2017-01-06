//
//  NIMMessageCellMaker.h
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageCell.h"
#import "YSFCellLayoutConfig.h"
#import "YSFMessageCellProtocol.h"
#import "YSFSessionTimestampCell.h"

@interface YSFMessageCellMaker : NSObject

+ (YSFMessageCell *)cellInTable:(UITableView*)tableView
                 forMessageMode:(YSFMessageModel *)model;

+ (YSFSessionTimestampCell *)cellInTable:(UITableView *)tableView
                            forTimeModel:(YSFTimestampModel *)model;

@end
