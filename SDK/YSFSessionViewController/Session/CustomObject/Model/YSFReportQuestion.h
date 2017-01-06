#import "YSFIMCustomSystemMessageApi.h"

@interface YSFReportQuestion : NSObject<YSF_NIMCustomAttachment>
@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,strong)    NSString *question;
@property (nonatomic,assign)    long long questionId;

+ (YSFReportQuestion *)objectByDict:(NSDictionary *)dict;

@end