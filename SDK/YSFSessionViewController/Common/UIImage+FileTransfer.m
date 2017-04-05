//
//  UIImage+FileTransfer.m
//  YSFSessionViewController
//
//  Created by JackyYu on 17/3/28.
//  Copyright © 2017年 Netease. All rights reserved.
//

#import "UIImage+FileTransfer.h"

@implementation UIImage (FileTransfer)

+ (UIImage *)getFileIconWithDefaultIcon:(UIImage *)defaultIcon fileName:(NSString *)fileName
{
    if (!defaultIcon || !fileName) return nil;
    
    NSDictionary *iconImageDict = @{
                                    @"txt" : @"icon_file_type_txt",
                                    @"htm" : @"icon_file_type_txt",
                                    @"html" : @"icon_file_type_txt",
                                    @"xml" : @"icon_file_type_txt",
                                    @"jpg" : @"icon_file_type_image",
                                    @"jpeg" : @"icon_file_type_image",
                                    @"png" : @"icon_file_type_image",
                                    @"gif" : @"icon_file_type_image",
                                    @"bmp" : @"icon_file_type_image",
                                    @"exif" : @"icon_file_type_image",
                                    @"doc" : @"icon_file_type_word",
                                    @"docx" : @"icon_file_type_word",
                                    @"xls" : @"icon_file_type_excel",
                                    @"xlsx" : @"icon_file_type_excel",
                                    @"csv" : @"icon_file_type_excel",
                                    @"ppt" : @"icon_file_type_ppt",
                                    @"pptx" : @"icon_file_type_ppt",
                                    @"pdf" : @"icon_file_type_pdf",
                                    @"key" : @"icon_file_type_keynote",
                                    @"zip" : @"icon_file_type_zip",
                                    @"rar" : @"icon_file_type_zip",
                                    @"7z" : @"icon_file_type_zip",
                                    @"mp3" : @"icon_file_type_audio",
                                    @"wma" : @"icon_file_type_audio",
                                    @"ape" : @"icon_file_type_audio",
                                    @"flac" : @"icon_file_type_audio",
                                    @"wav" : @"icon_file_type_audio",
                                    @"aac" : @"icon_file_type_audio",
                                    @"ogg" : @"icon_file_type_audio",
                                    @"avi" : @"icon_file_type_video",
                                    @"mov" : @"icon_file_type_video",
                                    @"mkv" : @"icon_file_type_video",
                                    @"rmvb" : @"icon_file_type_video",
                                    @"wmv" : @"icon_file_type_video",
                                    @"3gp" : @"icon_file_type_video",
                                    @"flv" : @"icon_file_type_video",
                                    @"mp4" : @"icon_file_type_video",
                                    @"mpg" : @"icon_file_type_video",
                                    };
    
    UIImage *iconImage = defaultIcon;
    NSString *fileExt = [[fileName pathExtension] lowercaseString];
    if ([iconImageDict objectForKey:fileExt]) {
        iconImage = [UIImage ysf_imageInKit:[iconImageDict objectForKey:fileExt]];
    }
    
    return iconImage;
}


@end
