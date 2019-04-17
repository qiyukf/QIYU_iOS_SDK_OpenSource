#import "YSFCustomAttachment.h"

@interface YSFRichText : NSObject<YSFCustomAttachment>

//命令
@property (nonatomic, assign) NSInteger command;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, copy) NSString *displayContent;
@property (nonatomic, strong, readonly) NSMutableArray<NSString *> *imageUrlStringArray;

@property (nonatomic, assign) BOOL customEmoticon;

+ (YSFRichText *)objectByDict:(NSDictionary *)dict;
+ (YSFRichText *)objectByParams:(NSInteger)cmd content:(NSString *)content;

@end
