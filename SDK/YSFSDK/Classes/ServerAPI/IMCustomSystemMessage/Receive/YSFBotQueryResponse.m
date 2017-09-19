#import "YSFBotQueryResponse.h"
#import "QYSDK_Private.h"
#import "YSFOrderList.h"
#import "YSFFlightList.h"
#import "YSFFlightList.h"

@implementation YSFBotQueryResponse

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    NSDictionary *templateDict = [dict ysf_jsonDict:YSFApiKeyTemplate];
    NSString *templateId = [templateDict ysf_jsonString:YSFApiKeyId];
    YSFBotQueryResponse * response = [YSFBotQueryResponse new];
    if ([templateId isEqualToString:@"order_list"]) {
        response.botQueryData = [YSFOrderList objectByDict:templateDict];
    }
    else if ([templateId isEqualToString:@"card_layout"]) {
        response.botQueryData = [YSFFlightList objectByDict:templateDict];
    }
    else if ([templateId isEqualToString:@"detail_view"]) {
        YSFFlightThumbnailAndDetail *fightDetail = [YSFFlightThumbnailAndDetail objectByDict:templateDict];
        YSFFlightList *fightList = [YSFFlightList objectByFlightThumbnail:fightDetail.thumbnail];
        fightList.detail = fightDetail.detail;
        response.botQueryData = fightList;
    }
    else if ([templateId isEqualToString:@"pair"]) {
        YSFFlightDetail *fightDetail = [YSFFlightDetail objectByDict:templateDict];
        YSFFlightList *fightList = [YSFFlightList new];
        fightList.detail = fightDetail;
        response.botQueryData = fightList;
    }
    
    return response;
}

@end
