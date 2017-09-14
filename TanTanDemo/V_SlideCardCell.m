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

@property (nonatomic) CGPoint       originalCenter;

@end

@implementation V_SlideCardCell

- (instancetype)init {
    return [self initWithFrame:CGRectMake(0, 0, SCRW, SCRH)];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        [self setUpConfig];
    }
    return self;
}

- (void)initUI {
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

- (void)setUpConfig {
    [self addAllObserver];
    
    _originalCenter = CGPointMake(-1, -1);
    //添加拖拽手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUserAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
}

- (void)panUserAction:(UIPanGestureRecognizer *)sender {
    CGPoint center = self.center;
    //横坐标上、纵坐标上拖动了多少像素
    CGPoint translation = [sender translationInView:self.superview];
    sender.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
    [sender setTranslation:CGPointZero inView:self.superview];
    
    CGPoint newCenter = sender.view.center;
    if (sender.state == UIGestureRecognizerStateChanged) {
        CGFloat width = SCRW / 2;
        CGFloat angle = M_PI_4 / 2 * (width - newCenter.x) / width;
        CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
        self.transform = transform;
        
        CGFloat PercentX = (newCenter.x - self.originalCenter.x) / DROP_DISTANCE;
        [self setSignAlpha:PercentX];
        
        CGFloat PercentY = (newCenter.y - self.originalCenter.y) / DROP_DISTANCE;
        CGFloat sendPercent = fabs(PercentX) > fabs(PercentY) ? fabs(PercentX) : fabs(PercentY);
        
        //轻微移动不做缩放操作 绝对值-0.15
//        sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
        
        //这里需要发送的是x／y的变化较大者的绝对值
        sendPercent = sendPercent >= 1 ? 1 : sendPercent;
        [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:PercentX]}];
        
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint endPoint = self.originalCenter;
        if (fabs(newCenter.x - self.originalCenter.x) > DROP_DISTANCE) {
            if ((newCenter.x - self.originalCenter.x) > 0) {
                endPoint = CGPointMake(SCRW * 2, self.originalCenter.y);
            } else {
                endPoint = CGPointMake(-SCRW * 2, self.originalCenter.y);
            }
        }
        
#warning  下面这些是不是可以把操作都放在通知里面做？ 然后各个cell动画完了state前进 最好这里只管发通知\
上面的也同理可以整理一下，各个cell可以有一个标志位表示是否在动画中，重复动画没有必要（可选）
        if (endPoint.x == self.originalCenter.x) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RESETFRAME object:@{ENDPOINT:NSStringFromCGPoint(endPoint)}];
        } else {
            [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{ENDPOINT:NSStringFromCGPoint(endPoint)}];
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

//#warning 这里有点问题啊  底下的cell移动不靠谱
- (void)moveAction:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        return;
    }
    NSLog(@"%p | frame == %@", self,NSStringFromCGRect(self.frame));

    NSDictionary *object = notification.object;
    CGFloat PercentMain = [[object objectForKey:PERCENTMAIN] floatValue];
//    NSLog(@"PercentMain == %f", PercentMain);
    CGFloat scale = 1 + 0.1 * PercentMain;//- self.currentState * 0.1
//    NSLog(@"--scale-----------%f", scale);
    self.transform = CGAffineTransformIdentity;
//    self.transform = CGAffineTransformMakeScale(scale, scale);
//    CGFloat scale = 1 - 0.1 * currentState;
    CGAffineTransform oldTransform = self.transform;
    self.transform = CGAffineTransformScale(oldTransform, scale, scale);
    
    CGFloat offsetY = MARGIN_Y * PercentMain;
    self.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - offsetY);
//    NSLog(@"--offsetY-----------%f", offsetY);
//    NSLog(@"center==%@", NSStringFromCGPoint(self.center));
}

- (void)stateChangeAction:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        NSString *pointStr = [notification.object objectForKey:ENDPOINT];
        CGPoint toPoint = CGPointFromString(pointStr);
        [UIView animateWithDuration:0.5 animations:^{
            self.center = toPoint;
            self.transform = CGAffineTransformMakeRotation(0);
            [self setSignAlpha:0];
        } completion:^(BOOL finished) {
            [self shouldDoSomethingWithState:UnderThirdCard];
        }];
    } else {
        [self shouldDoSomethingWithState:self.currentState - 1];
    }
}

- (void)resetFrame:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        NSString *pointStr = [notification.object objectForKey:ENDPOINT];
        CGPoint toPoint = CGPointFromString(pointStr);
        [UIView animateWithDuration:0.2 animations:^{
            self.center = toPoint;
            self.transform = CGAffineTransformMakeRotation(0);
            [self setSignAlpha:0];
        }];
    } else {
        self.center = self.originalCenter;
        self.transform = CGAffineTransformIdentity;
        
        //    CGFloat scale = 1 - self.currentState * 0.1;
        //    self.transform = CGAffineTransformMakeScale(scale, scale);
    }
}

- (void)shouldDoSomethingWithState:(CardState)state{
    self.currentState = state;

    if (self.currentState == UnderThirdCard) {
        if ([self.delegate respondsToSelector:@selector(loadNewData:)]) {
            [self.delegate loadNewData:self];
        }
    }
}

#pragma mark - setter
- (void)setUserImage:(UIImage *)userImage {
    _userImage = userImage;
    self.iv_user.image = _userImage;
}

- (void)setCenter:(CGPoint)center {
    [super setCenter:center];
    if (self.originalCenter.x == -1 && self.originalCenter.y == -1) {
        self.originalCenter = center;
        NSLog(@"originalCenter = %@", NSStringFromCGPoint(center));
    }
}

- (void)setCurrentState:(CardState)currentState {
    _currentState = currentState;
    
    CGFloat scale = 1 - 0.1 * currentState;
    CGAffineTransform oldTransform = self.transform;
    self.transform = CGAffineTransformScale(oldTransform, scale, scale);
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
