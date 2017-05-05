//
//  NIMInputTextView.m
//  YSFKit
//
//  Created by chris.
//  Copyright (c) 2015年 NetEase. All rights reserved.
//

#import "YSFInputTextView.h"
#import "../../YSFSDK/ExportHeaders/QYCustomUIConfig.h"

@implementation YSFInputTextView

- (void)setPlaceHolder:(NSString *)placeHolder {
    if([placeHolder isEqualToString:_placeHolder]) {
        return;
    }
    _placeHolder = placeHolder;
    [self setNeedsDisplay];
}

- (void)setText:(NSString *)text {
    [super setText:text];
    [self layoutIfNeeded];
    [self setNeedsDisplay];
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self customUI];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didReceiveTextDidChangeNotification:)
                                                     name:UITextViewTextDidChangeNotification
                                                   object:self];
    }
    return self;
}

- (void)setFrame:(CGRect)frame{
    if (self.frame.size.width != frame.size.width) {
        [self setNeedsDisplay];
    }
    [super setFrame:frame];
}

- (void)setCustomUI
{
    [self customUI];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveTextDidChangeNotification:)
                                                 name:UITextViewTextDidChangeNotification
                                               object:self];
}

- (void)customUI
{
    self.scrollIndicatorInsets = UIEdgeInsetsMake(10.0f, 0.0f, 10.0f, 8.0f);
    self.contentInset = UIEdgeInsetsZero;
    self.scrollEnabled = YES;
    self.scrollsToTop = NO;
    self.userInteractionEnabled = YES;
    self.font = [UIFont systemFontOfSize:[[QYCustomUIConfig sharedInstance] inputTextFontSize]];
    self.textColor = [[QYCustomUIConfig sharedInstance] inputTextColor];
    self.backgroundColor = [UIColor clearColor];
    self.keyboardAppearance = UIKeyboardAppearanceDefault;
    self.keyboardType = UIKeyboardTypeDefault;
    self.returnKeyType = UIReturnKeySend;
    self.textAlignment = NSTextAlignmentLeft;
}

- (UIResponder *)nextResponder
{
    if (_overrideNextResponder != nil)
    {
        return _overrideNextResponder;
    }
    else
    {
        return [super nextResponder];
    }
}

-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (_overrideNextResponder != nil)
    {
        return NO;
    }
    else
    {
        if(action == @selector(paste:))
        {
            UIImage *image = [[UIPasteboard generalPasteboard] image];
            
            //        YSFServiceSession *session = [QYSDK sharedSDK].sessionManager.sessions;
            //        if (image && session && !session.humanOrMachine) {
            //            return NO;
            //        }
            //        else if(image && self.selectedRange.length == 0)
            //            return YES;
            
            if (image) {
                if(image && self.selectedRange.length == 0) {
                    return YES;
                }
                else {
                    return NO;
                }
            }
            else {
                NSString *string = [[UIPasteboard generalPasteboard] string];
                if (string && string.length > 0) {
                    return YES;
                }
                else {
                    return NO;
                }
            }
        }
        
        return [super canPerformAction:action withSender:sender];
    }

}

- (void)paste:(id)sender {
    UIImage *image = [[UIPasteboard generalPasteboard] image];
    if (image) {
        _pasteImageCallback(image);
        return;
    }
    
    [super paste:sender];
}

#pragma mark - Notifications

- (void)didReceiveTextDidChangeNotification:(NSNotification *)notification {
    [self setNeedsDisplay];
}

#pragma mark - Drawing
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    if([self.text length] == 0 && self.placeHolder) {
        CGRect placeHolderRect = CGRectMake(10.0f,
                                            8.0f,
                                            rect.size.width,
                                            rect.size.height);
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        paragraphStyle.alignment = self.textAlignment;
        
        [self.placeHolder drawInRect:placeHolderRect
                      withAttributes:@{ NSFontAttributeName : self.font,
                                        NSForegroundColorAttributeName : YSFRGBA2(0xffccd5d8),
                                        NSParagraphStyleAttributeName : paragraphStyle }];
    }
}


- (void)dealloc {
    _placeHolder = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:self];
}



@end
