#import "YSFStaticUnion.h"
#import "NSDictionary+YSFJson.h"
#import "YSFStaticUnionContentConfig.h"
#import "YSFCoreText.h"

@implementation YSFLinkItem

@end

@interface YSFStaticUnion() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFStaticUnion

- (NSString *)thumbText
{
    return @"[查询消息]";
}

- (YSFStaticUnionContentConfig *)contentConfig
{
    return [YSFStaticUnionContentConfig new];
}

+ (instancetype)objectByDict:(NSDictionary *)dict
{
    YSFStaticUnion *staticUnion = [YSFStaticUnion new];
    staticUnion.imageUrlStringArray = [NSMutableArray new];

    NSMutableArray<YSFLinkItem *> *tmpLinkItems = [NSMutableArray<YSFLinkItem *> new];
    NSArray *items = [dict ysf_jsonArray:YSFApiKeyUnions];
    for (NSDictionary *dict in items) {
        YSFLinkItem *item = [YSFLinkItem new];
        NSString *type = [dict ysf_jsonString:YSFApiKeyType];
        item.type = type;
        NSDictionary *detail = [dict ysf_jsonDict:YSFApiKeyDetail];
        if ([type isEqualToString:YSFApiKeyText]) {
            item.label = [detail ysf_jsonString:YSFApiKeyLabel];
        }
        else if ([type isEqualToString:YSFApiKeyImage])
        {
            item.imageUrl = [detail ysf_jsonString:YSFApiKeyUrl];
            if (item.imageUrl.length) {
                [staticUnion.imageUrlStringArray addObject:item.imageUrl];
            }
        }
        else if ([type isEqualToString:YSFApiKeyLink])
        {
            item.label = [detail ysf_jsonString:YSFApiKeyLabel];
            item.target = [detail ysf_jsonString:YSFApiKeyTarget];
            item.params = [detail ysf_jsonString:YSFApiKeyParams];
            item.linkType = [detail ysf_jsonString:YSFApiKeyType];
        }
        else if ([type isEqualToString:YSFApiKeyRichText])
        {
            item.label = [detail ysf_jsonString:YSFApiKeyLabel];
            
            YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
            textView.textDelegate = staticUnion;
            textView.shouldDrawImages = NO;
            NSData *data = [item.label dataUsingEncoding:NSUTF8StringEncoding];
            NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
            textView.attributedString = string;
            [textView layoutSubviews];
            
        }
        [tmpLinkItems addObject:item];
    }
    staticUnion.linkItems = tmpLinkItems;
    
    return staticUnion;
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
