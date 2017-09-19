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

@implementation YSFCommodityInfoShow

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
    dict[YSFApiKeyShow]     = @(_show);
    
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
    
    return instance;
}



@end
