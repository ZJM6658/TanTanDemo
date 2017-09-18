//
//  V_TanTan.m
//  TanTanDemo
//
//  Created by zhujiamin on 2017/9/17.
//  Copyright © 2017年 zhujiamin. All rights reserved.
//

#import "V_TanTan.h"
#import "M_TanTan.h"

@interface V_TanTan ()

@property (nonatomic)         CGFloat       signAlpha;

@property (nonatomic, strong) UIImageView   *iv_user;

@property (nonatomic, strong) UILabel       *lb_name;
@property (nonatomic, strong) UILabel       *lb_age;
@property (nonatomic, strong) UILabel       *lb_constellation;
@property (nonatomic, strong) UILabel       *lb_jobOrDistance;

@end

@implementation V_TanTan

- (void)initUI {
    [super initUI];

    [self.contentView addSubview:self.iv_user];
    [self.contentView addSubview:self.iv_like];
    [self.contentView addSubview:self.iv_hate];
    
    [self.contentView addSubview:self.lb_name];
    [self.contentView addSubview:self.lb_age];
    [self.contentView addSubview:self.lb_constellation];
    [self.contentView addSubview:self.lb_jobOrDistance];
}


- (void)setDataItem:(M_TanTan *)dataItem {
    _dataItem = dataItem;
    self.lb_name.text = dataItem.userName;
    self.iv_user.image = [UIImage imageNamed:dataItem.imageName];
    self.lb_age.text = dataItem.age;
    self.lb_constellation.text = dataItem.constellationName;
    self.lb_jobOrDistance.text = dataItem.jobName.length ? dataItem.jobName : dataItem.distance;
}

- (void)setSignAlpha:(CGFloat)signAlpha {
    self.iv_like.alpha = signAlpha;
    self.iv_hate.alpha = - signAlpha;
}

#pragma mark - getter


- (UIImageView *)iv_user {
    if (_iv_user == nil) {
        _iv_user = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 70)];
    }
    return _iv_user;
}

- (UIImageView *)iv_like {
    if (_iv_like == nil) {
        _iv_like = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        _iv_like.image = [UIImage imageNamed:@"likeLine"];
        _iv_like.alpha = 0;
    }
    return _iv_like;
}

- (UIImageView *)iv_hate {
    if (_iv_hate == nil) {
        _iv_hate = [[UIImageView alloc]  initWithFrame:CGRectMake(self.frame.size.width - 20 - 60, 20, 60, 60)];
        _iv_hate.image = [UIImage imageNamed:@"hateLine"];
        _iv_hate.alpha = 0;
    }
    return _iv_hate;
}

- (UILabel *)lb_name {
    if (_lb_name == nil) {
        _lb_name = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.iv_user.frame), 100, 20)];
        _lb_name.font = [UIFont boldSystemFontOfSize:16];
        
    }
    return _lb_name;
}

- (UILabel *)lb_age {
    if (_lb_age == nil) {
        _lb_age = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_name.frame), 30, 20)];
        _lb_age.font = [UIFont systemFontOfSize:13];
        _lb_age.textColor = [UIColor redColor];
        
    }
    return _lb_age;
}

- (UILabel *)lb_constellation {
    if (_lb_constellation == nil) {
        _lb_constellation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lb_age.frame), CGRectGetMaxY(self.lb_name.frame), 50, 20)];
        _lb_constellation.font = [UIFont systemFontOfSize:11];
        
    }
    return _lb_constellation;
}

- (UILabel *)lb_jobOrDistance {
    if (_lb_jobOrDistance == nil) {
        _lb_jobOrDistance = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_age.frame), 30, 20)];
        _lb_jobOrDistance.font = [UIFont systemFontOfSize:11];
    }
    return _lb_jobOrDistance;
}
@end
