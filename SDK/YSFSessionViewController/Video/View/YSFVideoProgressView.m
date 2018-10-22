//
//  YSFVideoProgressView.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/13.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFVideoProgressView.h"

@interface YSFVideoProgressView ()

@property (nonatomic, strong) CALayer *background;
@property (nonatomic, strong) CALayer *progressBar;

@end

@implementation YSFVideoProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (CALayer *)background {
    if (!_background) {
        _background = [[CALayer alloc] init];
        _background.backgroundColor = YSFColorFromRGB(0x666666).CGColor;
        [self.layer addSublayer:_background];
    }
    return _background;
}

- (CALayer *)progressBar {
    if (!_progressBar) {
        _progressBar = [[CALayer alloc] init];
        _progressBar.backgroundColor = YSFColorFromRGB(0x337eff).CGColor;
        [self.background addSublayer:_progressBar];
    }
    return _progressBar;
}

- (void)setProgressValue:(double)progressValue {
    _progressValue = progressValue;
    
    if (progressValue >=0 && progressValue <= 1) {
        CGRect frame = self.progressBar.frame;
        frame.size.width = progressValue * CGRectGetWidth(self.background.frame);
        if (progressValue == 0) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
            self.progressBar.frame = frame;
            [CATransaction commit];
        } else {
            [CATransaction begin];
            [CATransaction setDisableActions:NO];
            self.progressBar.frame = frame;
            [CATransaction commit];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    
    self.background.frame = self.bounds;
    self.background.cornerRadius = roundf(CGRectGetHeight(self.background.frame) / 2);
    
    self.progressBar.frame = CGRectMake(0, 0, 0, CGRectGetHeight(self.background.frame));
    self.progressBar.cornerRadius = roundf(CGRectGetHeight(self.progressBar.frame) / 2);
}

@end
