#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"

@interface YSFQueryOrderListResponse : NSObject

@property (nonatomic,strong)    YSFOrderList *orderList;

+ (instancetype)dataByJson:(NSDictionary *)dict;

@end
