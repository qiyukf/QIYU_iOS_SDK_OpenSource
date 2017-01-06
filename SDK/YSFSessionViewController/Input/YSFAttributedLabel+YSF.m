//
//  NIMAttributedLabel+YSFKit
//  NIM
//
//  Created by chris.
//  Copyright (c) 2015 Netease. All rights reserved.
//

#import "YSFAttributedLabel+YSF.h"
#import "YSFInputEmoticonParser.h"
#import "YSFInputEmoticonManager.h"

@implementation YSFAttributedLabel (YSF)
- (void)ysf_setText:(NSString *)text
{
    [self setText:@""];
    NSArray *tokens = [[YSFInputEmoticonParser currentParser] tokens:text];
    for (YSFInputTextToken *token in tokens)
    {
        if (token.type == YSFInputTokenTypeEmoticon)
        {
            YSFInputEmoticon *emoticon = [[YSFInputEmoticonManager sharedManager] emoticonByTag:token.text];
            UIImage *image = [UIImage imageNamed:emoticon.filename];
            if (image)
            {
                [self appendImage:image
                          maxSize:CGSizeMake(18, 18)];
            }
        }
        else
        {
            NSString *text = token.text;
            [self appendText:text];
        }
    }
}
@end
