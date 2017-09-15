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

@property (nonatomic)         CGFloat       signAlpha;
@property (nonatomic)         CGPoint       originalCenter;

//获取当前实际缩放的state  第三个卡片及以后的缩放比例状态值一样
@property (nonatomic) NSInteger     frameState;

@end

@implementation V_SlideCardCell

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, SCRW, SCRH)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setUpConfig];
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.backgroundColor = [UIColor whiteColor];
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

- (void)setUpConfig {
    //添加拖拽手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUserAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
    
    [self addAllObserver];
}

- (void)panUserAction:(UIPanGestureRecognizer *)sender {
    CGPoint center = self.center;
    //横坐标上、纵坐标上拖动了多少像素
    CGPoint translation = [sender translationInView:self.superview];
    sender.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
    CGPoint newCenter = sender.view.center;
    
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat PercentX = (newCenter.x - self.originalCenter.x) / DROP_DISTANCE;
        CGFloat PercentY = (newCenter.y - self.originalCenter.y) / DROP_DISTANCE;
        
        //这里需要发送的是x／y的变化较大者的绝对值
        CGFloat sendPercent = fabs(PercentX) > fabs(PercentY) ? fabs(PercentX) : fabs(PercentY);
        //轻微移动不做缩放操作 绝对值 -0.15
        sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
        sendPercent = sendPercent >= 1 ? 1 : sendPercent;
        [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:PercentX]}];
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (fabs(newCenter.x - self.originalCenter.x) > DROP_DISTANCE) {
            BOOL choosedLike = YES;
            if ((newCenter.x - self.originalCenter.x) > 0) {
                choosedLike = YES;
            } else {
                choosedLike = NO;
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike)}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:RESETFRAME object:nil];
        }
    }
}

- (void)dealloc {
    NSLog(@"cell dealloc");
    [self removeAllObserver];
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)removeAllObserver {
    NSArray *notificationNames = @[MOVEACTION, RESETFRAME, STATECHANGE];
    for (NSString *nameStr in notificationNames) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:nameStr object:nil];
    }
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    [self moveWithParams:object];
}

- (void)moveWithParams:(NSDictionary *)params {
    if (self.currentState == OtherCard) return;//最底下的cell不做相应

    if (self.currentState == FirstCard) {
        //当前cell 旋转+按钮alpha改变
        CGFloat width = SCRW / 2;
        CGFloat moveToX = self.center.x;
        CGFloat angle = (1 - moveToX / width) * M_PI_4 / 2;

        //点击按钮时的动画效果
        if ([params objectForKey:@"MoveToX"]) {
            moveToX = [[params objectForKey:@"MoveToX"] floatValue];
            self.center = CGPointMake(moveToX, self.center.y);
            angle = (moveToX / width - 1)  * M_PI_4 / 2;
        }
        self.transform = CGAffineTransformMakeRotation(angle);
        
        CGFloat PercentX = [[params objectForKey:PERCENTX] floatValue];
        [self setSignAlpha:PercentX];
    } else {
        //中间cell 缩放+位移
        CGFloat PercentMain = [[params objectForKey:PERCENTMAIN] floatValue];
        CGFloat scale = 1 - self.frameState * TRANSFORM_SPACE + TRANSFORM_SPACE * PercentMain;
        CGFloat offsetY = self.cellMarginY * PercentMain;
        
        self.transform = CGAffineTransformMakeScale(scale, scale);
        self.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - offsetY);
    }
}

- (void)stateChangeAction:(NSNotification *)notification {
    BOOL choosedLike = [[notification.object objectForKey:@"RESULT"] boolValue];
    BOOL isClickButton = [[notification.object objectForKey:@"CLICK"] boolValue];

    if (isClickButton) {
        [UIView animateWithDuration:0.3 animations:^{
            CGFloat PercentX = (0 - self.originalCenter.x) / DROP_DISTANCE;
            CGFloat MoveToX = 0;
            if (choosedLike) {
                PercentX = (SCRW - self.originalCenter.x) / DROP_DISTANCE;
                MoveToX = SCRW;
            }
            CGFloat sendPercent = fabs(PercentX);
            sendPercent = sendPercent >= 1 ? 1 : sendPercent;
            [self moveWithParams:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:PercentX], @"MoveToX":[NSNumber numberWithFloat:MoveToX]}];
        } completion:^(BOOL finished) {
            [self stateChangeWithLike:choosedLike];
        }];
    } else {
        [self stateChangeWithLike:choosedLike];
    }
}

- (void)stateChangeWithLike:(BOOL)choosedLike {
    if (self.currentState == FirstCard) {
        if (choosedLike) {
            [self likeAction];
        } else {
            [self hateAction];
        }
    } else {
        [self shouldDoSomethingWithState:self.currentState - 1];
    }
}

- (void)likeAction {
    CGPoint toPoint = CGPointMake(SCRW * 2, self.originalCenter.y);
    self.iv_like.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.center = toPoint;
        self.transform = CGAffineTransformMakeRotation(0);
        [self setSignAlpha:0];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self shouldDoSomethingWithState:OtherCard];
    }];
}

- (void)hateAction {
    CGPoint toPoint = CGPointMake(- SCRW * 2, self.originalCenter.y);
    self.iv_hate.alpha = 1;
    [UIView animateWithDuration:0.5 animations:^{
        self.center = toPoint;
        self.transform = CGAffineTransformMakeRotation(0);
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self setSignAlpha:0];
        [self shouldDoSomethingWithState:OtherCard];
    }];
}

- (void)resetFrame:(NSNotification *)notification {
    [UIView animateWithDuration:0.2 animations:^{
        if (self.currentState == FirstCard) {
            self.center = self.originalCenter;
            self.transform = CGAffineTransformMakeRotation(0);
            [self setSignAlpha:0];
        } else {
            self.center = self.originalCenter;
            CGFloat scale = 1 - self.frameState * TRANSFORM_SPACE;
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    }];
}

- (void)shouldDoSomethingWithState:(CardState)state {
    self.currentState = state;
    if (self.currentState == OtherCard) {
        if ([self.delegate respondsToSelector:@selector(loadNewData:)]) {
            [self.delegate loadNewData:self];
        }
    }
}

#pragma mark - outside methods

- (void)hideToLeft {
    [self.superview sendSubviewToBack:self];
    self.center = CGPointMake(- self.height, self.originalCenter.y);
    self.transform = CGAffineTransformMakeRotation(- M_PI_2);
}

#pragma mark - setter

/** 每次重新设置state时，originalCenter和transform需要设置为当前state的值*/
- (void)setCurrentState:(CardState)currentState {
    NSAssert(self.superview, @"必须先加入父试图,再设置state");
    _currentState = currentState;
    CGFloat spaceY = self.cellMarginY * self.frameState;

    CGPoint currentStateCenter = CGPointMake(self.superview.center.x, self.superview.center.y - 60 + spaceY);
    self.originalCenter = currentStateCenter;
    self.center = currentStateCenter;
    CGFloat scale = 1 - TRANSFORM_SPACE * self.frameState;
    self.transform = CGAffineTransformMakeScale(scale, scale);
    self.userInteractionEnabled = (_currentState == FirstCard);
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

- (NSInteger)frameState {
    NSInteger state = self.currentState;
    if (state > 2) state = 2;
    return state;
}

- (UIImageView *)iv_user {
    if (_iv_user == nil) {
        _iv_user = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height - 70)];
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
        _iv_hate = [[UIImageView alloc]  initWithFrame:CGRectMake(self.width - 20 - 60, 20, 60, 60)];
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
