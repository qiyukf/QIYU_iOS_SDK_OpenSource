//
//  NIMAttributedLabel+YSFKit
//  NIM
//
//  Created by chris.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAttributedLabel+YSF.h"
#import "YSFInputEmoticonParser.h"
#import "YSFEmoticonDataManager.h"
#import "UIImageView+YSFWebCache.h"

@implementation YSFAttributedLabel (YSF)
- (void)ysf_setText:(NSString *)text {
    [self setText:@""];
    NSArray *tokens = [[YSFInputEmoticonParser currentParser] tokens:text];
    for (YSFInputTextToken *token in tokens) {
        BOOL appendImage = NO;
        if (token.type == YSFInputTokenTypeEmoticon) {
            YSFEmoticonItem *item = [[YSFEmoticonDataManager sharedManager] emoticonItemForTag:token.text];
            if (item && (item.type == YSFEmoticonTypeDefaultEmoji || item.type == YSFEmoticonTypeCustomEmoji)) {
                if (item.type == YSFEmoticonTypeDefaultEmoji) {
                    UIImage *image = [UIImage imageNamed:item.filePath];
                    if (image) {
                        [self appendImage:image maxSize:CGSizeMake(21, 21)];
                        appendImage = YES;
                    }
                } else {
                    if ([item.fileURL length]) {
                        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 21, 21)];
                        imageView.backgroundColor = [UIColor lightGrayColor];
                        imageView.contentMode = UIViewContentModeScaleAspectFill;
                        [imageView ysf_setImageWithURL:[NSURL URLWithString:item.fileURL]
                                             completed:^(UIImage * _Nullable image, NSError * _Nullable error, YSFImageCacheType cacheType, NSURL * _Nullable imageURL) {
                                                 if (!error && image) {
                                                     imageView.backgroundColor = [UIColor clearColor];
                                                 }
                                             }];
                        [self appendView:imageView];
                        appendImage = YES;
                    }
                }
            }
        }
        if (!appendImage) {
            [self appendText:token.text];
        }
    }
}

@end
