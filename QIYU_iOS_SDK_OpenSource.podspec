Pod::Spec.new do |s|

    s.name     = 'QIYU_iOS_SDK_OpenSource'
    s.version  = '3.12.0'
    s.license  = { :"type" => "Copyright",
                 :"text" => " Copyright 2016 Netease \n"}  
    s.summary  = '网易七鱼客服访客端 iOS SDK'
    s.homepage = 'http://www.qiyukf.com'
    s.author   = { 'qiyukf' => 'yunshangfu@126.com' }
    s.source   = { :git => 'https://github.com/qiyukf/QIYU_iOS_SDK_OpenSource.git', :tag => "3.12.0" }
    s.platform = :ios
    s.ios.deployment_target = '7.0'
    s.public_header_files = '**/ExportHeaders/**/*.h'
    s.source_files = "**/ExportHeaders/**/*.h"
    s.vendored_libraries = '**/libNIMLib.a', '**/libYSFVendor.a', '**/libaacplus.a', '**/libcrypto.a', '**/libevent.a'
    s.resource  = "**/QYResource.bundle"
    s.framework = 'UIKit','CoreText','MobileCoreServices','SystemConfiguration','AVFoundation','CoreTelephony','CoreMedia','AudioToolbox'
    s.libraries = 'z','stdc++.6.0.9','sqlite3.0','xml2'
    s.requires_arc = true
    s.prefix_header_contents = '#import <UIKit/UIKit.h>
                                #import "YSFMacro.h"
                                #import "UIView+YSFToast.h"
                                #import "UIImage+GetImage.h"
                                #import "UIView+Animation.h"
                                #import "UIView+YSFWebCacheOperation.h"
                                #import "UIAlertView+YSF.h"
                                #import "UIView+YSF.h"
                                #import "UIImage+YSF.h"
                                #import "NSString+YSF.h"
                                #import "NSDictionary+YSF.h"
                                #import "NIMSDK.h"
    s.xcconfig = {
        "GCC_PREPROCESSOR_DEFINITIONS" => 'NDEBUG=1'
    }
    s.subspec 'NIMLib' do |ss|
        ss.public_header_files = '**/NIMLib/**/*.h'
        ss.source_files = "**/NIMLib/**/*.{h}"
    end

    s.subspec 'YSFVendor' do |ss|
        ss.public_header_files = '**/YSFVendor/**/*.h'
        ss.source_files = "**/YSFVendor/**/*.{h}"
    end

    s.subspec 'YSFSessionViewController' do |ss|
        ss.public_header_files = '**/YSFSessionViewController/**/*.h'
        ss.source_files = "**/YSFSessionViewController/**/*.{h,m}"
    end

    s.subspec 'YSFSDK' do |ss|
    ss.public_header_files = '**/YSFSDK/**/*.h'
    ss.source_files = "**/YSFSDK/**/*.{h,m}"
    end
end
