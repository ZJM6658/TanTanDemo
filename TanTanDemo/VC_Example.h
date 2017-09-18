//
//  VC_Example.h
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, ExampleType) {
    ExampleTypeEmpty = 0,
    ExampleTypeTanTan,
    ExampleTypeBoss,
};

@interface VC_Example : UIViewController

@property (nonatomic) ExampleType exampleType;

@end
