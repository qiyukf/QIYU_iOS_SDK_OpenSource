#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"

@interface YSFOrderDetail : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *status;
@property (nonatomic,copy)    NSString *userName;
@property (nonatomic,copy)    NSString *address;
@property (nonatomic,copy)    NSString *orderNo;
@property (nonatomic,copy)    NSString *date;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
