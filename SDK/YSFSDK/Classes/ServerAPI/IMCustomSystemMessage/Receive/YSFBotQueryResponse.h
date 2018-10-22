#import "YSFIMCustomSystemMessageApi.h"

@interface YSFBotQueryResponse : NSObject

@property (nonatomic, strong) id botQueryData;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end
