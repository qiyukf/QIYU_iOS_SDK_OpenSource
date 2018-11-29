//
//  YSFCustomMessageCell.h
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class QYCustomModel;
@protocol QYCustomContentViewDelegate;

@interface YSFCustomMessageCell : UITableViewCell

@property (nonatomic, strong) QYCustomModel *model;
@property (nonatomic, weak) id<QYCustomContentViewDelegate> messageDelegate;

- (void)refreshData:(QYCustomModel *)model;

@end

NS_ASSUME_NONNULL_END
