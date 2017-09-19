#import "YSFFlightListContentView.h"
#import "YSFMessageModel.h"
#import "UIImageView+YSFWebCache.h"





@interface YSFFlightListContentView()

@property (nonatomic, strong) UIView *content;

@end

@implementation YSFFlightListContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _content = [UIView new];
        [self addSubview:_content];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    
    [_content ysf_removeAllSubviews];
    
    CGFloat offsetY = 0;
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFFlightList *fightList = (YSFFlightList *)object.attachment;
    
    if (fightList.label.length > 0) {
        offsetY += 13;
        UILabel *title = [UILabel new];
        title.numberOfLines = 0;
        title.font = [UIFont systemFontOfSize:14];
        title.text = fightList.label;
        title.ysf_frameLeft = self.model.contentViewInsets.left;
        title.ysf_frameTop = offsetY;
        title.ysf_frameWidth = self.model.contentSize.width;
        [title sizeToFit];
        [_content addSubview:title];
        offsetY += title.ysf_frameHeight;
        offsetY += 13;
    }
    
    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 5;
    splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
    splitLine.ysf_frameTop = offsetY;
    [_content addSubview:splitLine];
    
    for (int i = 0; i < fightList.fieldItems.count; i++) {
        YSFFlightItem *item = fightList.fieldItems[i];
        
        YSFCellView *flightCell = [item createCell:self.ysf_frameWidth - 5 eventHander:self];
        flightCell.ysf_frameLeft = 5;
        flightCell.ysf_frameTop = offsetY;
        [_content addSubview:flightCell];
        
        offsetY += flightCell.ysf_frameHeight;
    }
    
    if (fightList.action != nil) {
        YSFCellView *button = [YSFCellView new];
        button.itemData = fightList;
        [button setTitle:fightList.action.validOperation forState:UIControlStateNormal];
        [button setTitleColor:YSFRGB(0x5092E1) forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize:15.f];
        button.ysf_frameLeft = 5;
        button.ysf_frameWidth = self.ysf_frameWidth - 5;
        button.ysf_frameTop = offsetY;
        button.ysf_frameHeight = 40;
        [_content addSubview:button];
        [button addTarget:self action:@selector(onClickMore:) forControlEvents:UIControlEventTouchUpInside];
        
        offsetY += 42;
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
        _content.ysf_frameLeft = -5;
    }
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}

- (void)onClickItem:(YSFCellView *)actionView
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapBot;
    event.message = self.model.message;
    event.data = actionView.itemData;
    [self.delegate onCatchEvent:event];
}

- (void)onClickMore:(YSFCellView *)actionView
{
    YSFFlightList *flightList = actionView.itemData;

    if ([flightList.action.type isEqualToString:@"url"]
        || [flightList.action.type isEqualToString:@"block"]) {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapBot;
        event.message = self.model.message;
        event.data = flightList.action;
        [self.delegate onCatchEvent:event];
    }
    else {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapMoreFlight;
        event.message = self.model.message;
        event.data = actionView.itemData;
        [self.delegate onCatchEvent:event];
    }
}

@end


@implementation YSFFlightItem(YSF)

- (YSFCellView *)createCell:(CGFloat)width eventHander:(id)eventHander
{
    YSFCellView *flightCell = [YSFCellView new];
    if (self.action) {
        [flightCell addTarget:eventHander action:@selector(onClickItem:) forControlEvents:UIControlEventTouchUpInside];
        flightCell.itemData = self.action;
    }
    
    CGFloat offsetY = 0;
    for (NSArray *row in self.fields) {
        offsetY += 13;
        CGFloat rowHeight = 0;
        CGFloat columnWidth = (width - (row.count + 1) * 10) / row.count;
        for (int i = 0; i < row.count; i++) {
            YSFFlightInfoField *field = row[i];
            
            if ([field.type isEqualToString:@"image"]) {
                if (columnWidth > rowHeight) {
                    rowHeight = columnWidth;
                }
                
                UIImageView *imageView = [UIImageView new];
                imageView.backgroundColor = YSFRGB(0xebebeb);
                imageView.contentMode = UIViewContentModeCenter;
                imageView.ysf_frameLeft =  (i + 1) * 10 + i * columnWidth;
                imageView.ysf_frameTop = offsetY;
                imageView.ysf_frameWidth = columnWidth;
                imageView.ysf_frameHeight = columnWidth;
                [flightCell addSubview:imageView];
                
                //                    CGRect orginalRect = frame;
                //                    if (frame.size.width < 90) {
                //                        frame.size.width = 90;
                //                    }
                //                    if (frame.size.height < 90) {
                //                        frame.size.height = 90;
                //                    }
                //                    if (!CGRectEqualToRect(orginalRect, frame)) {
                //                        [attachment setDisplaySize:frame.size];
                //                        [attributedTextContentView.superview setNeedsLayout];
                //                    }
                UIImage *placeHoderImage = [UIImage ysf_imageInKit:@"icon_image_loading_default"];
                [imageView ysf_setImageWithURL:[NSURL URLWithString:field.value] placeholderImage:placeHoderImage
                                     completed:^(UIImage * _Nullable image, NSError * _Nullable error,
                                                 YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                         if (error != nil) {
                                             UIImage *failedImage = [UIImage ysf_imageInKit:@"icon_image_loading_failed"];
                                             imageView.image = failedImage;
                                         }
                                         else {
                                             //                                                 if (!CGRectEqualToRect(orginalRect, frame)) {
                                             //                                                     [attachment setDisplaySize:orginalRect.size];
                                             //                                                     [attributedTextContentView.superview setNeedsLayout];
                                             //                                                 }
                                             imageView.contentMode = UIViewContentModeScaleToFill;
                                             imageView.backgroundColor = [UIColor clearColor];
                                         }
                                     }];
                
                //                    imageView.userInteractionEnabled = YES;
                //                    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
                //                    [imageView addGestureRecognizer:tap];
            }
            else {
                UILabel *label = [UILabel new];
                NSMutableString *tmpStr = [field.color mutableCopy];
                if (tmpStr) {
                    [tmpStr replaceCharactersInRange:[tmpStr rangeOfString:@"#" ] withString:@"0x"];
                    long colorLong = strtoul([tmpStr cStringUsingEncoding:NSUTF8StringEncoding], 0, 16);
                    label.textColor = YSFRGB(colorLong);
                }
                if (field.flag & QYMessageTypeSingleLine) {
                    label.numberOfLines = 1;
                }
                else {
                    label.numberOfLines = 3;
                }
                if ([field.align isEqualToString:@"left"]) {
                    label.textAlignment = NSTextAlignmentLeft;
                }
                else if ([field.align isEqualToString:@"right"]) {
                    label.textAlignment = NSTextAlignmentRight;
                }
                else {
                    label.textAlignment = NSTextAlignmentCenter;
                }
                
                NSMutableAttributedString *attributedText = [[NSMutableAttributedString alloc] initWithString:field.value];
                NSRange attributedTextRange = {0,[attributedText length]};
                if (field.flag & QYMessageTypeBold) {
                    label.font = [UIFont boldSystemFontOfSize:14];
                }
                else {
                    label.font = [UIFont systemFontOfSize:14];
                }
                if (field.flag & QYMessageTypeItalic) {
                    [attributedText addAttribute:NSObliquenessAttributeName value:@(1) range:attributedTextRange];
                }
                if (field.flag & QYMessageTypeUnderline) {
                    [attributedText addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:attributedTextRange];
                }
                label.attributedText = attributedText;
                
                label.ysf_frameLeft = (i + 1) * 10 + i * columnWidth;
                label.ysf_frameTop = offsetY;
                label.ysf_frameWidth = columnWidth;
                label.ysf_frameHeight = [label sizeThatFits:CGSizeMake(columnWidth, 0)].height;
                [flightCell addSubview:label];
                if (label.ysf_frameHeight > rowHeight) {
                    rowHeight = label.ysf_frameHeight;
                }
            }
        }
        offsetY += rowHeight;
        offsetY += 13;
    }
    
    UIView *splitLine2 = [UIView new];
    splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine2.ysf_frameHeight = 0.5;
    splitLine2.ysf_frameLeft = 0;
    splitLine2.ysf_frameWidth = width;
    splitLine2.ysf_frameTop = offsetY;
    [flightCell addSubview:splitLine2];
    
    flightCell.ysf_frameWidth = width;
    flightCell.ysf_frameHeight = offsetY + 0.5;
    return flightCell;
}

@end


