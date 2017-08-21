#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"

@interface YSFBotFormCell : NSObject

@property (nonatomic,copy)    NSString   *label;
@property (nonatomic,copy)    NSString   *value;
@property (nonatomic,copy)    NSDictionary   *imageValue;
@property (nonatomic,assign)  BOOL   required;
@property (nonatomic,copy)    NSString   *type;
@property (nonatomic,copy)    NSString   *id;
@property (nonatomic,copy, readonly)    NSString   *imageUrl;
@property (nonatomic,copy, readonly)    NSString   *imageName;
@property (nonatomic,assign, readonly)    long long imageFileSize;

@end

@interface YSFBotForm : NSObject<YSF_NIMCustomAttachment>

@property (nonatomic,copy)    NSString   *version;
@property (nonatomic,copy)    NSString   *target;
@property (nonatomic,copy)    NSString   *params;
@property (nonatomic,copy)    NSString   *label;
@property (nonatomic,copy)    NSArray   *forms;
@property (nonatomic,assign)    BOOL   submitted;

- (NSDictionary *)encodeAttachment;
+ (instancetype)objectByDict:(NSDictionary *)dict;

@end





