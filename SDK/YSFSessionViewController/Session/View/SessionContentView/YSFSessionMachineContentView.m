//
//  NIMSessionTextContentView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 Netease. All rights reserved.
//

#import "YSFSessionMachineContentView.h"
#import "YSFMessageModel.h"
#import "QYCustomUIConfig.h"
#import "YSFMachineResponse.h"
#import "YSFAttributedLabel.h"
#import "YSFApiDefines.h"
#import "YSFCoreText.h"
#import "UIImageView+YSFWebCache.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputEmoticonParser.h"
#import "YSFRichText.h"
#import "NSString+FileTransfer.h"


@interface QuestionLink : NSObject
@property (nonatomic, copy) NSDictionary *questionDict;

@end

@implementation QuestionLink

@end


@interface YSFSessionMachineContentView()<YSFAttributedLabelDelegate, YSFAttributedTextContentViewDelegate>
@property (nonatomic, strong) UIView *content;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *imageViewsArray;
@property (nonatomic, strong) UIView *reasonView;
@end

@implementation YSFSessionMachineContentView

-(instancetype)initSessionMessageContentView
{
    if (self = [super initSessionMessageContentView]) {
        _content = [UIView new];
        [self addSubview:_content];
        _imageViewsArray = [NSMutableArray new];
    }
    return self;
}

- (void)refresh:(YSFMessageModel *)data{
    [super refresh:data];
    __block CGFloat offsetY = self.model.contentViewInsets.top;

    [_content ysf_removeAllSubviews];
    [_imageViewsArray removeAllObjects];
    
    YSFAttributedTextView *answerLabel = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
    answerLabel.shouldDrawImages = NO;
    answerLabel.textDelegate = self;
    answerLabel.backgroundColor = [UIColor clearColor];
    
    YSF_NIMCustomObject *object = (YSF_NIMCustomObject *)data.message.messageObject;
    YSFMachineResponse *attachment = (YSFMachineResponse *)object.attachment;
    NSString *tmpAnswerLabel = attachment.answerLabel; //unescapeHtml];
    answerLabel.attributedString = [tmpAnswerLabel ysf_attributedString:self.model.message.isOutgoingMsg];

    if (answerLabel.attributedString.length > 0) {
        offsetY += 15.5;
        answerLabel.ysf_frameWidth = self.model.contentSize.width;
        CGSize size = [answerLabel.attributedTextContentView sizeThatFits:CGSizeZero];
        answerLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                       self.model.contentSize.width, size.height);
        [answerLabel layoutSubviews];
        [_content addSubview:answerLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    
    if (attachment.answerArray.count == 1 && !attachment.isOneQuestionRelevant) {
        YSFAttributedTextView *questionLabel = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        questionLabel.shouldDrawImages = NO;
        questionLabel.textDelegate = self;
        questionLabel.backgroundColor = [UIColor clearColor];

        NSString *answer = @"";
        NSDictionary *dict = [attachment.answerArray objectAtIndex:0];
        NSString *oneAnswer = [dict objectForKey:YSFApiKeyAnswer];
        if (oneAnswer) {
            answer = [answer stringByAppendingString:oneAnswer];
        }
        //answer = [answer unescapeHtml];
        questionLabel.attributedString = [answer ysf_attributedString:self.model.message.isOutgoingMsg];
        questionLabel.ysf_frameWidth = self.model.contentSize.width;
        CGSize size = [questionLabel.attributedTextContentView sizeThatFits:CGSizeZero];
        offsetY += 15.5;
        questionLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                         self.model.contentSize.width, size.height);
        [questionLabel layoutSubviews];
        [_content addSubview:questionLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    else if ((attachment.answerArray.count == 1 && attachment.isOneQuestionRelevant)
             || attachment.answerArray.count > 1)
    {
        UIView *splitLine = [UIView new];
        splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        splitLine.ysf_frameHeight = 0.5;
        splitLine.ysf_frameLeft = 5;
        splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
        splitLine.ysf_frameTop = offsetY;
        [_content addSubview:splitLine];
        
        [attachment.answerArray enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *question = [dict objectForKey:YSFApiKeyQuestion];
            if (question) {
                UIView *point = [UIView new];
                point.backgroundColor = YSFRGB(0xd6d6d6);
                point.ysf_frameHeight = 7.5;
                point.ysf_frameLeft = 18;
                point.ysf_frameWidth = 7.5;
                point.layer.cornerRadius = 4;
                point.ysf_frameTop = offsetY + 23;
                [self.content addSubview:point];

                QuestionLink *questionLink = [[QuestionLink alloc] init];
                questionLink.questionDict = dict;
                
                YSFAttributedLabel *questionLabel = [self newAttrubutedLabel];
                [questionLabel setText:question];
                [questionLabel addCustomLink:questionLink forRange:NSMakeRange(0, question.length)];
                CGSize size = [questionLabel sizeThatFits:CGSizeMake(self.model.contentSize.width - 15, CGFLOAT_MAX)];
                offsetY += 15.5;
                questionLabel.frame = CGRectMake(self.model.contentViewInsets.left + 15, offsetY,
                                                 self.model.contentSize.width - 15, size.height);
                [self.content addSubview:questionLabel];
                offsetY += size.height;
                offsetY += -9;
            }
        }];
        offsetY += 22;
    }
    
    if (attachment.operatorHint && attachment.operatorHintDesc.length > 0) {
        if (_content.subviews.count > 0) {
            UIView *splitLine = [UIView new];
            splitLine.backgroundColor = YSFRGB(0xdbdbdb);
            splitLine.ysf_frameHeight = 0.5;
            splitLine.ysf_frameLeft = 5;
            splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
            splitLine.ysf_frameTop = offsetY;
            [_content addSubview:splitLine];
        }
        
        YSFAttributedTextView *questionLabel = [[YSFAttributedTextView alloc] initWithFrame:CGRectInfinite];
        questionLabel.shouldDrawImages = NO;
        questionLabel.textDelegate = self;
        questionLabel.backgroundColor = [UIColor clearColor];
        NSString *tmpOperatorHintDesc = attachment.operatorHintDesc; //unescapeHtml];
        questionLabel.attributedString = [tmpOperatorHintDesc ysf_attributedString:self.model.message.isOutgoingMsg];
        questionLabel.ysf_frameWidth = self.model.contentSize.width;
        CGSize size = [questionLabel.attributedTextContentView sizeThatFits:CGSizeZero];
        offsetY += 15.5;
        questionLabel.frame = CGRectMake(self.model.contentViewInsets.left, offsetY,
                                         self.model.contentSize.width, size.height);
        [questionLabel layoutSubviews];
        [_content addSubview:questionLabel];
        offsetY += size.height;
        offsetY += 13;
    }
    
    if (attachment.evaluation != YSFEvaluationSelectionTypeInvisible && attachment.shouldShow) {
        UIView *splitLine = [UIView new];
        splitLine.backgroundColor = YSFRGB(0xdbdbdb);
        splitLine.ysf_frameHeight = 0.5;
        splitLine.ysf_frameLeft = 5;
        splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
        splitLine.ysf_frameTop = offsetY;
        [_content addSubview:splitLine];
        
        UIView *splitLine2 = [UIView new];
        splitLine2.backgroundColor = YSFRGB(0xdbdbdb);
        splitLine2.ysf_frameHeight = 17;
        splitLine2.ysf_frameLeft = (self.ysf_frameWidth - 5) / 2;
        splitLine2.ysf_frameWidth = 0.5;
        splitLine2.ysf_frameTop = offsetY + 14;
        [_content addSubview:splitLine2];
        
        UIButton *yes = [UIButton new];
        [yes setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
        [yes setTitle:@"有用" forState:UIControlStateNormal];
        if (attachment.evaluation == YSFEvaluationSelectionTypeYes) {
            yes.selected = YES;
            [yes setImage:[UIImage ysf_imageInKit:@"icon_yes_selected"] forState:UIControlStateNormal];
        }
        else {
            [yes setImage:[UIImage ysf_imageInKit:@"icon_yes_unselected"] forState:UIControlStateNormal];
        }
        yes.ysf_frameTop = offsetY + 2;
        yes.ysf_frameWidth = 64;
        yes.ysf_frameHeight = 44;
        yes.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        yes.ysf_frameLeft = ((self.ysf_frameWidth - 5) / 2 - yes.ysf_frameWidth) / 2;
        [yes addTarget:self action:@selector(onSelectYes:) forControlEvents:UIControlEventTouchUpInside];
        [_content addSubview:yes];
        
        UIButton *no = [UIButton new];
        [no setTitleColor:YSFRGB(0x666666) forState:UIControlStateNormal];
        [no setTitle:@"没用" forState:UIControlStateNormal];
        if (attachment.evaluation == YSFEvaluationSelectionTypeNo) {
            no.selected = YES;
            [no setImage:[UIImage ysf_imageInKit:@"icon_no_selected"] forState:UIControlStateNormal];
        }
        else {
            [no setImage:[UIImage ysf_imageInKit:@"icon_no_unselected"] forState:UIControlStateNormal];
        }
        no.ysf_frameTop = offsetY + 2;
        no.ysf_frameWidth = 64;
        no.ysf_frameHeight = 44;
        no.titleEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 0);
        no.ysf_frameLeft = (self.ysf_frameWidth - 5) / 2 + ((self.ysf_frameWidth - 5) / 2 - yes.ysf_frameWidth) / 2;
        [no addTarget:self action:@selector(onSelectNo:) forControlEvents:UIControlEventTouchUpInside];
        [_content addSubview:no];
        offsetY += yes.ysf_frameHeight;
        
        if (attachment.evaluationReason) {
            UIView *reasonView = [UIView new];
            self.reasonView = reasonView;
            reasonView.backgroundColor = YSFRGB(0xF9F9F9);
            reasonView.layer.cornerRadius = 2;
            reasonView.layer.borderWidth = 0.5;
            reasonView.layer.borderColor = YSFRGB(0xefefef).CGColor;
            reasonView.userInteractionEnabled = YES;
            reasonView.ysf_frameTop = offsetY;
            reasonView.ysf_frameLeft = 10+3;
            reasonView.ysf_frameWidth = self.ysf_frameWidth - 10*2;
            UILabel *reasonLabel = [UILabel new];
            reasonLabel.backgroundColor = YSFRGB(0xF9F9F9);
            reasonLabel.numberOfLines = 3;
            reasonLabel.textColor = YSFRGB(0x666666);
            reasonLabel.font = [UIFont systemFontOfSize:12];
            reasonLabel.ysf_frameTop = 0;
            reasonLabel.ysf_frameLeft = 5;
            reasonLabel.ysf_frameWidth = reasonView.ysf_frameWidth - 10;
            if (![attachment.evaluationContent isEqualToString:@""]) {
                reasonLabel.text = attachment.evaluationContent;
            } else {
                reasonLabel.text = attachment.evaluationGuide;
            }
            CGFloat height = [reasonLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(reasonLabel.bounds), 60) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.height;
            reasonView.ysf_frameHeight = height > 25 ? height : 25;
            reasonLabel.ysf_frameHeight = height > 25 ? height : 25;
            [reasonView addSubview:reasonLabel];
            [_content addSubview:reasonView];
            if (attachment.evaluation == YSFEvaluationSelectionTypeNo) {
                reasonView.hidden = NO;
            } else {
                reasonView.hidden = YES;
                attachment.evaluationContent = @"";
            }
            UITapGestureRecognizer *reasonTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapReasonLabel:)];
            [reasonView addGestureRecognizer:reasonTap];
            offsetY += reasonView.ysf_frameHeight;
        }
    }
    
    if (![YSF_NIMSDK sharedSDK].sdkOrKf && (attachment.evaluation == YSFEvaluationSelectionTypeYes || attachment.evaluation == YSFEvaluationSelectionTypeNo)) {
        UIImageView *evaluationResult = [UIImageView new];
        evaluationResult.backgroundColor = [UIColor whiteColor];
        evaluationResult.ysf_frameWidth = 28;
        evaluationResult.ysf_frameHeight = 28;
        evaluationResult.ysf_frameTop = -(evaluationResult.ysf_frameHeight) / 2;
        evaluationResult.ysf_frameLeft = -evaluationResult.ysf_frameWidth / 2;
        evaluationResult.clipsToBounds=YES;
        evaluationResult.layer.cornerRadius = evaluationResult.frame.size.width/2;
        evaluationResult.layer.borderColor = YSFRGB(0xd3d3d3).CGColor;
        evaluationResult.layer.borderWidth = 0.5;
        if (attachment.evaluation == YSFEvaluationSelectionTypeYes) {
            evaluationResult.image = [UIImage ysf_imageInKit:@"icon_yes_selected"];
        }
        else {
            evaluationResult.image = [UIImage ysf_imageInKit:@"icon_no_selected"];
        }
        evaluationResult.contentMode = UIViewContentModeCenter;

        [_content addSubview:evaluationResult];
        
        if (![attachment.evaluationContent isEqualToString:@""] && (attachment.evaluation == YSFEvaluationSelectionTypeNo)) {
            UIView *splitLine = [UIView new];
            splitLine.backgroundColor = YSFRGB(0xdbdbdb);
            splitLine.ysf_frameHeight = 0.5;
            splitLine.ysf_frameLeft = 0;
            splitLine.ysf_frameWidth = self.ysf_frameWidth - 5;
            splitLine.ysf_frameTop = offsetY;
            [_content addSubview:splitLine];
            offsetY += 0.5;
            offsetY += 10;  //空白间隙
            UILabel *noReasonLabel = [UILabel new];
            noReasonLabel.ysf_frameTop = offsetY;
            noReasonLabel.ysf_frameLeft = 10;
            noReasonLabel.ysf_frameWidth = self.ysf_frameWidth - 25;
            noReasonLabel.textColor = YSFRGBA2(0xffa3afb7);
            noReasonLabel.text = [NSString stringWithFormat:@"差评原因：%@", attachment.evaluationContent];
            noReasonLabel.textAlignment = NSTextAlignmentLeft;
            noReasonLabel.font = [UIFont systemFontOfSize:12];
            noReasonLabel.numberOfLines = 0;
            CGFloat height = [noReasonLabel.text boundingRectWithSize:CGSizeMake(CGRectGetWidth(noReasonLabel.bounds), MAXFLOAT) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:12]} context:nil].size.height;
            noReasonLabel.ysf_frameHeight = height;
            [_content addSubview:noReasonLabel];
            offsetY += height;
            offsetY += 10;  //空白间隙
        }
        
    }
}


#pragma mark - NIMAttributedLabelDelegate
- (void)ysfAttributedLabel:(YSFAttributedLabel *)label
             clickedOnLink:(id)strQuestion
{
    if ([strQuestion isKindOfClass:[QuestionLink class]]) {
        QuestionLink *questionLink = strQuestion;
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapMachineQuestion;
        event.message = self.model.message;
        event.data = questionLink.questionDict;
        [self.delegate onCatchEvent:event];
    }
    else {
        YSFKitEvent *event = [[YSFKitEvent alloc] init];
        event.eventName = YSFKitEventNameTapLabelLink;
        event.message = self.model.message;
        event.data = strQuestion;
        [self.delegate onCatchEvent:event];
    }

}

- (YSFAttributedLabel *)newAttrubutedLabel
{
    YSFAttributedLabel *answerLabel = [[YSFAttributedLabel alloc] initWithFrame:CGRectZero];
    answerLabel.delegate = self;
    answerLabel.numberOfLines = 0;
    answerLabel.underLineForLink = NO;
    answerLabel.autoDetectNumber = NO;
    answerLabel.lineBreakMode = NSLineBreakByWordWrapping;
    answerLabel.font = [UIFont systemFontOfSize:16.f];
    answerLabel.highlightColor = YSFRGBA2(0x1a000000);
    answerLabel.backgroundColor = [UIColor clearColor];
    QYCustomUIConfig *uiConfig = [QYCustomUIConfig sharedInstance];
    if (self.model.message.isOutgoingMsg) {
        answerLabel.textColor = uiConfig.customMessageTextColor;
        answerLabel.linkColor = uiConfig.customMessageHyperLinkColor;
    }
    else {
        answerLabel.textColor = uiConfig.serviceMessageTextColor;
        answerLabel.linkColor = uiConfig.serviceMessageHyperLinkColor;
    }
    CGFloat fontSize = self.model.message.isOutgoingMsg ? uiConfig.customMessageTextFontSize : uiConfig.serviceMessageTextFontSize;
    answerLabel.font = [UIFont systemFontOfSize:fontSize];
    return answerLabel;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _content.ysf_frameWidth = self.ysf_frameWidth;
    _content.ysf_frameHeight = self.ysf_frameHeight;
}

- (void)onSelectYes:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapEvaluationSelection;
    event.message = self.model.message;
    event.data = @(YES);
    [self.delegate onCatchEvent:event];
}

- (void)onSelectNo:(UIButton *)sender
{
    if (sender.selected) {
        return;
    }
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapEvaluationSelection;
    event.message = self.model.message;
    event.data = @(NO);
    [self.delegate onCatchEvent:event];
}

- (void)onTapReasonLabel:(UITapGestureRecognizer *)sender {
    YSFKitEvent *event = [[YSFKitEvent alloc] init];
    event.eventName = YSFKitEventNameTapEvaluationReason;
    event.message = self.model.message;
    [self.delegate onCatchEvent:event];
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



@end
