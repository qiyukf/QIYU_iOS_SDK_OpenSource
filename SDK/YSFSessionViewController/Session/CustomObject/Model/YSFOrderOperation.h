#import "YSFIMCustomSystemMessageApi.h"


@interface YSFOrderOperation : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)    NSString   *target;
@property (nonatomic,copy)    NSString   *params;
@property (nonatomic,copy)    NSDictionary   *template;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
