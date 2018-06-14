#import "YSFRefundDetailContentView.h"
#import "NSDictionary+YSFJson.h"
#import "YSFMessageModel.h"
#import "YSFRefundDetail.h"

@interface YSFRefundDetailContentView()

@property (nonatomic, strong) UIView *content;
@property (nonatomic,strong) UIImageView * imageView;
@property (nonatomic,strong) UILabel * titleLabel;

@end

@implementation YSFRefundDetailContentView

- (instancetype)initSessionMessageContentView {
    self = [super initSessionMessageContentView];
    if (self) {
        _content = [UIView new];
        [self addSubview:_content];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data
{
    [super refresh:data];
    
    [_content ysf_removeAllSubviews];
    __block CGFloat offsetY = self.model.contentViewInsets.top;
    offsetY += 13;

    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFRefundDetail *refundDetail = (YSFRefundDetail *)object.attachment;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.numberOfLines = 0;
    label.font = [UIFont systemFontOfSize:16.f];
    label.text = refundDetail.label;
    label.frame = CGRectMake(18, offsetY,
                             self.model.contentSize.width - 28, 0);
    [label sizeToFit];
    [_content addSubview:label];
    
    offsetY += label.ysf_frameHeight;
    offsetY += 13;

    UIView *splitLine = [UIView new];
    splitLine.backgroundColor = YSFRGB(0xdbdbdb);
    splitLine.ysf_frameHeight = 0.5;
    splitLine.ysf_frameLeft = 5;
    splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
    splitLine.ysf_frameTop = offsetY;
    [_content addSubview:splitLine];
    
    offsetY += 13;

    UIImageView *imageView = [UIImageView new];
    imageView.frame = CGRectMake(18, offsetY - 1, 0, 0);
    [_content addSubview:imageView];
    
    UILabel *refundState = [[UILabel alloc] initWithFrame:CGRectZero];
    refundState.numberOfLines = 0;
    refundState.font = [UIFont systemFontOfSize:15.f];
    refundState.text = refundDetail.refundStateText;
    refundState.frame = CGRectMake(48, offsetY,
                             self.model.contentSize.width - 58, 0);
    if ([refundDetail.refundStateType isEqualToString:@"success"]) {
        imageView.image = [UIImage ysf_imageInKit:@"icon_success"];
        refundState.textColor = YSFRGB(0x4cac35);
    }
    else {
        imageView.image = [UIImage ysf_imageInKit:@"icon_failed"];
        refundState.textColor = [UIColor redColor];
    }
    [imageView sizeToFit];
    [refundState sizeToFit];
    [_content addSubview:refundState];
    
    offsetY += refundState.ysf_frameHeight;
    offsetY += 13;
    
    [refundDetail.contentList enumerateObjectsUsingBlock:^(NSString * _Nonnull contentStr, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > 0)
        {
            offsetY += 13;
        }
        
        UILabel *refundContent = [[UILabel alloc] initWithFrame:CGRectZero];
        refundContent.font = [UIFont systemFontOfSize:15.f];
        refundContent.numberOfLines = 0;
        refundContent.text = contentStr;
        refundContent.frame = CGRectMake(18, offsetY,
                                         self.model.contentSize.width - 28, 0);
        [refundContent sizeToFit];
        offsetY += refundContent.ysf_frameHeight;
        [self.content addSubview:refundContent];
        
    }];


}

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


@end
