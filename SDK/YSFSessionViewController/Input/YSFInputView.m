//
//  NIMInputView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputView.h"
#import <AVFoundation/AVFoundation.h>
#import "YSFInputMoreContainerView.h"
#import "YSFInputEmoticonContainerView.h"
#import "YSFInputAudioRecordIndicatorView.h"
#import "YSFInputEmoticonDefine.h"
#import "YSFInputEmoticonManager.h"
#import "YSFInputToolBar.h"
#import "YSFInputTextView.h"
#import "YSFKeyboardManager.h"
#import "QYCustomUIConfig.h"


@interface YSFInputView()<UITextViewDelegate,YSFInputEmoticonProtocol, YSFKeyboardObserver>
{
    UIView  *_emoticonView;
    CGFloat   _inputTextViewOlderHeight;
}

@property (nonatomic, strong) YSFInputAudioRecordIndicatorView *audioRecordIndicator;
@property (nonatomic, assign) NIMAudioRecordPhase recordPhase;
@property (nonatomic, weak) id<YSFSessionConfig> inputConfig;
@property (nonatomic, weak) id<YSFInputDelegate> inputDelegate;
@property (nonatomic, weak) id<YSFInputActionDelegate> actionDelegate;
@property (nonatomic, assign) NIMInputType inputType;
@property (nonatomic, assign) CGFloat bottomHeight;

@end


@implementation YSFInputView

- (instancetype)initWithFrame:(CGRect)frame inputType:(NIMInputType)inputType
{
    self = [super initWithFrame:frame];
    if (self) {
        _inputType = inputType;
        _recording = NO;
        _recordPhase = AudioRecordPhaseEnd;
        _inputTextViewOlderHeight = YSFTopInputViewHeight;

        if (_inputType == InputTypeAudio) {
            [self changeInputTypeToAudio];
        }
        else
        {
            [self changeInputTypeToText];
        }
        
        [self addKeyboardObserver];
        
        _actionBar = [[YSFActionBar alloc] init];
        _actionBar.hidden = YES;
        _actionBar.ysf_frameHeight = YSFActionBarHeight;
        [self addSubview:_actionBar];

        _toolBar = [[YSFInputToolBar alloc] initWithFrame:CGRectZero];
        [_toolBar.emoticonBtn addTarget:self action:@selector(onTouchEmoticonBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.voiceBtn addTarget:self action:@selector(onTouchVoiceBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDown:) forControlEvents:UIControlEventTouchDown];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDragInside:) forControlEvents:UIControlEventTouchDragInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnDragOutside:) forControlEvents:UIControlEventTouchDragOutside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnUpInside:) forControlEvents:UIControlEventTouchUpInside];
        [_toolBar.recordButton addTarget:self action:@selector(onTouchRecordBtnUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
        _toolBar.ysf_frameSize = [_toolBar sizeThatFits:CGSizeMake(self.ysf_frameWidth, CGFLOAT_MAX)];
        _toolBar.recordLabel.text = @"按住 说话";
        [self addSubview:_toolBar];
        _toolBar.inputTextView.delegate = self;
        [_toolBar.inputTextView setCustomUI];
        _inputBottomViewHeight = 0;
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        
        __weak typeof(self) weakSelf = self;
        [_toolBar.imageButton addTarget:self action:@selector(onTouchImageBtn:) forControlEvents:UIControlEventTouchUpInside];
        _toolBar.inputTextView.pasteImageCallback = ^(UIImage *image) {
            [weakSelf.actionDelegate onPasteImage:image];
        };
    }
    return self;
}

- (void)setInputConfig:(id<YSFSessionConfig>)config
{
    _inputConfig = config;
    
    //设置最大输入字数
    NSInteger textInputLength = 4500;
    if ([_inputConfig respondsToSelector:@selector(maxInputLength)]) {
        textInputLength = [_inputConfig maxInputLength];
    }
    self.maxTextLength = textInputLength;
    
    //最大输入行数
    NSInteger maxInputLines = 4;
    if ([_inputConfig respondsToSelector:@selector(maxInputLines)]) {
        maxInputLines = [_inputConfig maxInputLines];
    }
    self.maxInputLines = maxInputLines;
    
    //设置placeholder
    if ([_inputConfig respondsToSelector:@selector(inputViewPlaceholder)]) {
        NSString *placeholder = [_inputConfig inputViewPlaceholder];
        _toolBar.inputTextView.placeHolder = placeholder;
    }
}

- (void)setInputDelegate:(id<YSFInputDelegate>)delegate
{
    _inputDelegate = delegate;

}

- (void)setActionInfoArray:(NSArray<YSFActionInfo *> *)actionInfoArray
{
    if (_actionBar.actionInfoArray.count == 0 && actionInfoArray.count > 0) {
        self.ysf_frameHeight += YSFActionBarHeight;
    }
    else if (_actionBar.actionInfoArray.count > 0 && actionInfoArray.count == 0) {
        self.ysf_frameHeight -= YSFActionBarHeight;
    }
    _actionBar.actionInfoArray = actionInfoArray;
    _actionBar.hidden = actionInfoArray.count == 0;
    
    [self willShowBottomHeight:_bottomHeight];
}

- (void)setActionCallback:(SelectActionCallback)callback
{
    _actionBar.selectActionCallback = callback;
}

- (void)setInputActionDelegate:(id<YSFInputActionDelegate>)actionDelegate
{
    _actionDelegate                 = actionDelegate;
}

- (NSString *)inputText
{
    return [_toolBar.inputTextView text];
}

- (void)setInputText:(NSString *)inputText
{
    [_toolBar layoutIfNeeded];
    [_toolBar.inputTextView setText:inputText];
    [self inputTextViewToHeight:[self getTextViewContentH:_toolBar.inputTextView]];;
}


- (YSFInputAudioRecordIndicatorView *)audioRecordIndicator {
    if(!_audioRecordIndicator) {
        _audioRecordIndicator = [[YSFInputAudioRecordIndicatorView alloc] init];
    }
    return _audioRecordIndicator;
}

- (void)setRecordPhase:(NIMAudioRecordPhase)recordPhase
{
    if (recordPhase == AudioRecordPhaseStart || recordPhase == AudioRecordPhaseRecording)  {
        _toolBar.recordLabel.text = @"松开 结束";
    }
    else if (recordPhase == AudioRecordPhaseCancelling) {
        _toolBar.recordLabel.text = @"按住 说话";
        _toolBar.recordButton.highlighted = YES;
    }
    else {
        _toolBar.recordLabel.text = @"按住 说话";
        _toolBar.recordButton.highlighted = NO;
    }
    NIMAudioRecordPhase prevPhase = _recordPhase;
    _recordPhase = recordPhase;
    self.audioRecordIndicator.phase = _recordPhase;
    if(prevPhase == AudioRecordPhaseEnd) {
        if(AudioRecordPhaseStart == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onStartRecording)]) {
                [_actionDelegate onStartRecording];
            }
        }
    } else if (prevPhase == AudioRecordPhaseStart || prevPhase == AudioRecordPhaseRecording) {
        if (AudioRecordPhaseEnd == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onStopRecording)]) {
                [_actionDelegate onStopRecording];
            }
        }
    } else if (prevPhase == AudioRecordPhaseCancelling) {
        if(AudioRecordPhaseEnd == _recordPhase) {
            if ([_actionDelegate respondsToSelector:@selector(onCancelRecording)]) {
                [_actionDelegate onCancelRecording];
            }
        }
    }
}

- (void)dealloc
{
    [self removeKeyboardObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _emoticonContainer.delegate = nil;
    _toolBar.inputTextView.delegate = nil;
}

- (void)addKeyboardObserver
{
    [[YSFKeyboardManager defaultManager] addObserver:self];
}

- (void)removeKeyboardObserver
{
    [[YSFKeyboardManager defaultManager] removeObserver:self];
}

- (void)setRecording:(BOOL)recording {
    if(recording) {
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.audioRecordIndicator];
        self.recordPhase = AudioRecordPhaseRecording;
    } else {
        [self.audioRecordIndicator removeFromSuperview];
        self.audioRecordIndicator = nil;
    }
    _recording = recording;
}

#pragma mark - 外部接口
- (void)setInputTextPlaceHolder:(NSString*)placeHolder
{
    [_toolBar.inputTextView setPlaceHolder:placeHolder];
}

- (void)updateAudioRecordTime:(NSTimeInterval)time {
}

- (void)updateVoicePower:(float)power {
    
}


#pragma mark - private methods

- (void)updateAllButtonImages
{
    if (_inputType == InputTypeText)
    {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    }
    else if(_inputType == InputTypeAudio)
    {
        [self updateVoiceBtnImages:NO];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:NO];
        [_toolBar.recordLabel setHidden:NO];
        [_toolBar.inputTextView setHidden:YES];
        [_toolBar.inputTextBkgImage setHidden:YES];
    }
    else if (_inputType == InputTypeEmot)
    {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:NO];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    }
    else
    {
        [self updateVoiceBtnImages:YES];
        [self updateEmotAndTextBtnImages:YES];
        [_toolBar.recordButton setHidden:YES];
        [_toolBar.recordLabel setHidden:YES];
        [_toolBar.inputTextView setHidden:NO];
        [_toolBar.inputTextBkgImage setHidden:NO];
    }
}

- (CGFloat)getTextViewContentH:(UITextView *)textView
{
    return YSFIOS8 ? textView.contentSize.height : ceilf([textView sizeThatFits:textView.frame.size].height);
}

- (void)updateVoiceBtnImages:(BOOL)selected
{
    [_toolBar.voiceBtn setImage:selected?[UIImage ysf_imageInKit:@"icon_toolview_voice_normal"]:[UIImage ysf_imageInKit:@"icon_toolview_keyboard_normal"] forState:UIControlStateNormal];
    [_toolBar.voiceBtn setImage:selected?[UIImage ysf_imageInKit:@"icon_toolview_voice_pressed"]:[UIImage ysf_imageInKit:@"icon_toolview_keyboard_pressed"] forState:UIControlStateHighlighted];
}

- (void)updateEmotAndTextBtnImages:(BOOL)selected
{
    [_toolBar.emoticonBtn setImage:selected?[UIImage ysf_imageInKit:@"icon_toolview_emotion_normal"]:[UIImage ysf_imageInKit:@"icon_toolview_keyboard_normal"] forState:UIControlStateNormal];
    [_toolBar.emoticonBtn setImage:selected?[UIImage ysf_imageInKit:@"icon_toolview_emotion_pressed"]:[UIImage ysf_imageInKit:@"icon_toolview_keyboard_pressed"] forState:UIControlStateHighlighted];
}

#pragma mark - UIKeyboardNotification
- (void)keyboardChangedWithTransition:(YSFKeyboardTransition)transition {
    [UIView animateWithDuration:transition.animationDuration delay:0 options:transition.animationOption animations:^{
        [self willShowKeyboardFromFrame:transition.toFrame];

    } completion:^(BOOL finished) {
        
    }];
}

//- (void)keyboardWillChangeFrame:(NSNotification *)notification
//{
//    if (self.ysf_viewController.presentedViewController) {
//        return;
//    }
//    NSDictionary *userInfo = notification.userInfo;
//    CGRect endFrame   = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect beginFrame = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
//    UIViewAnimationCurve curve = (UIViewAnimationCurve)[userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
//    
//    //兼容iPad设备
//    if (iPadDevice) {
//        endFrame = [self resetEndFrameForIPad:endFrame];
//    }
//    
//    void(^animations)() = ^{
//        [self willShowKeyboardFromFrame:beginFrame toFrame:endFrame];
//    };
//    
//    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:nil];
//}

- (void)willShowKeyboardFromFrame:(CGRect)toFrame
{
//    toFrame.origin.y -= _inputBottomViewHeight;

    if (toFrame.origin.y == [[UIScreen mainScreen] bounds].size.height) {
        if (_inputType != InputTypeEmot) {
            [self willShowBottomHeight:0];
        }
    }else{
        CGFloat bottomHeight = toFrame.size.height;
        bottomHeight -= [[QYCustomUIConfig sharedInstance] bottomMargin];
        if (@available(iOS 11, *)) {
            bottomHeight -= self.ysf_viewController.view.safeAreaInsets.bottom;
        }
        [self willShowBottomHeight:bottomHeight];
    }
}

- (void)willShowBottomHeight:(CGFloat)bottomHeight
{
    self.bottomHeight = bottomHeight;
    CGRect fromFrame = self.frame;
    CGFloat toHeight = self.toolBar.frame.size.height + bottomHeight;
    if (!_actionBar.hidden) {
        toHeight += _actionBar.ysf_frameHeight;
    }
    CGRect toFrame = CGRectMake(fromFrame.origin.x, fromFrame.origin.y + (fromFrame.size.height - toHeight), fromFrame.size.width, toHeight);
    
    if(bottomHeight == 0 && self.frame.size.height == self.toolBar.frame.size.height)
    {
        return;
    }
    self.frame = toFrame;
    
    if (bottomHeight == 0) {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(hideInputView)]) {
            [self.inputDelegate hideInputView];
        }
    } else
    {
        if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(showInputView)]) {
            [self.inputDelegate showInputView];
        }
    }
    if (self.inputDelegate && [self.inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
        [self.inputDelegate inputViewSizeToHeight:toHeight showInputView:!(bottomHeight==0)];
    }
}

- (void)inputTextViewToHeight:(CGFloat)toHeight
{
    toHeight = MAX(YSFTopInputViewHeight, toHeight);
    toHeight = MIN(YSFTopInputViewMaxHeight, toHeight);

    [self inputTextViewChangeHeight:toHeight];
}

- (void)inputTextViewChangeHeight:(CGFloat)toHeight
{
    if (toHeight != _inputTextViewOlderHeight)
    {
        CGFloat changeHeight = toHeight - _inputTextViewOlderHeight;
        CGRect rect = self.frame;
        rect.size.height += changeHeight;
        rect.origin.y -= changeHeight;
        self.frame = rect;
        
        rect = self.toolBar.frame;
        rect.size.height += changeHeight;
        [self updateInputTopViewFrame:rect];
        
        _inputTextViewOlderHeight = toHeight;
        
        if (_inputDelegate && [_inputDelegate respondsToSelector:@selector(inputViewSizeToHeight:showInputView:)]) {
            [_inputDelegate inputViewSizeToHeight:self.frame.size.height showInputView:YES];
        }
    }
}

- (void)updateInputTopViewFrame:(CGRect)rect
{
    self.toolBar.frame             = rect;
    [self.toolBar layoutIfNeeded];
    self.emoticonContainer.ysf_frameTop = self.toolBar.ysf_frameBottom;
}

//键盘弹出后视图兼容iPad
- (CGRect)resetEndFrameForIPad:(CGRect)endFrame{
    
    if (_containerController && endFrame.size.height > 0) {
        
        BOOL flag = NO;
        
        if (_containerController.presentingViewController && _containerController.modalPresentationStyle == UIModalPresentationFormSheet) {
            flag = YES;
        }
        else{
            if (_containerController.navigationController && _containerController.navigationController.presentingViewController && _containerController.navigationController.modalPresentationStyle == UIModalPresentationFormSheet) {
                flag = YES;
            }
        }
        
        if (flag) {
            CGFloat sheetHeight = _containerController.view.frame.size.height;
            CGFloat fullHeight = [UIScreen mainScreen].bounds.size.height;
            CGFloat height = (fullHeight - sheetHeight)*0.5;
            
            if (height <= endFrame.size.height) {
                endFrame = CGRectMake(endFrame.origin.x, endFrame.origin.y, endFrame.size.width, endFrame.size.height - height);
            }
        }
    }

    return endFrame;
}


#pragma mark - button actions
- (void)onTouchVoiceBtn:(id)sender {
    // image change
    if (_inputType != InputTypeAudio) {
        [self changeInputTypeToAudio];
    }
    else
    {
        [self changeInputTypeToText];
        [self.toolBar.inputTextView becomeFirstResponder];
    }
}

- (void)changeInputTypeToText
{
    self.inputType = InputTypeText;

    [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    [self updateAllButtonImages];
}

- (void)changeInputTypeToAudio
{
    if ([[AVAudioSession sharedInstance] respondsToSelector:@selector(requestRecordPermission:)]) {
        [[AVAudioSession sharedInstance] performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.inputType = InputTypeAudio;
                    if ([self.toolBar.inputTextView isFirstResponder]) {
                        _inputBottomViewHeight = 0;
                        [self.toolBar.inputTextView resignFirstResponder];
                    }
                    else if (_inputBottomViewHeight > 0)
                    {
                        _inputBottomViewHeight = 0;
                        [self willShowBottomHeight:_inputBottomViewHeight];
                    }
                    [self inputTextViewChangeHeight:YSFTopInputViewHeight];;
                    [self updateAllButtonImages];
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"没有麦克风权限"
                                                message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许访问你的麦克风。"
                                               delegate:nil
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
}

- (IBAction)onTouchRecordBtnDown:(id)sender {
    // start Recording
    self.recordPhase = AudioRecordPhaseStart;
}
- (IBAction)onTouchRecordBtnUpInside:(id)sender {
    // finish Recording
    self.recordPhase = AudioRecordPhaseEnd;
}
- (IBAction)onTouchRecordBtnUpOutside:(id)sender {
    //TODO cancel Recording
    self.recordPhase = AudioRecordPhaseEnd;
}

- (IBAction)onTouchRecordBtnDragInside:(id)sender {
    //TODO @"手指上滑，取消发送"
    self.recordPhase = AudioRecordPhaseRecording;
}
- (IBAction)onTouchRecordBtnDragOutside:(id)sender {
    //TODO @"松开手指，取消发送"
    self.recordPhase = AudioRecordPhaseCancelling;
}


- (void)onTouchEmoticonBtn:(id)sender
{
    if (_inputType != InputTypeEmot) {
        if (!_emoticonContainer) {
            _emoticonContainer = [[YSFInputEmoticonContainerView alloc] initWithFrame:CGRectMake(0, _inputTextViewOlderHeight, self.ysf_frameWidth, YSFBottomInputViewHeight)];
            if (!_actionBar.hidden) {
                _emoticonContainer.ysf_frameTop += YSFActionBarHeight;
            }
            _emoticonContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            _emoticonContainer.delegate = self;
            _emoticonContainer.hidden = YES;
            [self addSubview:_emoticonContainer];
        }
        
        self.inputType = InputTypeEmot;
        _inputBottomViewHeight = YSFBottomInputViewHeight;
        [self bringSubviewToFront:_emoticonContainer];
        [_emoticonContainer setHidden:NO];
        [self endTextEditWithInputBottomViewHeight:_inputBottomViewHeight];
    }
    else
    {
        [_emoticonContainer setHidden:YES];
        self.inputType = InputTypeText;
        _inputBottomViewHeight = 0;
        [self.toolBar.inputTextView becomeFirstResponder];
    }
    [self inputTextViewToHeight:[self getTextViewContentH:self.toolBar.inputTextView]];;
    [self updateAllButtonImages];
}

- (void)endTextEditWithInputBottomViewHeight:(CGFloat)inputBottomViewHeight
{
    if ([self.toolBar.inputTextView isFirstResponder]) {
        [self.toolBar.inputTextView resignFirstResponder];
    }
    [UIView animateWithDuration:0.25 animations:^{
        [self willShowBottomHeight:inputBottomViewHeight];
    }];
}

- (void)inputBottomViewHeightToZero
{
    if (_inputType != InputTypeAudio) {
        [_emoticonContainer setHidden:YES];
        _inputBottomViewHeight = 0.0;
        _inputType = InputTypeText;
        [self endTextEditWithInputBottomViewHeight:0];
        [self updateAllButtonImages];
    }

//    BOOL endEditing = NO;
//    if ( ![self.toolBar.inputTextView isFirstResponder]) {
//        _inputBottomViewHeight = 0.0;
//        _inputType = InputTypeText;
//        [UIView animateWithDuration:0.25 animations:^{
//            [self willShowBottomHeight:_inputBottomViewHeight];
//        }];
//    }
//    else{
//        endEditing = [super endEditing:force];
//    }
//    return endEditing;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.inputType = InputTypeText;
    
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    [textView resignFirstResponder];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        NSString *sendText = textView.text;
        if ([sendText length])
        {
            if ([self.actionDelegate respondsToSelector:@selector(onSendText:)]) {
                BOOL sended = [self.actionDelegate onSendText:sendText];
                if (sended) {
                    textView.text = @"";
                    [textView layoutIfNeeded];
                    [self inputTextViewToHeight:[self getTextViewContentH:textView]];;
                }
            }
        }
        
        return NO;
    }
    if ([text isEqualToString:@""]) {
        if (range.length > 1) {     //ios cut and delete command use the same @"", has conflict.
            return YES;         //当有选择一部分的时候直接删除或剪切
        }
        //delete Emoji
        NSRange range = [self rangeForEmoticon];
        if (range.length != 1) {    //一般表情至少包括[*]有3个字符
            [self deleteTextRange:range];
            return NO;      //只有当找到表情的时候才手动删除返回NO,其他情况交给系统删除
        }
    }

    return YES;
}


- (void)textViewDidChange:(UITextView *)textView
{
    NSString *str = textView.text;
    if (str.length > self.maxTextLength) {
        textView.text = [str substringToIndex:self.maxTextLength];
    }
    
    if (self.actionDelegate && [self.actionDelegate respondsToSelector:@selector(onTextChanged:)])
    {
        [self.actionDelegate onTextChanged:self];
    }
    [self inputTextViewToHeight:[self getTextViewContentH:textView]];
}


#pragma mark - InputEmoticonProtocol
- (void)selectedEmoticon:(NSString*)emoticonID catalog:(NSString*)emotCatalogID description:(NSString *)description{
    if (!emotCatalogID) { //删除键
        NSRange range = [self rangeForEmoticon];
        [self deleteTextRange:range];
    }else{
        if ([emotCatalogID isEqualToString:YSFKit_EmojiCatalog]) {
            [self.toolBar.inputTextView insertText:description];
            [self.toolBar.inputTextView scrollRangeToVisible:
             NSMakeRange(self.toolBar.inputTextView.text.length, 1)];
        }
        else{
            //发送贴图消息
            if ([self.actionDelegate respondsToSelector:@selector(onSelectChartlet:catalog:)]) {
                [self.actionDelegate onSelectChartlet:emoticonID catalog:emotCatalogID];
            }
        }
        
        
    }
}

- (void)didPressSend:(id)sender{
    if ([self.actionDelegate respondsToSelector:@selector(onSendText:)]
        && [self.toolBar.inputTextView.text length] > 0)
    {
        if ([self.actionDelegate onSendText:self.toolBar.inputTextView.text]) {
            self.toolBar.inputTextView.text = @"";
            [self textViewDidChange:self.toolBar.inputTextView];
        }
    }
}

- (void)deleteTextRange: (NSRange)range
{
    NSString *text = [self.toolBar.inputTextView text];
    if (range.location + range.length <= [text length]
        && range.location != NSNotFound && range.length != 0)
    {
        NSString *newText = [text stringByReplacingCharactersInRange:range withString:@""];
        NSRange newSelectRange = NSMakeRange(range.location, 0);
        [self.toolBar.inputTextView setText:newText];
        [self textViewDidChange:self.toolBar.inputTextView];
        [self.toolBar.inputTextView setSelectedRange:newSelectRange];
    }
}

- (NSRange)rangeForEmoticon
{
    NSString *text = [self.toolBar.inputTextView text];
    NSRange range = [self.toolBar.inputTextView selectedRange];
    NSString *selectedText = range.length ? [text substringWithRange:range] : text;
    NSInteger endLocation =range.location + range.length;
    if (range.length) {
        return range;
    }
    if (endLocation <= 0)
    {
        return NSMakeRange(NSNotFound, 0);
    }
    NSInteger index = -1;
    if ([selectedText hasSuffix:@"]"]) {
        for (NSInteger i = endLocation; i >= endLocation - 4 && i-1 >= 0 ; i--)
        {
            NSRange subRange = NSMakeRange(i - 1, 1);
            NSString *subString = [text substringWithRange:subRange];
            if ([subString compare:@"["] == NSOrderedSame)
            {
                index = i - 1;
                break;
            }
        }
    }
    if (index == -1)
    {
        return NSMakeRange(endLocation - 1, 1);
    }
    else
    {
        NSRange emoticonRange = NSMakeRange(index, endLocation - index);
        NSString *name = [text substringWithRange:emoticonRange];
        YSFInputEmoticon *icon = [[YSFInputEmoticonManager sharedManager] emoticonByTag:name];
        return icon ? emoticonRange : NSMakeRange(endLocation - 1, 1);
    }
}

- (void)onTouchImageBtn:(id)sender
{
    if ([self.actionDelegate respondsToSelector:@selector(OnMediaPicturePressed)]) {
        [self.actionDelegate OnMediaPicturePressed];
        self.inputType = InputTypeText;
        _inputBottomViewHeight = 0;
        [self endTextEditWithInputBottomViewHeight:0];
    }
}

- (void)setHumanOrMachine:(BOOL)humanOrMachine
{
    _toolBar.humanOrMachine = humanOrMachine;
    if (!humanOrMachine) {
        [self changeInputTypeToText];
    }
}

- (void)layoutSubviews
{
    _actionBar.ysf_frameTop = 0;
    _actionBar.ysf_frameWidth = self.ysf_frameWidth;
    if (_actionBar.hidden == NO) {
        _toolBar.ysf_frameTop = _actionBar.ysf_frameHeight;
    }
    else {
        _toolBar.ysf_frameTop = 0;
    }
    _toolBar.ysf_frameWidth = self.ysf_frameWidth;
}

@end
