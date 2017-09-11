//
//  V_SlideCardCell.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "V_SlideCardCell.h"
#import "V_SlideCard.h"

@interface V_SlideCardCell ()

@property (nonatomic, strong) UIImageView   *iv_user;
@property (nonatomic, strong) UIImageView   *iv_like;
@property (nonatomic, strong) UIImageView   *iv_hate;
@property (nonatomic, strong) UILabel       *lb_name;
@property (nonatomic, strong) UILabel       *lb_age;
@property (nonatomic, strong) UILabel       *lb_constellation;
@property (nonatomic, strong) UILabel       *lb_jobOrDistance;

@end

@implementation V_SlideCardCell

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, SCRW, SCRH)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        self.userInteractionEnabled = YES;
        self.layer.borderColor = RGBA(200, 200, 200, 1).CGColor;
        self.layer.borderWidth = 1;
        self.layer.cornerRadius = 5;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.iv_user];
        [self addSubview:self.iv_like];
        [self addSubview:self.iv_hate];
        
        [self addSubview:self.lb_name];
        [self addSubview:self.lb_age];
        [self addSubview:self.lb_constellation];
        [self addSubview:self.lb_jobOrDistance];
    }
    return self;
}

#pragma mark - notification

- (void)moveAction:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        return;
    }
    CGFloat curPercent = [notification.object floatValue];
    V_SlideCard *cardView = (V_SlideCard *)self.superview;
    M_CardFrame *startframe = [cardView.frameArray objectAtIndex:self.currentState];
    M_CardFrame *endframe = [cardView.frameArray objectAtIndex:self.currentState - 1];
    self.x = startframe.x - (startframe.x - endframe.x) * curPercent;
    self.y = startframe.y - (startframe.y - endframe.y) * curPercent;
    self.width = startframe.width + (endframe.width - startframe.width) * curPercent;
    self.height = startframe.height + (endframe.height - startframe.height) * curPercent;
}

- (void)stateChangeAction:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        [self shouldDoSomethingWithState:UnderThirdCard];
    } else {
        [self shouldDoSomethingWithState:self.currentState - 1];
    }
}

- (void)resetFrame {
    V_SlideCard *cardView = (V_SlideCard *)self.superview;
    M_CardFrame *startframe = [cardView.frameArray objectAtIndex:self.currentState];
    self.frame = CGRectMake(startframe.x, startframe.y, startframe.width, startframe.height);
}

- (void)shouldDoSomethingWithState:(CardState)state{
    self.currentState = state;
    V_SlideCard *cardView = (V_SlideCard *)self.superview;
    M_CardFrame *startframe = [cardView.frameArray objectAtIndex:self.currentState];
    self.frame = CGRectMake(startframe.x, startframe.y, startframe.width, startframe.height);
    if (self.currentState == UnderThirdCard) {
        [cardView reloadDataWithUnderCell:self];
    }
}

- (void)dealloc {
    [self removeAllObserver];
}

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)removeAllObserver {
    NSArray *notificationNames = @[MOVEACTION, RESETFRAME, STATECHANGE];
    for (NSString *nameStr in notificationNames) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nameStr object:nil];
    }
}

#pragma mark - setter
- (void)setUserImage:(UIImage *)userImage {
    _userImage = userImage;
    self.iv_user.image = _userImage;
}

- (void)setCurrentState:(CardState)currentState {
    _currentState = currentState;
    self.userInteractionEnabled = currentState == FirstCard;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    self.lb_name.text = _userName;
}

- (void)setSignAlpha:(CGFloat)signAlpha {
    self.iv_like.alpha = signAlpha;
    self.iv_hate.alpha = - signAlpha;
}

- (void)setDataItem:(M_SlideCard *)dataItem {
    _dataItem = dataItem;
    self.lb_name.text = dataItem.userName;
    self.iv_user.image = [UIImage imageNamed:dataItem.imageName];
    self.lb_age.text = dataItem.age;
    self.lb_constellation.text = dataItem.constellationName;
    self.lb_jobOrDistance.text = dataItem.jobName.length ? dataItem.jobName : dataItem.distance;
}

#pragma mark - getter
- (UIImageView *)iv_user {
    if (!_iv_user) {
        _iv_user = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 70)];
    }
    return _iv_user;
}

- (UIImageView *)iv_like {
    if (!_iv_like) {
        _iv_like = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        _iv_like.image = [UIImage imageNamed:@"likeLine"];
        _iv_like.alpha = 0;
    }
    return _iv_like;
}

- (UIImageView *)iv_hate {
    if (!_iv_hate) {
        _iv_hate = [[UIImageView alloc]  initWithFrame:CGRectMake(self.width - 20 - 60, 20, 60, 60)];
        _iv_hate.image = [UIImage imageNamed:@"hateLine"];
        _iv_hate.alpha = 0;
    }
    return _iv_hate;
}

- (UILabel *)lb_name {
    if (!_lb_name) {
        _lb_name = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.iv_user.frame), 100, 20)];
        _lb_name.font = [UIFont boldSystemFontOfSize:16];

    }
    return _lb_name;
}

- (UILabel *)lb_age {
    if (!_lb_age) {
        _lb_age = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_name.frame), 30, 20)];
        _lb_age.font = [UIFont systemFontOfSize:13];
        _lb_age.textColor = [UIColor redColor];

    }
    return _lb_age;
}

- (UILabel *)lb_constellation {
    if (!_lb_constellation) {
        _lb_constellation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lb_age.frame), CGRectGetMaxY(self.lb_name.frame), 50, 20)];
        _lb_constellation.font = [UIFont systemFontOfSize:11];

    }
    return _lb_constellation;
}

- (UILabel *)lb_jobOrDistance {
    if (!_lb_jobOrDistance) {
        _lb_jobOrDistance = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_age.frame), 30, 20)];
        _lb_jobOrDistance.font = [UIFont systemFontOfSize:11];
    }
    return _lb_jobOrDistance;
}
@end
