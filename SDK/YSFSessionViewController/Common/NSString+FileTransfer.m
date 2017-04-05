//
//  NSString+FileTransfer.m
//  YSFSessionViewController
//
//  Created by NetEase on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "NSString+FileTransfer.h"

@implementation NSString (FileTransfer)

+ (NSString *)getFileSizeTextWithFileLength:(long long)fileLength
{
    if (fileLength < 0) return nil;
    
    NSString *sizeText = nil;
    float fileSize = 0;
    int lastNum = 0;
    
    if ((fileLength / 1024.0 / 1024.0) > 1) {
        fileSize = fileLength / 1024.0 / 1024.0;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fMB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fMB", fileSize];
        }
    } else if ((fileLength / 1024.0) > 1) {
        fileSize = fileLength / 1024.0;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fKB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fKB", fileSize];
        }
    } else {
        fileSize = (float)fileLength;
        lastNum = (int)(fileSize * 10) % 10;
        if (lastNum > 0) {
            sizeText = [NSString stringWithFormat:@"%.1fB", fileSize];
        } else {
            sizeText = [NSString stringWithFormat:@"%.0fB", fileSize];
        }
    }
    
    return sizeText;
}

- (BOOL)isImageByFileName
{
    NSDictionary *dict = @{
                           @"jpg" : @(YES),
                           @"jpeg" : @(YES),
                           @"png" : @(YES),
                           @"gif" : @(YES),
                           @"bmp" : @(YES),
                           @"exif" : @(YES),
                           };
    
    NSString *fileExt = [[self pathExtension] lowercaseString];
    if ([dict objectForKey:fileExt]) {
        return YES;
    }
    
    return NO;
}



@end
