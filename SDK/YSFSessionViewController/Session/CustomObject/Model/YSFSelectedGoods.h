#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"

@interface YSFSelectedGoods : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)    NSString   *target;
@property (nonatomic,copy)    NSString   *params;
@property (nonatomic,strong)    YSFGoods   *goods;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
