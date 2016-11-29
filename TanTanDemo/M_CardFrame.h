//
//  M_CardFrame.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/17.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M_CardFrame : NSObject
@property (nonatomic) CGFloat x;
@property (nonatomic) CGFloat y;

@property (nonatomic) CGFloat width;
@property (nonatomic) CGFloat height;

- (instancetype)initWithaFrame:(CGRect)frame;
@end
