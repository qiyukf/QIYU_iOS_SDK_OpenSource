//
//  NIMSessionUnknowContentView.h
//  YSFKit
//
//  Created by chris on 15/3/9.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionUnknowContentView.h"
#import "YSFMessageModel.h"

@interface YSFSessionUnknowContentView()

@property (nonatomic,strong) UILabel *label;

@end

@implementation YSFSessionUnknowContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        //
        _label = [[UILabel alloc] initWithFrame:CGRectZero];
        _label.font = [UIFont systemFontOfSize:14.f];
        _label.userInteractionEnabled = NO;
        [self addSubview:_label];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    NSString *text = @"未知类型消息";
    [self.label setText:text];
    [self.label sizeToFit];
    
    if ([YSF_NIMSDK sharedSDK].sdkOrKf) {
        if (!self.model.message.isOutgoingMsg) {
            self.label.backgroundColor = [UIColor clearColor];
            self.label.textColor = [UIColor blackColor];
        }else{
            self.label.backgroundColor = [UIColor clearColor];
            self.label.textColor = [UIColor whiteColor];
        }
    }
    else {
        if (!self.model.message.isOutgoingMsg) {
            self.label.backgroundColor = [UIColor clearColor];
            self.label.textColor = [UIColor whiteColor];
        }else{
            self.label.backgroundColor = [UIColor clearColor];
            self.label.textColor = [UIColor blackColor];
        }
    }
}


- (void)layoutSubviews{
    [super layoutSubviews];
    _label.ysf_frameCenterX = self.ysf_frameWidth  * .5f;
    _label.ysf_frameCenterY = self.ysf_frameHeight * .5f;
}

@end
