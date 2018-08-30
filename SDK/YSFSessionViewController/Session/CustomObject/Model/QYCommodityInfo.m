//
//  QYCommodityInfo.m
//  YSFSDK
//
//  Created by JackyYu on 16/5/26.
//  Copyright © 2016年 Netease. All rights reserved.
//

#import "QYCommodityInfo_private.h"
#import "YSFApiDefines.h"
#import "NSArray+YSF.h"
#import "YSFCommodityInfoContentConfig.h"
#import "QYCommodityInfo.h"
#import "UIColor+YSF.h"

@implementation QYCommodityTag
@end

@implementation QYCommodityInfo

- (instancetype)init
{
    self = [super init];
    if (self) {
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone{
    QYCommodityInfo * commdityInfo =  [[[self class] allocWithZone:zone] init];
    commdityInfo.title = _title;
    commdityInfo.desc = _desc;
    commdityInfo.pictureUrlString = _pictureUrlString;
    commdityInfo.urlString = _urlString;
    commdityInfo.note = _note;
    commdityInfo.show = _show;
    commdityInfo.tagsArray = _tagsArray;
    commdityInfo.tagsString = _tagsString;
    commdityInfo.isCustom = _isCustom;
    commdityInfo.sendByUser = _sendByUser;
    commdityInfo.actionText = _actionText;
    commdityInfo.actionTextColor = _actionTextColor;
    commdityInfo.ext = _ext;
    commdityInfo.payMoney = _payMoney;
    commdityInfo.price = _price;
    commdityInfo.orderCount = _orderCount;
    commdityInfo.orderSku = _orderSku;
    commdityInfo.orderStatus = _orderStatus;
    commdityInfo.orderId = _orderId;
    commdityInfo.orderTime = _orderTime;
    commdityInfo.activity = _activity;
    commdityInfo.activityHref = _activityHref;
    commdityInfo.bAuto = _bAuto;
    
    return commdityInfo;
}

//对title,desc,note有字数限制要求
- (void)checkCommodityInfoValid
{
    if (_title.length > 100) {
        self.title  = [_title substringToIndex:99];
    }
    if (_desc.length > 300) {
        self.desc = [_desc substringToIndex:299];
    }
    if (_note.length > 100) {
        self.note = [_note substringToIndex:99];
    }
    self.pictureUrlString = [_pictureUrlString ysf_trim];    
}

- (BOOL)isEqual:(id)object
{
    if ([object isMemberOfClass:[QYCommodityInfo class]])
    {
        QYCommodityInfo *newCommodityInfo = object;
        if (!_sendByUser) {
            if (((!_title && !newCommodityInfo.title) || [_title isEqualToString:newCommodityInfo.title])
                && ((!_desc && !newCommodityInfo.desc) || [_desc isEqualToString:newCommodityInfo.desc])
                && ((!_urlString && !newCommodityInfo.urlString) || [_urlString isEqualToString:newCommodityInfo.urlString])) {
                return YES;
            }
        }
        else {
            if ((!_pictureUrlString && !newCommodityInfo.pictureUrlString) || [_pictureUrlString isEqualToString:newCommodityInfo.pictureUrlString])
            {
                return YES;
            }
        }
    }
    
    return NO;
}


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
    
    dict[YSFApiKeyCmd]      = @(YSFCommandSetCommodityInfoRequest);
    dict[YSFApiKeyTitle]    = YSFStrParam(_title);
    dict[YSFApiKeyDesc]     = YSFStrParam(_desc);
    dict[YSFApiKeyPicture]  = YSFStrParam(_pictureUrlString);
    dict[YSFApiKeyUrl]      = YSFStrParam(_urlString);
    dict[YSFApiKeyNote]     = YSFStrParam(_note);
    dict[YSFApiKeyExt]     = YSFStrParam(_ext);
    dict[YSFApiKeyShow]     = _show ? @(1) : @(0);
    dict[YSFApiKeyAuto]     = _bAuto ? @(1) : @(0);
    dict[YSFApiKeyPayMoney]     = YSFStrParam(_payMoney);
    dict[YSFApiKeyPrice]     = YSFStrParam(_price);
    dict[YSFApiKeyOrderCount]     = YSFStrParam(_orderCount);
    dict[YSFApiKeyOrderSku]     = YSFStrParam(_orderSku);
    dict[YSFApiKeyOrderStatus]     = YSFStrParam(_orderStatus);
    dict[YSFApiKeyOrderId]     = YSFStrParam(_orderId);
    dict[YSFApiKeyOrderTime]     = YSFStrParam(_orderTime);
    dict[YSFApiKeyActivity]     = YSFStrParam(_activity);
    dict[YSFApiKeyActivityHref]     = YSFStrParam(_activityHref);
    if (_isCustom) {
        dict[YSFApiKeyTemplate]     = YSFApiKeyPictureLink;
    }
    dict[YSFApiKeyActionText]     = YSFStrParam(_actionText);
    dict[YSFApiKeyActionTextColor]     = [_actionTextColor ysf_HEXString];
    
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

+(QYCommodityInfo *)objectByDict:(NSDictionary *)dict
{
    QYCommodityInfo *instance = [[QYCommodityInfo alloc] init];
    instance.title               = [dict ysf_jsonString:YSFApiKeyTitle];
    instance.desc                = [dict ysf_jsonString:YSFApiKeyDesc];
    instance.pictureUrlString    = [dict ysf_jsonString:YSFApiKeyPicture];
    instance.urlString           = [dict ysf_jsonString:YSFApiKeyUrl];
    instance.note                = [dict ysf_jsonString:YSFApiKeyNote];
    instance.ext            = [dict ysf_jsonString:YSFApiKeyExt];
    if (!instance.ext) {
        NSDictionary *extDict = [dict ysf_jsonDict:YSFApiKeyExt];
        if (extDict) {
            NSError *error = nil;
            NSData *data = [NSJSONSerialization dataWithJSONObject:extDict options:NSJSONWritingPrettyPrinted error:&error];
            if (data && !error) {
                instance.ext = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
        }
    }
    instance.show                = [dict ysf_jsonBool:YSFApiKeyShow];
    instance.bAuto                = [dict ysf_jsonBool:YSFApiKeyAuto];
    instance.payMoney                = [dict ysf_jsonString:YSFApiKeyPayMoney];
    instance.price                = [dict ysf_jsonString:YSFApiKeyPrice];
    instance.orderCount                = [dict ysf_jsonString:YSFApiKeyOrderCount];
    instance.orderSku                = [dict ysf_jsonString:YSFApiKeyOrderSku];
    instance.orderStatus                = [dict ysf_jsonString:YSFApiKeyOrderStatus];
    instance.orderId                = [dict ysf_jsonString:YSFApiKeyOrderId];
    instance.orderTime                = [dict ysf_jsonString:YSFApiKeyOrderTime];
    instance.activity                = [dict ysf_jsonString:YSFApiKeyActivity];
    instance.activityHref                = [dict ysf_jsonString:YSFApiKeyActivityHref];
    instance.actionText                = [dict ysf_jsonString:YSFApiKeyActionText];
    instance.actionTextColor                = [UIColor ysf_colorWithHexString:[dict ysf_jsonString:YSFApiKeyActionTextColor]];
    NSString *templateString                = [dict ysf_jsonString:YSFApiKeyTemplate];
    instance.isCustom = [templateString isEqualToString:YSFApiKeyPictureLink];
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
