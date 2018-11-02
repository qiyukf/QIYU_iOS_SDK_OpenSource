
@interface YSFAction : NSObject

@property (nonatomic,copy)    NSString *style;
@property (nonatomic,copy)    NSString *type;
@property (nonatomic,copy)    NSString *url;
@property (nonatomic,copy)    NSString *params;
@property (nonatomic,copy)    NSString *target;
@property (nonatomic,copy)    NSString *validOperation;
@property (nonatomic,copy)    NSString *title;

+ (instancetype)objectByDict:(NSDictionary *)dict;
- (NSString *)toJsonString;

@end
