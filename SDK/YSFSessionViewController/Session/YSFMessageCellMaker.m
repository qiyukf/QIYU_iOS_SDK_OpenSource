//
//  NIMMessageCellMaker.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFMessageCellMaker.h"
#import "YSFMessageModel.h"
#import "YSFTimestampModel.h"
@implementation YSFMessageCellMaker

+ (YSFMessageCell *)cellInTable:(UITableView*)tableView
                 forMessageMode:(YSFMessageModel *)model;
{
    id<YSFCellLayoutConfig> config = model.layoutConfig;
    NSString *identity = [config cellContent:model];
    YSFMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"YSFMessageCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return (YSFMessageCell *)cell;
}

+ (YSFSessionTimestampCell *)cellInTable:(UITableView *)tableView
                            forTimeModel:(YSFTimestampModel *)model
{
    NSString *identity = @"time";
    YSFSessionTimestampCell *cell = [tableView dequeueReusableCellWithIdentifier:identity];
    if (!cell) {
        NSString *clz = @"YSFSessionTimestampCell";
        [tableView registerClass:NSClassFromString(clz) forCellReuseIdentifier:identity];
        cell = [tableView dequeueReusableCellWithIdentifier:identity];
    }
    [cell refreshData:model];
    return (YSFSessionTimestampCell *)cell;

}


@end
