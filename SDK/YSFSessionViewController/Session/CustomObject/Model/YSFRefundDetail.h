#import "YSFIMCustomSystemMessageApi.h"


@interface YSFRefundDetail : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *refundStateType;
@property (nonatomic,copy)    NSString *refundStateText;
@property (nonatomic,copy)    NSArray<NSString *> *contentList;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
