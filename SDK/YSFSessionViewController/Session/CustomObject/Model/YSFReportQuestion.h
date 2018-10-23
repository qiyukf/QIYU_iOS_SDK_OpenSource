#import "YSFIMCustomSystemMessageApi.h"

@interface YSFReportQuestion : NSObject <YSF_NIMCustomAttachment>
@property (nonatomic, assign) NSInteger command;
@property (nonatomic, copy) NSString *question;
@property (nonatomic, assign) long long questionId;
@property (nonatomic, copy) NSString *messageId;

+ (YSFReportQuestion *)objectByDict:(NSDictionary *)dict;

@end
