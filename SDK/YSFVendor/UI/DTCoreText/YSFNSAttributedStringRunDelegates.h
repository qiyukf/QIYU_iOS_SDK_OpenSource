//
//  NSAttributedStringRunDelegates.h
//  YSFCoreText
//
//  Created by Oliver on 14.01.11.
//  Copyright 2011 Drobnik.com. All rights reserved.
//

#if TARGET_OS_IPHONE
#import <CoreText/CoreText.h>
#elif TARGET_OS_MAC
#import <ApplicationServices/ApplicationServices.h>
#endif

void ysf_embeddedObjectDeallocCallback(void *context);
CGFloat ysf_embeddedObjectGetAscentCallback(void *context);
CGFloat ysf_embeddedObjectGetDescentCallback(void *context);
CGFloat ysf_embeddedObjectGetWidthCallback(void *context);
CTRunDelegateRef ysf_createEmbeddedObjectRunDelegate(id obj);
