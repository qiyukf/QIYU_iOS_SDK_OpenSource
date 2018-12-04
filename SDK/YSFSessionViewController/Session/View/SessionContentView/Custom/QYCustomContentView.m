//
//  QYCustomContentView.m
//  YSFSDK
//
//  Created by liaosipei on 2018/11/27.
//  Copyright © 2018 Netease. All rights reserved.
//

#import "QYCustomContentView.h"
#import "QYCustomContentView_Private.h"

@implementation QYCustomContentView
- (instancetype)initCustomContentView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        
    }
    return self;
}

- (void)refreshData:(QYCustomModel *)model {
    self.model = model;
}

@end
