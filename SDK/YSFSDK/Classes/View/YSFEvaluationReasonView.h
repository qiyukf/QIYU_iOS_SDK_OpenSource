//
//  YSFEvaluationReasonView.h
//  YSFSDK
//
//  Created by Jacky Yu on 2018/3/1.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YSFEvaluationReasonView;

typedef void(^ReasonViewRemovedBlock)(void);

@protocol YSFEvaluationReasonViewDelegate<NSObject>

- (void)evaluationReasonView:(YSFEvaluationReasonView *)view didConfirmWithText:(NSString *)text;

@end

@interface YSFEvaluationReasonView : UIView


@property (nonatomic, weak) id<YSFEvaluationReasonViewDelegate> delegate;
@property (nonatomic, weak) id data;        //存放数据，如YSF_NIMMessage
@property (nonatomic, copy) ReasonViewRemovedBlock completedBlock;


- (instancetype)initWithFrame:(CGRect)frame content:(NSString *)string holdText:(NSString*)holdText NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame __attribute__((unavailable("use initWithFrame: content:")));
- (instancetype)init __attribute__((unavailable("use initWithFrame:")));
- (instancetype)initWithCoder:(NSCoder *)aDecoder __attribute__((unavailable("use initWithFrame: content:")));
@end
