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

@property (nonatomic, strong) UIImageView   *iV_User;
@property (nonatomic, strong) UIImageView   *iV_Like;
@property (nonatomic, strong) UIImageView   *iV_Hate;
@property (nonatomic, strong) UILabel       *lb_Name;
@property (nonatomic, strong) UILabel       *lb_Age;
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
        
        [self addSubview:self.iV_User];
        [self addSubview:self.iV_Like];
        [self addSubview:self.iV_Hate];
        
        [self addSubview:self.lb_Name];
        [self addSubview:self.lb_Age];
        [self addSubview:self.lb_constellation];
        [self addSubview:self.lb_jobOrDistance];
    }
    return self;
}

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

- (void)setCurrentState:(CardState)currentState {
    _currentState = currentState;
    self.userInteractionEnabled = currentState == FirstCard;
}

#pragma mark - setter
- (void)setUserImage:(UIImage *)userImage {
    _userImage = userImage;
    self.iV_User.image = _userImage;
}

- (void)setUserName:(NSString *)userName {
    _userName = userName;
    self.lb_Name.text = _userName;
}

- (void)setSignAlpha:(CGFloat)signAlpha {
    self.iV_Like.alpha = signAlpha;
    self.iV_Hate.alpha = - signAlpha;
}

#pragma mark - getter
- (UIImageView *)iV_User {
    if (!_iV_User) {
        _iV_User = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 70)];
    }
    return _iV_User;
}

- (UIImageView *)iV_Like {
    if (!_iV_Like) {
        _iV_Like = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 60, 60)];
        _iV_Like.image = [UIImage imageNamed:@"likeLine"];
        _iV_Like.alpha = 0;
    }
    return _iV_Like;
}

- (UIImageView *)iV_Hate {
    if (!_iV_Hate) {
        _iV_Hate = [[UIImageView alloc]  initWithFrame:CGRectMake(self.width - 20 - 60, 20, 60, 60)];
        _iV_Hate.image = [UIImage imageNamed:@"hateLine"];
        _iV_Hate.alpha = 0;
    }
    return _iV_Hate;
}

- (UILabel *)lb_Name {
    if (!_lb_Name) {
        _lb_Name = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.iV_User.frame), 100, 20)];
        _lb_Name.font = [UIFont boldSystemFontOfSize:16];

    }
    return _lb_Name;
}

- (UILabel *)lb_Age {
    if (!_lb_Age) {
        _lb_Age = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_Name.frame), 30, 20)];
        _lb_Age.font = [UIFont systemFontOfSize:13];
        _lb_Age.textColor = [UIColor redColor];

    }
    return _lb_Age;
}

- (UILabel *)lb_constellation {
    if (!_lb_constellation) {
        _lb_constellation = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.lb_Age.frame), CGRectGetMaxY(self.lb_Name.frame), 50, 20)];
        _lb_constellation.font = [UIFont systemFontOfSize:11];

    }
    return _lb_constellation;
}

- (UILabel *)lb_jobOrDistance {
    if (!_lb_jobOrDistance) {
        _lb_jobOrDistance = [[UILabel alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(self.lb_Age.frame), 30, 20)];
        _lb_jobOrDistance.font = [UIFont systemFontOfSize:11];
    }
    return _lb_jobOrDistance;
}

- (void)setDataItem:(M_SlideCard *)dataItem {
    _dataItem = dataItem;
    self.lb_Name.text = dataItem.userName;
    self.iV_User.image = [UIImage imageNamed:dataItem.imageName];
    self.lb_Age.text = dataItem.age;
    self.lb_constellation.text = dataItem.constellationName;
    self.lb_jobOrDistance.text = dataItem.jobName.length ? dataItem.jobName : dataItem.distance;
}

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)dealloc {
    [self removeAllObserver];
}

- (void)removeAllObserver {
    NSArray *notificationNames = @[MOVEACTION, RESETFRAME, STATECHANGE];
    for (NSString *nameStr in notificationNames) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nameStr object:nil];
    }
}
@end
