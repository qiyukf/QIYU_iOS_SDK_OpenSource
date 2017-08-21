//
//  YSFSessionTipView.h
//  YSFSDK
//
//  Created by amao on 9/14/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//


typedef enum : NSUInteger {
    YSFSessionTipOK,                        //初始状态
    YSFSessionTipNetworkError,              //网络出错
    YSFSessionTipNetworkOK,                 //网络正常
    YSFSessionTipRequestServiceFailed,      //请求客服失败 (请求未发送成功或者服务器没响应)
    YSFSessionTipServiceNotExsit,            //客服不在线
    YSFSessionTipServicewaiting,            //正在排队
} YSFSessionTipType;

@class YSFSessionTipView;

@protocol YSFSessionTipViewDelegate <NSObject>
- (void)tipViewRequestService:(YSFSessionTipView *)tipView;
@end

@interface YSFSessionTipView : UIView
@property (nonatomic,weak)  id<YSFSessionTipViewDelegate> delegate;

- (CGFloat)getTipLabelHeight;
- (void)setSessionTip:(YSFSessionTipType)type;
- (void)setSessionTipForWaiting:(BOOL)showNumber waitingNumber:(NSInteger)waitingNumber
    inQueeuStr:(NSString *)inQueeuStr;
- (void)setSessionTipForNotExist:(NSString *)tip;

@end
