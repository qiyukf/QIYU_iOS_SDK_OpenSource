//
//  YSFMiniProgramPage.m
//  YSFSessionViewController
//
//  Created by liaosipei on 2018/9/20.
//  Copyright © 2018年 Netease. All rights reserved.
//

#import "YSFMiniProgramPage.h"
#import "YSFCustomAttachment.h"
#import "YSFApiDefines.h"
#import "YSFMiniProgramPageContentConfig.h"

@implementation YSFMiniProgramPage

- (NSString *)thumbText {
    return @"[小程序卡片]";
}

- (YSFMiniProgramPageContentConfig *)contentConfig {
    return [[YSFMiniProgramPageContentConfig alloc] init];
}

+ (instancetype)objectByDict:(NSDictionary *)dict {
    YSFMiniProgramPage *miniProgram = [[YSFMiniProgramPage alloc] init];
    miniProgram.headImgURL = [dict ysf_jsonString:YSFApiKeyHeadImage];
    if (!miniProgram.headImgURL.length) {
        miniProgram.headImgURL = [dict ysf_jsonString:YSFApiTolerantKeyHeadImage];
    }
    miniProgram.name = [dict ysf_jsonString:YSFApiKeyName];
    miniProgram.title = [dict ysf_jsonString:YSFApiKeyMiniTitle];
    if (!miniProgram.title.length) {
        miniProgram.title = [dict ysf_jsonString:YSFApiTolerantKeyMiniTitle];
    }
    miniProgram.coverImgURL = [dict ysf_jsonString:YSFApiKeyThumbUrl];
    if (!miniProgram.coverImgURL.length) {
        miniProgram.coverImgURL = [dict ysf_jsonString:YSFApiTolerantKeyThumbUrl];
    }
    return miniProgram;
}

@end
