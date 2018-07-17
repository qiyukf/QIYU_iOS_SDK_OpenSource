#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"
#import "YSFCustomAttachment.h"

@interface YSFSelectedCommodityInfo : NSObject<YSFCustomAttachment>

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)    NSString   *target;
@property (nonatomic,copy)    NSString   *params;
@property (nonatomic,strong)    QYSelectedCommodityInfo   *goods;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
