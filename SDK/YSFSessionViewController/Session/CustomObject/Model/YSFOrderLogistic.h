#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"


@interface YSFOrderLogisticNode : NSObject

@property (nonatomic,copy)    NSString *logistic;
@property (nonatomic,copy)    NSString *timestamp;

@end



@interface YSFOrderLogistic : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *title;
@property (nonatomic,copy)    NSArray *logistic;
@property (nonatomic,strong)  YSFAction* action;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
