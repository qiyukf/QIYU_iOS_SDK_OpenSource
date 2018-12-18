#import "YSFRichText.h"
#import "YSFApiDefines.h"
#import "NSDictionary+YSFJson.h"
#import "YSFCoreText.h"
#import "YSFRichTextContentConfig.h"

@interface YSFRichText() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) NSMutableArray<NSString *> *imageUrlStringArray;

@end

@implementation YSFRichText

- (NSString *)thumbText {
    return self.displayContent;
}

- (YSFRichTextContentConfig *)contentConfig {
    return [YSFRichTextContentConfig new];
}

- (NSDictionary *)encodeAttachment {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[YSFApiKeyCmd] = @(_command);
    dict[YSFApiKeyContent] = YSFStrParam(_content);
    return dict;
}

+ (YSFRichText *)objectByDict:(NSDictionary *)dict {
    YSFRichText *instance = [[YSFRichText alloc] init];
    instance.command = [dict ysf_jsonInteger:YSFApiKeyCmd];
    instance.content = [dict ysf_jsonString:YSFApiKeyContent];
    return instance;
}

+ (YSFRichText *)objectByParams:(NSInteger)cmd content:(NSString *)content {
    YSFRichText *instance = [[YSFRichText alloc] init];
    instance.command = cmd;
    instance.content = content;
    return instance;
}

- (NSString *)displayContent {
    if (!_displayContent) {
        YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        textView.textDelegate = self;
        textView.shouldDrawImages = NO;
        //处理富文本消息中的换行
        NSString *resultStr = self.content;
        if ([resultStr containsString:@"\n"] || [resultStr containsString:@"\r"]) {
            resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
            resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\r" withString:@"<br>"];
        }
        
        NSData *data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributeString = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = attributeString;
        _displayContent = attributeString.string;
    }
    return _displayContent;
}

- (NSMutableArray<NSString *> *)imageUrlStringArray {
    if (_imageUrlStringArray == nil) {
        self.imageUrlStringArray = [NSMutableArray array];
        YSFAttributedTextView *textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        textView.textDelegate = self;
        textView.shouldDrawImages = NO;
        //处理富文本消息中的换行
        NSString *resultStr = self.content;
        if ([resultStr containsString:@"\n"] || [resultStr containsString:@"\r"]) {
            resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
            resultStr = [resultStr stringByReplacingOccurrencesOfString:@"\r" withString:@"<br>"];
        }
        
        NSData *data = [resultStr dataUsingEncoding:NSUTF8StringEncoding];
        NSAttributedString *attributeString = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:0 documentAttributes:NULL];
        textView.attributedString = attributeString;
        [textView layoutSubviews];
        self.displayContent = attributeString.string;
    }
    return _imageUrlStringArray;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView
                    viewForAttachment:(YSFTextAttachment *)attachment
                                frame:(CGRect)frame {
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]]) {
        NSString *urlString = attachment.contentURL.relativeString;
        if (urlString.length) {
            [_imageUrlStringArray addObject:urlString];
        }
    }
    return nil;
}


@end
