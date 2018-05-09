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
@property (nonatomic, strong) NSMutableArray<YSFQuickReplyKeyWordAndContent*> *dataArray;
@property (nonatomic, weak) id<YSFQuickReplyContentViewDelegate> delegate;
@property (nonatomic, assign) BOOL onlyMatchFirst;

- (instancetype)initWithFrame:(CGRect)frame NS_DESIGNATED_INITIALIZER;

- (void)update;

@end
