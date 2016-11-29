//
//  M_CardFrame.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/17.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "M_CardFrame.h"

@implementation M_CardFrame

- (instancetype)initWithaFrame:(CGRect)frame {
    if (self= [super init]) {
        self.x = frame.origin.x;
        self.y = frame.origin.y;
        self.width = frame.size.width;
        self.height = frame.size.height;
    }
    return self;
}

@end
