//
//  KFQuickReplyPreviewView.h
//  QYKF
//
//  Created by Jacky Yu on 2018/3/7.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)(void);
typedef void(^SendBlock)(void);

@interface YSFQuickReplyPreviewView : UIView

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) SendBlock sendBlock;

- (instancetype)initWithContent:(NSString *)content isRichContent:(BOOL)isRichContent NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;

@end
