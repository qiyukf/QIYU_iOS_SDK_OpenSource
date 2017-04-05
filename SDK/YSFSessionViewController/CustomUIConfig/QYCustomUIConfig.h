//
//  QYCustomUIConfig.h
//  QYCustomUIConfig
//
//  Created by towik on 12/21/15.
//  Copyright (c) 2015 Netease. All rights reserved.
//

/**
 *  自定义UI配置类；如果想要替换图片素材，可以在QYCustomResource.bundle中放置跟QYResource.bundle中同名的图片素材，即可对应替换
 */
@interface QYCustomUIConfig : NSObject

+ (instancetype)sharedInstance;

/**
 *  恢复成默认设置
 *
 *  @return void
 */
- (void)restoreToDefault;

/**
 *  会话窗口上方提示条中的文本字体颜色
 */
@property (nonatomic, strong) UIColor *sessionTipTextColor;

/**
 *  会话窗口上方提示条中的文本字体大小
 */
@property (nonatomic, assign) CGFloat sessionTipTextFontSize;

/**
 *  会话窗口上方提示条中的背景颜色
 */
@property (nonatomic, strong) UIColor *sessionTipBackgroundColor;

/**
 *  访客文本消息字体颜色
 */
@property (nonatomic, strong) UIColor *customMessageTextColor;

/**
 *  访客文本消息中的链接字体颜色
 */
@property (nonatomic, strong) UIColor *customMessageHyperLinkColor;

/**
 *  访客文本消息字体大小
 */
@property (nonatomic, assign) CGFloat customMessageTextFontSize;

/**
 *  客服文本消息字体颜色
 */
@property (nonatomic, strong) UIColor *serviceMessageTextColor;

/**
 *  客服文本消息中的链接字体颜色
 */
@property (nonatomic, strong) UIColor *serviceMessageHyperLinkColor;

/**
 *  客服文本消息字体大小
 */
@property (nonatomic, assign) CGFloat serviceMessageTextFontSize;

/**
 *  提示文本消息字体颜色；提示文本消息有很多种，比如“***为你服务”就是一种
 */
@property (nonatomic, strong) UIColor *tipMessageTextColor;

/**
 *  提示文本消息字体大小；提示文本消息有很多种，比如“***为你服务”就是一种
 */
@property (nonatomic, assign) CGFloat tipMessageTextFontSize;

/**
 *  输入框文本消息字体颜色
 */
@property (nonatomic, strong) UIColor *inputTextColor;

/**
 *  输入框文本消息字体大小
 */
@property (nonatomic, assign) CGFloat inputTextFontSize;

/**
 *  消息tableview的背景图片
 */
@property (nonatomic, strong) UIImageView *sessionBackground;

/**
 *  访客头像
 */
@property (nonatomic, strong) UIImage *customerHeadImage;
@property (nonatomic, copy) NSString *customerHeadImageUrl;

/**
 *  客服头像
 */
@property (nonatomic, strong) UIImage *serviceHeadImage;
@property (nonatomic, copy) NSString *serviceHeadImageUrl;

/**
 *  访客消息气泡normal图片
 */
@property (nonatomic, strong) UIImage *customerMessageBubbleNormalImage;

/**
 *  访客消息气泡pressed图片
 */
@property (nonatomic, strong) UIImage *customerMessageBubblePressedImage;

/**
 *  客服消息气泡normal图片
 */
@property (nonatomic, strong) UIImage *serviceMessageBubbleNormalImage;

/**
 *  客服消息气泡pressed图片
 */
@property (nonatomic, strong) UIImage *serviceMessageBubblePressedImage;

/**
 *  消息竖直方向间距
 */
@property (nonatomic, assign) CGFloat sessionMessageSpacing;

/**
 *  是否显示头像
 */
@property (nonatomic, assign) BOOL showHeadImage;

/**
 *  默认是YES,默认rightBarButtonItem内容是黑色，设置为NO，可以修改为白色
 */
@property (nonatomic, assign) BOOL rightBarButtonItemColorBlackOrWhite;

/**
 *  默认是YES,默认显示发送语音入口，设置为NO，可以修改为隐藏
 */
@property (nonatomic, assign) BOOL showAudioEntry;

/**
 *  默认是YES,默认在机器人模式下显示发送语音入口，设置为NO，可以修改为隐藏
 */
@property (nonatomic, assign) BOOL showAudioEntryInRobotMode;

/**
 *  默认是YES,默认显示发送表情入口，设置为NO，可以修改为隐藏
 */
@property (nonatomic, assign) BOOL showEmoticonEntry;

/**
 *  默认是YES,默认进入聊天界面，是文本输入模式的话，会弹出键盘，设置为NO，可以修改为不弹出
 */
@property (nonatomic, assign) BOOL autoShowKeyboard;

/**
 *  表示聊天组件离界面底部的间距，默认是0；比较典型的是底部有tabbar，这时候设置为tabbar的高度即可
 */
@property (nonatomic, assign) CGFloat bottomMargin;

/**
 *  聊天窗口右上角商铺入口显示，默认不显示
 */
@property (nonatomic, assign)   BOOL showShopEntrance;

/**
 *  聊天窗口右上角商铺入口icon
 */
@property (nonatomic, strong) UIImage *shopEntranceImage;

/**
 *  聊天窗口右上角商铺入口文本
 */
@property (nonatomic, copy) NSString *shopEntranceText;

/**
 *  聊天窗口右边会话列表入口，默认不显示
 */
@property (nonatomic, assign) BOOL showSessionListEntrance;

/**
 *  会话列表入口在聊天页面的位置，YES代表在右上角，NO代表在左上角，默认在右上角
 */
@property (nonatomic, assign) BOOL sessionListEntrancePosition;

/**
 *  会话列表入口icon
 */
@property (nonatomic, strong) UIImage *sessionListEntranceImage;

@end

@interface QYCustomUIConfig()
@property (nonatomic, assign) BOOL sdkOrKf;
@end 


