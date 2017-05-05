//
//  YSFSessionTipCell.m
//  NIMDemo
//
//  Created by ght on 15-1-28.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionTimestampCell.h"
#import "YSFCellLayoutConfig.h"
#import "YSFTimestampModel.h"
#import "YSFKitUtil.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"

@interface YSFSessionTimestampCell()

@property (nonatomic,strong) YSFTimestampModel *model;

@end

@implementation YSFSessionTimestampCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont boldSystemFontOfSize:[[QYCustomUIConfig sharedInstance] tipMessageTextFontSize]];
        _timeLabel.textColor = [[QYCustomUIConfig sharedInstance] tipMessageTextColor];
        [self addSubview:_timeLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [_timeLabel sizeToFit];
    _timeLabel.center = CGPointMake(self.ysf_frameCenterX, 20);
}


- (void)refreshData:(YSFTimestampModel *)data{
    self.model = data;
    if([self checkData]){
        YSFTimestampModel *model = (YSFTimestampModel *)data;
        [_timeLabel setText:[YSFKitUtil showTime:model.messageTime showDetail:YES]];
    }
}

- (BOOL)checkData{
    return [self.model isKindOfClass:[YSFTimestampModel class]];
}

@end
