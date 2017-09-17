//
//  V_TanTan.h
//  TanTanDemo
//
//  Created by zhujiamin on 2017/9/17.
//  Copyright © 2017年 zhujiamin. All rights reserved.
//

#import "V_SlideCardCell.h"

@class M_TanTan;

@interface V_TanTan : V_SlideCardCell

@property (nonatomic, strong) M_TanTan   *dataItem;

@property (nonatomic, strong) UIImageView   *iv_like;
@property (nonatomic, strong) UIImageView   *iv_hate;

@end
