//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSubmittedBotFormContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFAttributedLabel.h"
#import "YSFAttributedLabel+YSF.h"
#import "YSFApiDefines.h"
#import "YSF_NIMMessage+YSF.h"
#import "YSFSubmittedBotForm.h"
#import "NIMPathManager.h"
#import "NSString+FileTransfer.h"

@interface YSFSubmittedBotFormImage : UIImageView

@property (nonatomic, strong) NSString *imageFilePath;

@end

@implementation YSFSubmittedBotFormImage

@end


@interface YSFSubmittedBotFormContentView()
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewsArray;

@end

@implementation YSFSubmittedBotFormContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _content = [UIView new];
        _content.userInteractionEnabled = YES;
        [self addSubview:_content];
        
        _imageViewsArray = [NSMutableArray new];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];

    [_imageViewsArray removeAllObjects];

    self.bubbleImageView.image = [[UIImage ysf_imageInKit:@"icon_sender_node_normal_white"]
                                      resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                      resizingMode:UIImageResizingModeStretch];
    self.bubbleImageView.highlightedImage = [[UIImage ysf_imageInKit:@"icon_sender_node_pressed_white"]
                                             resizableImageWithCapInsets:UIEdgeInsetsMake(25,10,10,10)
                                             resizingMode:UIImageResizingModeStretch];
    [_content ysf_removeAllSubviews];

    __block CGFloat offsetY = 0;
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)self.model.message.messageObject;
    YSFSubmittedBotForm *attachment = (YSFSubmittedBotForm *)object.attachment;
    [attachment.forms enumerateObjectsUsingBlock:^(YSFSubmittedBotFormCell *botFormCell, NSUInteger idx, BOOL * _Nonnull stop) {
        UILabel *label = [UILabel new];
        label.numberOfLines = 0;
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize:16];
        label.text = botFormCell.label;
        CGSize size = [label sizeThatFits:CGSizeMake(self.model.contentSize.width, 0)];
        offsetY += 10;
        label.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                         self.model.contentSize.width, size.height);
        [_content addSubview:label];
        
        offsetY += size.height;
        offsetY += 10;

        if ([botFormCell.type isEqualToString:@"image"]) {
            if (botFormCell.imageValue.count > 0) {
                YSFSubmittedBotFormImage *removeImageView = [YSFSubmittedBotFormImage new];
                removeImageView.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapImage:)];
                [removeImageView addGestureRecognizer:tap];
                removeImageView.ysf_frameLeft = self.model.contentViewInsets.left;
                removeImageView.ysf_frameTop = offsetY;
                removeImageView.ysf_frameWidth = 170;
                removeImageView.ysf_frameHeight = 43;
                removeImageView.backgroundColor = YSFRGB(0xfafafa);
                removeImageView.layer.borderWidth = 0.5;
                removeImageView.layer.borderColor = YSFRGB(0xcccccc).CGColor;
                [_content addSubview:removeImageView];
                [_imageViewsArray addObject:removeImageView];
                
                UIImageView *imageView = [UIImageView new];
                imageView.userInteractionEnabled = YES;
                imageView.image = [UIImage ysf_imageInKit:@"icon_botform_image"];
                imageView.frame = CGRectMake(5, 5, 29, 33);
                [removeImageView addSubview:imageView];
                
                UILabel *imageName = [UILabel new];
                imageName.userInteractionEnabled = YES;
                imageName.text = botFormCell.imageName;
                imageName.frame = CGRectMake(43, 3, 110, 20);
                imageName.font = [UIFont systemFontOfSize:14];
                [removeImageView addSubview:imageName];
                
                UILabel *imageSize = [UILabel new];
                imageSize.userInteractionEnabled = YES;
                imageSize.text = [NSString getFileSizeTextWithFileLength:botFormCell.imageFileSize];
                imageSize.frame = CGRectMake(43, 21, 110, 20);
                imageSize.font = [UIFont systemFontOfSize:14];
                [removeImageView addSubview:imageSize];
                
                offsetY += removeImageView.ysf_frameHeight;
            }
            
        }
        else {
            UILabel *value = [UILabel new];
            value.numberOfLines = 0;
            value.textColor = [UIColor blackColor];
            value.font = [UIFont systemFontOfSize:16];
            value.text = botFormCell.value;
            CGSize size2 = [value sizeThatFits:CGSizeMake(self.model.contentSize.width, 0)];
            value.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                     self.model.contentSize.width, size2.height);
            [_content addSubview:value];
            
            offsetY += size2.height;
        }
        offsetY += 10;
        
        if (idx != attachment.forms.count - 1) {
            UIView *splitLine = [UIView new];
            splitLine.backgroundColor = YSFRGB(0xdbdbdb);
            splitLine.ysf_frameTop = offsetY;
            splitLine.ysf_frameHeight = 0.5;
            splitLine.ysf_frameLeft = 0;
            if (![YSF_NIMSDK sharedSDK].sdkOrKf) {
                splitLine.ysf_frameLeft = 5;
            }
            splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
            [_content addSubview:splitLine];
        }

    }];
}

- (void)tapImage:(UITapGestureRecognizer *)gesture
{
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapRichTextImage;
    event.message = self.model.message;
    event.data = gesture.view;
    [self.delegate onCatchEvent:event];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}


@end
