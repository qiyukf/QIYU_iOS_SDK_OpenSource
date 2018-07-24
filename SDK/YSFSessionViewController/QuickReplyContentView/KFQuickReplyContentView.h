//
//  KFQuickReplyContentView.h
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSFSendSearchQuestionResponse.h"

@protocol YSFQuickReplyContentViewDelegate<NSObject>

- (void)didTapRowAtIndex:(NSUInteger)index data:(YSFQuickReplyKeyWordAndContent*)data;

@end

@interface YSFQuickReplyContentView : UIView

@property (nonatomic, copy) NSString *searchText;
@property (nonatomic, weak) id<YSFQuickReplyContentViewDelegate> delegate;
@property (nonatomic, assign) BOOL onlyMatchFirst;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

//更新数据源
- (void)updateDataArray:(NSArray<YSFQuickReplyKeyWordAndContent *>*)dataArray;

// 快捷回复条目数
- (NSUInteger)itemCount;

- (CGFloat)viewHeight;

@end
