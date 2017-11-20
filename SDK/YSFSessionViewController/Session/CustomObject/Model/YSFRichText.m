
#import "YSFRichText.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "YSFCoreText.h"

@interface YSFRichText() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFRichText

- (NSDictionary *)encodeAttachment
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    dict[YSFApiKeyCmd]      = @(_command);
    dict[YSFApiKeyContent]    = YSFStrParam(_content);
    
    return dict;
}

+(YSFRichText *)objectByDict:(NSDictionary *)dict
{
    YSFRichText *instance = [[YSFRichText alloc] init];
    instance.command             = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.content               = [dict ysf_jsonString:YSFApiKeyContent];
    
    return instance;
}

- (NSMutableArray<NSString *> *)imageUrlStringArray
{
    if (_imageUrlStringArray == nil) {
        self.imageUrlStringArray = [NSMutableArray new];
        YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        textView.textDelegate = self;
        textView.shouldDrawImages = NO;
        
        NSData *data = [self.content dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributeString = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = attributeString;
        self.displayContent = attributeString.string;
        [textView layoutSubviews];
    }
    
    return _imageUrlStringArray;
}

+ (YSFRichText *)objectByParams:(NSInteger)cmd content:(NSString *)content
{
    YSFRichText *instance = [[YSFRichText alloc] init];
    instance.command             = cmd;
    instance.content               = content;
    
    return instance;
}

- (NSString *)displayContent
{
    if (!_displayContent) {
        YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        textView.textDelegate = self;
        textView.shouldDrawImages = NO;
        
        NSData *data = [self.content dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributeString = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = attributeString;
        self.displayContent = attributeString.string;
    }
    
    return _displayContent;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForAttachment:(YSFTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]])
    {
        NSString *urlString = attachment.contentURL.relativeString;
        if (urlString.length) {
            [_imageUrlStringArray addObject:urlString];
        }
    }
    return nil;
}


@end
