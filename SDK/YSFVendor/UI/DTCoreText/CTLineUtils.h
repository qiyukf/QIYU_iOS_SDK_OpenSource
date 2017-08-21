//
//  CTLineUtils.h
//  YSFCoreText
//
//  Created by Oleksandr Deundiak on 7/15/15.
//  Copyright 2015. All rights reserved.
//

#import <CoreText/CoreText.h>
#import <Foundation/Foundation.h>

BOOL ysf_areLinesEqual(CTLineRef line1, CTLineRef line2);
CFIndex ysf_getTruncationIndex(CTLineRef line, CTLineRef trunc);
