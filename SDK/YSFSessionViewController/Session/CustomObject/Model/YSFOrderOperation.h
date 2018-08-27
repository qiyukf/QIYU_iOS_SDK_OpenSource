#import "YSFIMCustomSystemMessageApi.h"


@interface YSFOrderOperation : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic, assign) NSInteger command;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, copy) NSString *params;
@property (nonatomic, copy) NSString *label;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSDictionary *templateInfo;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
