#import "YSFHttpApi.h"

typedef NS_ENUM(NSInteger, YSFUploadLogType) {
    YSFUploadLogTypeInvite,             //收到cmd=163消息
    YSFUploadLogTypeSDKInitFail,        //SDK初始化失败
    YSFUploadLogTypeRequestStaffFail,   //请求客服失败
};

@interface YSFUploadLog : NSObject<YSFApiProtocol>

@property (nonatomic, copy) NSString *version;
@property (nonatomic, copy) NSString *logString;
@property (nonatomic, assign) YSFUploadLogType type;

@end
