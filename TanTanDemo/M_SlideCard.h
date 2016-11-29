//
//  M_SlideCard.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface M_SlideCard : NSObject

@property (nonatomic, strong) NSString *imageName;

@property (nonatomic, strong) NSString *userName;

@property (nonatomic, strong) NSString *constellationName;

@property (nonatomic, strong) NSString *jobName;

@property (nonatomic, strong) NSString *distance;

@property (nonatomic, strong) NSString *age;

- (instancetype)initWithImage:(NSString *)imageName andName:(NSString *)userName andConstellation:(NSString *)constellation andJob:(NSString *)job andDistance:(NSString *)distance andAge:(NSString *)age;

@end
