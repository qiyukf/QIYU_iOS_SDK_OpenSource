
@interface YSFAction : NSObject

@property (nonatomic,copy)    NSString *style;
@property (nonatomic,copy)    NSString *type;
@property (nonatomic,copy)    NSString *url;
@property (nonatomic,copy)    NSString *params;
@property (nonatomic,copy)    NSString *target;
@property (nonatomic,copy)    NSString *validOperation;

+ (instancetype)objectByDict:(NSDictionary *)dict;

@end
