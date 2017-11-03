//
//  NIMCustomLeftBarView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2014年 Netease. All rights reserved.
//

#import "YSFCustomLeftBarView.h"
#import "YSFBadgeView.h"

@interface YSFCustomLeftBarView()
@property (nonatomic, strong) UIImageView* backImage;
@end

@implementation YSFCustomLeftBarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initSubviews];
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (void)initSubviews
{
    _backImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_back_white"]];
    [self addSubview:_backImage];

    self.badgeView = [YSFBadgeView viewWithBadgeTip:@""];
    self.badgeView.frame = CGRectMake(17, 0, 0, 0);
    self.badgeView.hidden = YES;
    self.badgeView.userInteractionEnabled = NO;
    self.frame = CGRectMake(0.0, 0.0, 50.0, 30.f);
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.badgeView];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.backImage.ysf_frameTop = 4.5;
    self.badgeView.ysf_frameTop = 4;
}
@end
