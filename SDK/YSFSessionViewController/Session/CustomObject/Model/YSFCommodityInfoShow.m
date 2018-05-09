//
//  YSFProductInfoShow.m
//  YSFSessionViewController
//
//  Created by JackyYu on 16/5/25.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "YSFCommodityInfoShow.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "NSArray+YSF.h"
#import "YSFCommodityInfoContentConfig.h"



@implementation YSFCommodityInfoShow

- (NSString *)thumbText
{
    return @"发送了一条消息";
}

- (YSFCommodityInfoContentConfig *)contentConfig
{
    return [YSFCommodityInfoContentConfig new];
}

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]      = @(_command);
    dict[YSFApiKeyTitle]    = YSFStrParam(_title);
    dict[YSFApiKeyDesc]     = YSFStrParam(_desc);
    dict[YSFApiKeyPicture]  = YSFStrParam(_pictureUrlString);
    dict[YSFApiKeyUrl]      = YSFStrParam(_urlString);
    dict[YSFApiKeyNote]     = YSFStrParam(_note);
    dict[YSFApiKeyExt]     = YSFStrParam(_ext);
    dict[YSFApiKeyShow]     = _show ? @(1) : @(0);
    dict[YSFApiKeyAuto]     = _bAuto ? @(1) : @(0);
    if (_tagsString.length == 0) {
        NSMutableArray *array = [NSMutableArray new];
        for (QYCommodityTag *tag in _tagsArray) {
            NSMutableDictionary *tagDict = [NSMutableDictionary dictionary];
            tagDict[YSFApiKeyLabel]     = YSFStrParam(tag.label);
            tagDict[YSFApiKeyUrl]     = YSFStrParam(tag.url);
            tagDict[YSFApiKeyFocusIframe]     = YSFStrParam(tag.focusIframe);
            tagDict[YSFApiKeyData]     = YSFStrParam(tag.data);
            [array addObject:tagDict];
        }
        dict[YSFApiKeyTags] = [array ysf_toUTF8String];
    }
    else {
        dict[YSFApiKeyTags] = YSFStrParam(_tagsString);
    }

    return dict;
}

+(YSFCommodityInfoShow *)objectByDict:(NSDictionary *)dict
{
    YSFCommodityInfoShow *instance = [[YSFCommodityInfoShow alloc] init];
    instance.command             = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.title               = [dict ysf_jsonString:YSFApiKeyTitle];
    instance.desc                = [dict ysf_jsonString:YSFApiKeyDesc];
    instance.pictureUrlString    = [dict ysf_jsonString:YSFApiKeyPicture];
    instance.urlString           = [dict ysf_jsonString:YSFApiKeyUrl];
    instance.note                = [dict ysf_jsonString:YSFApiKeyNote];
    instance.ext            = [dict ysf_jsonString:YSFApiKeyExt];
    instance.show                = [dict ysf_jsonBool:YSFApiKeyShow];
    instance.bAuto                = [dict ysf_jsonBool:YSFApiKeyAuto];
    
    NSMutableArray *tagArray = [NSMutableArray new];
    NSArray *array                = [dict ysf_jsonArray:YSFApiKeyTags];
    for (NSDictionary *dict in array) {
        QYCommodityTag *tag = [QYCommodityTag new];
        tag.label            = [dict ysf_jsonString:YSFApiKeyLabel];
        tag.url              = [dict ysf_jsonString:YSFApiKeyUrl];
        tag.focusIframe      = [dict ysf_jsonString:YSFApiKeyFocusIframe];
        tag.data             = [dict ysf_jsonString:YSFApiKeyData];
        [tagArray addObject:tag];
    }
    instance.tagsArray = tagArray;

    return instance;
}



@end
