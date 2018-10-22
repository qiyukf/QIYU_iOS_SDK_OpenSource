#import "YSFIMCustomSystemMessageApi.h"
#import "YSFAction.h"
#import "YSFCustomAttachment.h"

@interface YSFLinkItem : NSObject

@property (nonatomic,copy)    NSString *type;
@property (nonatomic,copy)    NSString *label;
@property (nonatomic,copy)    NSString *imageUrl;
@property (nonatomic,copy)    NSString *target;
@property (nonatomic,copy)    NSString *linkType;
@property (nonatomic,copy)    NSString *params;

@end


@interface YSFStaticUnion : NSObject <YSFCustomAttachment>

@property (nonatomic,strong)  NSArray<YSFLinkItem *> *linkItems;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *imageUrlStringArray;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
