//
//  NSString+FileTransfer.h
//  YSFSessionViewController
//
//  Created by NetEase on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (FileTransfer)

+ (NSString *)getFileSizeTextWithFileLength:(long long)fileLength;

- (BOOL)isImageByFileName;
- (NSAttributedString *)ysf_attributedString:(BOOL)isOutgoingMsg;

@end
