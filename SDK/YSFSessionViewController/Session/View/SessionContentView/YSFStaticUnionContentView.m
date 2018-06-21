#import "YSFStaticUnionContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFStaticUnion.h"
#import "UIImageView+YSFWebCache.h"
#import "UIControl+BlocksKit.h"
#import "YSFCoreText.h"
#import "NSString+FileTransfer.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"

@interface YSFStaticUnionContentView() <YSFAttributedTextContentViewDelegate>

@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewsArray;

@end

@implementation YSFStaticUnionContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _content = [UIView new];
        [self addSubview:_content];
        
        _imageViewsArray = [NSMutableArray new];
    }
    return self;
}


- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
    [_imageViewsArray removeAllObjects];
    [_content ysf_removeAllSubviews];
    
    CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFStaticUnion *staticUnion = (YSFStaticUnion *)object.attachment;
    
    for (YSFLinkItem *item in staticUnion.linkItems) {
        
        if ([item.type isEqualToString:YSFApiKeyText]) {
            offsetY += 13;
            
            UILabel * content;
            content = [UILabel new];
            [_content addSubview:content];
            content.font = [UIFont systemFontOfSize:16];
            content.numberOfLines = 0;
            content.text = item.label;
            content.frame = CGRectMake(18, offsetY,
                                       self.model.contentSize.width - 33, 0);
            [content sizeToFit];
            if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
                content.ysf_frameLeft -= 5;
            }
            
            offsetY += content.ysf_frameHeight;
        }
        else if ([item.type isEqualToString:YSFApiKeyImage]) {
            offsetY += 13;
            
            if (item.imageUrl.length > 0) {
                UIImageView *imageView = [UIImageView new];
                [_content addSubview:imageView];
                imageView.frame = CGRectMake(18, offsetY,
                                             self.model.contentSize.width - 33, 90);
        
                imageView.backgroundColor = YSFRGB(0xebebeb);
                imageView.contentMode = UIViewContentModeCenter;
                imageView.layer.cornerRadius = 2;
                imageView.layer.masksToBounds = YES;
                NSURL *url = nil;
                if (item.imageUrl) {
                    url = [NSURL URLWithString:item.imageUrl];
                }
                if (url) {
                    NSString *key = [[YSFWebImageManager sharedManager] cacheKeyForURL:url];
                    UIImage *image = [[YSFImageCache sharedImageCache] imageFromDiskCacheForKey:key];
                    if (image) {
                        CGFloat width = image.size.width;
                        CGFloat height = image.size.height;
                        if (image.size.width > self.model.contentSize.width - 33) {
                            width = self.model.contentSize.width - 33;
                            height = (height/image.size.width) * width;
                        }
                        imageView.image = image;
                        imageView.ysf_frameWidth = width;
                        imageView.ysf_frameHeight = height;
                        imageView.contentMode = UIViewContentModeScaleToFill;
                        imageView.backgroundColor = [UIColor clearColor];
                    }
                    else {
                        UIImage *placeHoderImage = [UIImage ysf_imageInKit:@"icon_image_loading_default"];
                        [imageView ysf_setImageWithURL:url placeholderImage:placeHoderImage
                                             completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                                         YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                 if (error != nil) {
                                                     UIImage *failedImage = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                                     imageView.image = failedImage;
                                                 }
                                                 else {
                                                     dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                                         [self.model cleanLayoutConfig];
                                                         [self.model cleanCache];
                                                         YSFKitEvent *event = [[YSFKitEvent alloc] init];
                                                         event.eventName = YSFKitEventNameReloadData;
                                                         event.message = self.model.message;
                                                         [self.delegate onCatchEvent:event];
                                                     });
                                                     
                                                     

                                                 }
                                             }];
                    }
                    
                    
                    imageView.userInteractionEnabled = YES;
                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
                    [imageView addGestureRecognizer:tap];
                    [_imageViewsArray addObject:imageView];
                }
                if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
                    imageView.ysf_frameLeft -=5;
                }
                
                offsetY += imageView.ysf_frameHeight;
            }
        }
        else if ([item.type isEqualToString:YSFApiKeyLink]) {
            offsetY += 13;
            
            UIButton *actionButton = [UIButton new];
            [_content addSubview:actionButton];
            
            YSFAction *action = [YSFAction new];
            action.target = item.target;
            action.params = item.params;
            action.validOperation = item.label;
            action.type = item.linkType;
            actionButton.layer.borderWidth = 0.5;
            actionButton.titleLabel.font = [UIFont systemFontOfSize:15];
            actionButton.layer.borderColor = YSFRGB(0x5092E1).CGColor;
            actionButton.layer.cornerRadius = 4;
            [actionButton setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
            [actionButton setTitle:item.label forState:UIControlStateNormal];
            actionButton.frame = CGRectMake(18, offsetY,
                                            self.model.contentSize.width - 33, 34);
            __weak typeof(self) weakSelf = self;
            [actionButton ysf_addEventHandler:^(id  _Nonnull sender) {
                [weakSelf onClickAction:action];
            } forControlEvents:UIControlEventTouchUpInside];
            if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
                actionButton.ysf_frameLeft -= 5;
            }
            
            offsetY += 34;
        }
        else if ([item.type isEqualToString:YSFApiKeyRichText]) {
            offsetY += 13;
            
            YSFAttributedTextView *label = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
            label.shouldDrawImages = NO;
            label.textDelegate = self;
            label.backgroundColor = [UIColor clearColor];
            
            label.attributedString = [item.label ysf_attributedString:self.model.message.isOutgoingMsg];
            label.ysf_frameWidth = self.model.contentSize.width - 33;
            CGSize size = [label.attributedTextContentView sizeThatFits:CGSizeZero];
            label.frame = CGRectMake(18, offsetY,
                                             self.model.contentSize.width - 33, size.height);
            [label layoutSubviews];
            [_content addSubview:label];
            if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
                label.ysf_frameLeft -=5;
            }
            
            offsetY += size.height;
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


- (void)onClickAction:(YSFAction *)action
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = action;
    [self.delegate onCatchEvent:event];
}

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


- (UIView *)attributedTextContentView:(YSFAttributedTextContentView *)attributedTextContentView viewForAttachment:(YSFTextAttachment *)attachment frame:(CGRect)frame
{
    if ([attachment isKindOfClass:[YSFImageTextAttachment class]])
    {
        // if the attachment has a hyperlinkURL then this is currently ignored
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
        imageView.backgroundColor = YSFRGB(0xebebeb);
        imageView.contentMode = UIViewContentModeCenter;
        UIImage *placeHoderImage = [UIImage ysf_imageInKit:@"icon_image_loading_default"];
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


@end
