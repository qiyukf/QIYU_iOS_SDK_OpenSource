//
//  YSFSDK+Server.m
//  YSFSDK
//
//  Created by amao on 9/21/15.
//  Copyright © 2015 Netease. All rights reserved.
//

#import "YSFSDK+Server.h"
#import "QYSDK_Private.h"



@implementation QYSDK (Server)
- (void)readEnvironmentConfig:(NSNumber *)isTest useHttps:(NSNumber *)pUseHttps
{
    self.serverSetting = [isTest integerValue];
    BOOL useHttps = [pUseHttps integerValue];
    [YSF_NIMSDK sharedSDK].useHttps = useHttps;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ysf_dev" ofType:@"plist"];
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
        
        //云信配置服设置
        YSF_NIMServerSetting *nimSetting = [[YSF_NIMServerSetting alloc] init];
        if (self.serverSetting == YSFUseServerSettingTest
            || self.serverSetting == YSFUseServerSettingDev) {
            nimSetting.lbsAddress                  = [dict objectForKey:@"nim_lbs"];
            nimSetting.linkAddress                 = [dict objectForKey:@"nim_link"];
            nimSetting.rsaPublicKeyModule          = [dict objectForKey:@"nim_module"];
        } else if (self.serverSetting == YSFUseServerSettingPre) {
            //预上线和线上服配置一样
//            nimSetting.lbsAddress                  = @"http://lbs.netease.im/lbs/conf.jsp";
//            nimSetting.linkAddress                 = @"link.netease.im:8080";
//            nimSetting.rsaPublicKeyModule          = @"0081c4bb8bf3ec6941275d4a74af3e4bcd38775caf912eab0fa490e4b33bf6ee0cc85e09f1482d10bfbf9fa7bfc06c2fbfd86565690c0f2c2014f17cd46a482bb4b8b8e56c9a93fec3273d3d71c5d42b91bd474a7b92c936d96ea6889d0d77b4113649f70086c419249d61290484d90c8a38cc503e13f9f37a9cb088436dd131bf";
        }
        
        if (!useHttps) {
            nimSetting.nosLbsAddress      = @"http://wanproxy.127.net/lbs";
            nimSetting.nosUploadAddress   = @"http://223.252.196.41";
        }
        
        [[YSF_NIMSDK sharedSDK] setSetting:nimSetting];
        
        //云商服
        if (self.serverSetting == YSFUseServerSettingTest) {
            [YSFServerSetting sharedInstance].apiAddress = [dict objectForKey:@"ysf_api"];
        } else if (self.serverSetting == YSFUseServerSettingPre) {
            [YSFServerSetting sharedInstance].apiAddress = @"http://qiyukf.netease.com/";
        } else if (self.serverSetting == YSFUseServerSettingDev) {
            [YSFServerSetting sharedInstance].apiAddress = @"http://qydev.netease.com/";
        }
    }
}

@end
