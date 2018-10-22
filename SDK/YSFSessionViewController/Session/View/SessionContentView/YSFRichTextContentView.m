#import "YSFRichTextContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFCoreText.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"
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

- (instancetype)initSessionMessageContentView{
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

- (void)refresh:(YSFMessageModel *)data
{
    [super refresh:data];
    [_imageViewsArray removeAllObjects];
    
    _textView.frame = CGRectMake(self.model.contentViewInsets.left, self.model.contentViewInsets.top,
                              self.model.contentSize.width, self.model.contentSize.height);
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    YSFRichText *attachment = (YSFRichText *)object.attachment;
    _textView.attributedString = [self _attributedString:attachment.content];
    
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
}

- (NSAttributedString *)_attributedString:(NSString *)text
{
    NSRegularExpression *exp = [NSRegularExpression regularExpressionWithPattern:@"\\[[a-zA-Z0-9\\u4e00-\\u9fa5]+\\]"
                                                                         options:NSRegularExpressionCaseInsensitive
                                                                           error:nil];
    __block NSInteger index = 0;
    __block NSString *resultText = @"";
    [exp enumerateMatchesInString:text
                          options:0
                            range:NSMakeRange(0, [text length])
                       usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
                           NSString *rangeText = [text substringWithRange:result.range];
                           if ([[YSFInputEmoticonManager sharedManager] emoticonByTag:rangeText]) {
                               if (result.range.location > index) {
                                   NSString *rawText = [text substringWithRange:NSMakeRange(index, result.range.location - index)];
                                   resultText = [resultText stringByAppendingString:rawText];
                               }
                               NSString *rawText = [NSString stringWithFormat:@"<object type=\"0\" data=\"%@\" width=\"18\" height=\"18\"></object>", rangeText];
                               resultText = [resultText stringByAppendingString:rawText];
                               index = result.range.location + result.range.length;
                           }
                       }];
    
    if (index < [text length]) {
        NSString *rawText = [text substringWithRange:NSMakeRange(index, [text length] - index)];
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
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        defaultTextColor = uiConfig.customMessageTextColor;
        defaultLinkColor = uiConfig.customMessageHyperLinkColor;
    } else {
        defaultTextColor = uiConfig.serviceMessageTextColor;
        defaultLinkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    NSMutableDictionary *options = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSValue valueWithCGSize:maxImageSize], YSFMaxImageSize, @(16), YSFDefaultFontSize, defaultTextColor, YSFDefaultTextColor, defaultLinkColor, YSFDefaultLinkColor, nil];
    NSAttributedString *string = [[NSAttributedString alloc] ysf_initWithHTMLData:data options:options documentAttributes:NULL];
    
    return string;
}

#pragma mark Private Methods


#pragma mark Custom Views on Text

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForLink:(NSURL *)url identifier:(NSString *)identifier2 frame:(CGRect)frame
{
    NSURL *URL = url;
    NSString *identifier = identifier2;
    
    YSFLinkButton *button = [[YSFLinkButton alloc] initWithFrame:frame];
    button.URL = URL;
    button.minimumHitSize = CGSizeMake(25, 25); // adjusts it's bounds so that button is always large enough
    button.GUID = identifier;
    
    // use normal push action for opening URL
    [button addTarget:self action:@selector(linkPushed:) forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForAttachment:(YSFTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = YSFRGB(0xebebeb);
        imageView.contentMode = UIViewContentModeCenter;
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
        [imageView ysf_setImageWithURL:attachment.contentURL placeholderImage:placeHoderImage
                             completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                         YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
            if (error != nil) {
                UIImage *failedImage = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                imageView.image = failedImage;
            }
            else {
                if (!CGRectEqualToRect(orginalRect, frame)) {
                    [attachment setDisplaySize:orginalRect.size];
                    [attributedTextContentView.superview setNeedsLayout];
                }
                imageView.contentMode = UIViewContentModeScaleToFill;
                imageView.backgroundColor = [UIColor clearColor];
            }
        }];
        
        // NOTE: this is a hack, you probably want to use your own image view and touch handling
        // also, this treats an image with a hyperlink by itself because we don't have the GUID of the link parts
        imageView.userInteractionEnabled = YES;
        
        // demonstrate combination with long press
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
        [imageView addGestureRecognizer:tap];
        
        imageView.tag = (NSInteger)_imageViewsArray.count;
        [_imageViewsArray addObject:imageView];
        
        return imageView;
    }
    else if ([attachment isKindOfClass:[YSFObjectTextAttachment class]])
    {
        UIImageView *someView = [[UIImageView alloc] initWithFrame:frame];
        NSInteger type = [[attachment.attributes objectForKey:@"type"] integerValue];
        if (type == 0) {    //emoji
            NSString *emojiStr = [attachment.attributes objectForKey:@"data"];
            YSFInputEmoticon *emoticon = [[YSFInputEmoticonManager sharedManager] emoticonByTag:emojiStr];
            UIImage *image = [UIImage imageNamed:emoticon.filename];
            someView.image = image;
        }
        
        return someView;
    }
    
    return nil;
}


#pragma mark Actions

- (void)tapImage:(UITapGestureRecognizer *)gesture
{
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

- (void)linkPushed:(YSFLinkButton *)button
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapLabelLink;
    event.message = self.model.message;
    event.data = button.URL.relativeString;
    [self.delegate onCatchEvent:event];
}

- (void)actionClick:(NSString *)actionUrl
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapPushMessageActionUrl;
    event.message = self.model.message;
    event.data = actionUrl;
    [self.delegate onCatchEvent:event];
}

@end










