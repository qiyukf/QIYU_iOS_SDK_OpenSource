#import "YSFStaticUnionContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFStaticUnion.h"
#import "UIImageView+YSFWebCache.h"
#import "UIControl+BlocksKit.h"



@interface YSFStaticUnionContentView()

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
        
        if ([item.type isEqualToString:@"text"]) {
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
        else if ([item.type isEqualToString:@"image"]) {
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
        else if ([item.type isEqualToString:@"link"]) {
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
    [self.delegate onCatchEvent:event];
}


@end
