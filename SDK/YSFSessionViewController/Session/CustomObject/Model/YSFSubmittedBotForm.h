#import "YSFIMCustomSystemMessageApi.h"
#import "YSFOrderList.h"
#import "YSFCustomAttachment.h"


@interface YSFSubmittedBotFormCell : NSObject

@property (nonatomic,copy)    NSString   *label;
@property (nonatomic,copy)    NSString   *type;
@property (nonatomic,copy)    NSString   *value;
@property (nonatomic,copy)    NSDictionary   *imageValue;
@property (nonatomic,copy, readonly)    NSString   *imageUrl;
@property (nonatomic,copy, readonly)    NSString   *imageName;
@property (nonatomic,assign, readonly)    long long  imageFileSize;

@end

@interface YSFSubmittedBotForm : NSObject<YSFCustomAttachment>

@property (nonatomic,assign)    NSInteger   command;
@property (nonatomic,copy)    NSString   *params;
@property (nonatomic,copy)    NSArray   *forms;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *imageUrlStringArray;

+ (instancetype)objectByDict:(NSDictionary *)dict;
- (void)setImageUrlString:(NSArray *)forms;

@end

