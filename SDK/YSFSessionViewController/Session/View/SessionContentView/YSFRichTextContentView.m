#import "YSFRichTextContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFCoreText.h"
#import "YSFEmoticonDataManager.h"
#import "YSFAnimatedImageView.h"
#import "YSFRichText.h"
#import "QYCustomUIConfig.h"
#import "UIControl+BlocksKit.h"
#import "YSF_NIMMessage+YSF.h"


@interface YSFRichTextContentView() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) YSFAttributedTextView *textView;
@property (nonatomic, strong) UIView *splitLine;
@property (nonatomic, strong) UIButton *action;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewsArray;

@end


@implementation YSFRichTextContentView
- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _textView = [[YSFAttributedTextView alloc] initWithFrame:CGRectZero];
        _textView.shouldDrawImages = NO;
        _textView.textDelegate = self;
        _textView.backgroundColor = [UIColor clearColor];
        [self addSubview:_textView];
        
        _splitLine = [UIView new];
        _splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        [self addSubview:_splitLine];

        _action = [UIButton new];
        [_action setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        __weak typeof(self) weakSelf = self;
        [_action ysf_addEventHandler:^(id  _Nonnull sender) {
            [weakSelf actionClick:weakSelf.model.message.actionUrl];
        } forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_action];
        
        _imageViewsArray = [NSMutableArray new];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data {
    [super refresh:data];
    [_imageViewsArray removeAllObjects];
    
    _textView.frame = CGRectMake(self.model.contentViewInsets.left, self.model.contentViewInsets.top,
                              self.model.contentSize.width, self.model.contentSize.height);
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    YSFRichText *attachment = (YSFRichText *)object.attachment;
    
    NSString *content = attachment.content;
    if (attachment.customEmoticon) {
        CGFloat scale = [UIScreen mainScreen].scale;
        NSString *old_w = nil;
        NSString *new_w = nil;
        NSRange range_w = NSMakeRange(0, 0);
        NSRange range = [content rangeOfString:@"width=\""];
        if (range.location != NSNotFound) {
            NSUInteger i = (range.location + range.length);
            for (i = (range.location + range.length); i < content.length; i++) {
                NSString *str = [content substringWithRange:NSMakeRange(i, 1)];
                if (str.length) {
                    if ([str isEqualToString:@"\""]) {
                        break;
                    }
                }
            }
            range_w = NSMakeRange((range.location + range.length), i - (range.location + range.length));
            old_w = [content substringWithRange:range_w];
            CGFloat width = roundf([old_w floatValue] / scale);
            new_w = [NSString stringWithFormat:@"%ld", (long)width];
        }
        NSString *old_h = nil;
        NSString *new_h = nil;
        NSRange range_h = NSMakeRange(0, 0);
        range = [content rangeOfString:@"height=\""];
        if (range.location != NSNotFound) {
            NSUInteger i = (range.location + range.length);
            for (i = (range.location + range.length); i < content.length; i++) {
                NSString *str = [content substringWithRange:NSMakeRange(i, 1)];
                if (str.length) {
                    if ([str isEqualToString:@"\""]) {
                        break;
                    }
                }
            }
            range_h = NSMakeRange((range.location + range.length), i - (range.location + range.length));
            old_h = [content substringWithRange:range_h];
            CGFloat height = roundf([old_h floatValue] / scale);
            new_h = [NSString stringWithFormat:@"%ld", (long)height];
        }
        if (new_w.length && range_w.length) {
            content = [content stringByReplacingCharactersInRange:range_w withString:new_w];
        }
        if (new_h.length && range_h.length) {
            content = [content stringByReplacingCharactersInRange:NSMakeRange(range_h.location + (new_w.length - old_w.length), range_h.length)
                                                       withString:new_h];
        }
    }
    
    _textView.attributedString = [self _attributedString:content];
    
    if (self.model.message.isPushMessageType
        && self.model.message.actionText.length) {
        _textView.ysf_frameHeight -= 44;
        _splitLine.hidden = NO;
        _splitLine.ysf_frameTop = _textView.ysf_frameBottom;
        _splitLine.ysf_frameHeight = 0.5;
        _splitLine.ysf_frameLeft = 5;
        _splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.hidden = NO;
        [_action setTitle:self.model.message.actionText forState:UIControlStateNormal];
        _action.titleLabel.font = [UIFont systemFontOfSize:15];
        _action.ysf_frameLeft = 5;
        _action.ysf_frameWidth = self.ysf_frameWidth - 5;
        _action.ysf_frameTop = _splitLine.ysf_frameBottom;
        _action.ysf_frameHeight = 44;
        if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
            _splitLine.ysf_frameLeft = -5;
            _action.ysf_frameLeft = -5;
        }
    } else {
        _splitLine.hidden = YES;
        _action.hidden = YES;
    }
    //自定义表情隐藏气泡
    self.bubbleImageView.hidden = attachment.customEmoticon;
}

#pragma mark - Attributed Text
- (NSAttributedString *)_attributedString:(NSString *)text {
    //识别文本中的<p>标签，替换为<br>
    NSString *filterString = [self filterHTMLString:text forTag:@"p"];
    if (filterString.length <= 0) {
        filterString = text;
    }
    
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]|\\[:[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:filterString
                          options:0
                            range:NSMakeRange(0, [filterString length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [filterString substringWithRange:result.range];
                           if ([[YSFEmoticonDataManager sharedManager] emoticonItemForTag:rangeText]) {
                               if (result.range.location > index) {
                                   NSString *rawText = [filterString substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"21\" height=\"21\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [filterString length]) {
        NSString *rawText = [filterString substringWithRange:NSMakeRange(index, [filterString length] - index)];
        resultText = [resultText stringByAppendingString:rawText];
    }
    //处理富文本消息中的换行
    if ([resultText containsString:@"\n"] || [resultText containsString:@"\r"]) {
        resultText = [resultText stringByReplacingOccurrencesOfString:@"\n" withString:@"<br>"];
        resultText = [resultText stringByReplacingOccurrencesOfString:@"\r" withString:@"<br>"];
    }
    
    resultText = [NSString stringWithFormat:@"<span>%@</span>", resultText];
    NSData *data = [resultText dataUsingEncoding:NSUTF8StringEncoding];
    
    // Create attributed string from HTML
    CGSize maxImageSize = CGSizeMake(239, 425);
    UIColor *defaultTextColor = nil;
    UIColor *defaultLinkColor = nil;
    CGFloat fontSize = 16.0f;
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        defaultTextColor = uiConfig.customMessageTextColor;
        defaultLinkColor = uiConfig.customMessageHyperLinkColor;
        fontSize = uiConfig.customMessageTextFontSize;
    } else {
        defaultTextColor = uiConfig.serviceMessageTextColor;
        defaultLinkColor = uiConfig.serviceMessageHyperLinkColor;
        fontSize = uiConfig.serviceMessageTextFontSize;
    }
    UIFont *font = [UIFont systemFontOfSize:fontSize];
    NSDictionary *options = @{
                              YSFMaxImageSize : [NSValue valueWithCGSize:maxImageSize],
                              YSFDefaultFontFamily : YSFStrParam(font.familyName),
                              YSFDefaultFontName : YSFStrParam(font.fontName),
                              YSFDefaultFontSize : @(fontSize),
                              YSFDefaultTextColor : defaultTextColor,
                              YSFDefaultLinkColor : defaultLinkColor,
                              };
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView
                          viewForLink:(NSURL *)url
                           identifier:(NSString *)identifier2
                                frame:(CGRect)frame {
    NSURL *URL = url;
    NSString *identifier = identifier2;
    
    YSFLinkButton *button = [[YSFLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25);
    button.GUID = identifier;
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView
                    viewForAttachment:(YSFTextAttachment *)attachment
                                frame:(CGRect)frame {
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]]) {
        YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
        YSFRichText *richObj = (YSFRichText *)object.attachment;
        
        CGRect orginalRect = frame;
        if (frame.size.width < 90) {
            frame.size.width = 90;
        }
        if (frame.size.height < 90) {
            frame.size.height = 90;
        }
        if (!CGRectEqualToRect(orginalRect, frame)) {
            [attachment setDisplaySize:frame.size];
            [attributedTextContentView.superview setNeedsLayout];
        }
        UIImage *placeHoderImage = [UIImage ysf_imageInKit:@"icon_image_loading_default"];
        
        if (richObj.customEmoticon) {
            YSFAnimatedImageView *imageView = [[YSFAnimatedImageView alloc] initWithFrame:frame];
            imageView.backgroundColor = [UIColor clearColor];
            imageView.userInteractionEnabled = YES;
            imageView.contentMode = UIViewContentModeCenter;
            [imageView ysf_setImageWithURL:attachment.contentURL
                          placeholderImage:placeHoderImage
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                             YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                     if (error != nil) {
                                         imageView.image = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                     } else {
                                         if (!CGRectEqualToRect(orginalRect, frame)) {
                                             [attachment setDisplaySize:orginalRect.size];
                                             [attributedTextContentView.superview setNeedsLayout];
                                         }
                                         imageView.contentMode = UIViewContentModeScaleToFill;
                                     }
                                 }];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
            [imageView addGestureRecognizer:tap];
            imageView.tag = (NSInteger)_imageViewsArray.count;
            [_imageViewsArray addObject:imageView];
            return imageView;
        } else {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
            imageView.userInteractionEnabled = YES;
            imageView.backgroundColor = YSFRGB(0xebebeb);
            imageView.contentMode = UIViewContentModeCenter;
            [imageView ysf_setImageWithURL:attachment.contentURL
                          placeholderImage:placeHoderImage
                                 completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                             YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                     if (error != nil) {
                                         imageView.image = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                     } else {
                                         if (!CGRectEqualToRect(orginalRect, frame)) {
                                             [attachment setDisplaySize:orginalRect.size];
                                             [attributedTextContentView.superview setNeedsLayout];
                                         }
                                         imageView.contentMode = UIViewContentModeScaleToFill;
                                         imageView.backgroundColor = [UIColor clearColor];
                                     }
                                 }];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
            [imageView addGestureRecognizer:tap];
            imageView.tag = (NSInteger)_imageViewsArray.count;
            [_imageViewsArray addObject:imageView];
            return imageView;
        }
    } else if ([attachment isKindOfClass:[YSFObjectTextAttachment class]]) {
        NSInteger type = [[attachment.attributes objectForKey:@"type"] integerValue];
        if (type == 0) {
            NSString *emojiStr = [attachment.attributes objectForKey:@"data"];
            YSFEmoticonItem *item = [[YSFEmoticonDataManager sharedManager] emoticonItemForTag:emojiStr];
            if (item && (item.type == YSFEmoticonTypeDefaultEmoji || item.type == YSFEmoticonTypeCustomEmoji)) {
                if (item.type == YSFEmoticonTypeDefaultEmoji) {
                    UIImage *image = [UIImage imageNamed:item.filePath];
                    UIImageView *someView = [[UIImageView alloc] initWithFrame:frame];
                    someView.image = image;
                    return someView;
                } else {
                    if ([item.fileURL length]) {
                        UIImageView *someView = [[UIImageView alloc] initWithFrame:frame];
                        someView.backgroundColor = [UIColor lightGrayColor];
                        someView.contentMode = UIViewContentModeScaleAspectFill;
                        [someView ysf_setImageWithURL:[NSURL URLWithString:item.fileURL]
                                            completed:^(UIImage * _Nullable image, NSError * _Nullable error, YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                 if (!error && image) {
                                                     someView.backgroundColor = [UIColor clearColor];
                                                 }
                                             }];
                        return someView;
                    }
                }
            }
        }
    }
    return nil;
}

- (NSString *)filterHTMLString:(NSString *)htmlString forTag:(NSString *)tag {
    if (htmlString.length <= 0 || tag.length <= 0) {
        return htmlString;
    }
    NSString *start = [NSString stringWithFormat:@"<%@>", tag];
    NSString *end = [NSString stringWithFormat:@"</%@>", tag];
    if (![htmlString containsString:start] || ![htmlString containsString:end]) {
        return htmlString;
    }
    
    NSScanner *scanner = [NSScanner scannerWithString:htmlString];
    NSString *text = nil;
    while ([scanner isAtEnd] == NO) {
        [scanner scanUpToString:start intoString:nil];
        [scanner scanUpToString:end intoString:&text];
        if (text.length) {
            NSRange range = [htmlString rangeOfString:text];
            if (range.location != NSNotFound) {
                if ((range.location + start.length) <= [htmlString length]) {
                    htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(range.location, start.length) withString:@""];
                }
                if ((range.location + range.length - start.length) >= 0
                    && (range.location + range.length - start.length + end.length) <= [htmlString length]) {
                    htmlString = [htmlString stringByReplacingCharactersInRange:NSMakeRange(range.location + range.length - start.length, end.length) withString:@"<br>"];
                }
            }
        }
    }
    return htmlString;
}

#pragma mark - Actions
- (void)tapImage:(UITapGestureRecognizer *)gesture {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapRichTextImage;
    event.message = self.model.message;
    event.data = gesture.view;
    NSInteger tagIndex = 0;
    for (id viewObject in _imageViewsArray) {
        if (viewObject == gesture.view) {
            break;
        }
        tagIndex++;
    }
    gesture.view.tag = tagIndex;
    [self.delegate onCatchEvent:event];
}

- (void)linkPushed:(YSFLinkButton *)button {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapLabelLink;
    event.message = self.model.message;
    event.data = button.URL.relativeString;
    [self.delegate onCatchEvent:event];
}

- (void)actionClick:(NSString *)actionUrl {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapPushMessageActionUrl;
    event.message = self.model.message;
    event.data = actionUrl;
    [self.delegate onCatchEvent:event];
}

@end










