#import "YSFHttpApi.h"


@interface YSFUploadLog : NSObject<YSFApiProtocol>

@property (nonatomic, copy) NSString *apiAddress;
@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, assign) long long time;

@end
