#import "YSFIMCustomSystemMessageApi.h"
#import "QYUserInfo.h"

@interface YSFSetInfoRequest : NSObject<YSFIMCustomSystemMessageApiProtocol>

@property (nonatomic,strong)    QYUserInfo    *userInfo;
@property (nonatomic,copy)      NSString    *authToken;

@end
