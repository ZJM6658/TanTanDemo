//
//  M_SlideCard.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "M_SlideCard.h"

@implementation M_SlideCard
- (instancetype)initWithImage:(NSString *)imageName
                      andName:(NSString *)userName
             andConstellation:(NSString *)constellation
                       andJob:(NSString *)job
                  andDistance:(NSString *)distance
                       andAge:(NSString *)age{
    if (self = [super init]) {
        _imageName = imageName;
        _userName = userName;
        _constellationName = constellation;
        _jobName = job;
        _distance = distance;
        _age = age;
    }
    return self;
}
@end
