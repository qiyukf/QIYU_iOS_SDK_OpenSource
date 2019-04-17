//
//  YSFMenuModel.m
//  YSFSDK
//
//  Created by liaosipei on 2019/3/27.
//  Copyright © 2019 Netease. All rights reserved.
//

#import "YSFMenuModel.h"
#import "YSFApiDefines.h"

@implementation YSFMenuModel
+ (instancetype)dataByJson:(NSDictionary *)dict {
    YSFMenuModel *model = [[YSFMenuModel alloc] init];
    model.text = [dict ysf_jsonString:YSFApiKeyText];
    model.selected = NO;
    return model;
}

- (instancetype)initWithText:(NSString *)text selected:(BOOL)selected {
    self = [super init];
    if (self) {
        _text = text;
        _selected = selected;
    }
    return self;
}

@end
