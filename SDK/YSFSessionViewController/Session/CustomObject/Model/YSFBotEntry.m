#import "YSFBotEntry.h"
#import "NSDictionary+YSFJson.h"
#import "YSFApiDefines.h"
#import "YSFActionBar.h"

@implementation YSFBotEntry

+ (instancetype)dataByJson:(NSDictionary *)dict
{
    YSFBotEntry *instance = [[YSFBotEntry alloc] init];
    NSArray *botEntry = [dict ysf_jsonArray:YSFApiKeyBot];
    NSMutableArray *entryArray = [NSMutableArray arrayWithCapacity:botEntry.count];
    for (NSDictionary *dict in botEntry) {
        YSFActionInfo *entry =  [YSFActionInfo dataByJson:dict];
        [entryArray addObject:entry];
    }
    instance.entryArray = entryArray;
    
    return instance;
}

@end
