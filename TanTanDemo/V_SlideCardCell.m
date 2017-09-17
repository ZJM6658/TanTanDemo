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
    self.backgroundColor = [UIColor clearColor];
    //关于shadow和maskToBounds的冲突问题 可以看( http://www.cocoachina.com/ios/20150104/10816.html )中关于阴影的章节
    self.layer.shadowOffset = CGSizeMake(0, 3);
    self.layer.shadowRadius = 5.0;
    self.layer.shadowColor = [UIColor colorWithWhite:0.1 alpha:0.5].CGColor;
    self.layer.shadowOpacity = 0.3;
    
    [self addSubview:self.contentView];
}

- (void)setUpConfig {
    //添加拖拽手势
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panUserAction:)];
    panGesture.maximumNumberOfTouches = 1;
    panGesture.minimumNumberOfTouches = 1;
    [self addGestureRecognizer:panGesture];
    
    [self addAllObserver];
}

#pragma mark - UIPanGestureRecognizer
- (void)panUserAction:(UIPanGestureRecognizer *)sender {
    if (self.currentState != FirstCard) {
        return;
    }
    
    if ([self.delegate isAnimating] == NO) {
        CGPoint center = self.center;
        //横坐标上、纵坐标上拖动了多少像素
        CGPoint translation = [sender translationInView:self.superview];
        sender.view.center = CGPointMake(center.x + translation.x, center.y + translation.y);
        [sender setTranslation:CGPointZero inView:self.superview];
        CGPoint newCenter = sender.view.center;
        
        if (sender.state == UIGestureRecognizerStateChanged) {
            CGFloat percentX = (newCenter.x - self.originalCenter.x) / DROP_DISTANCE;
            CGFloat percentY = (newCenter.y - self.originalCenter.y) / DROP_DISTANCE;
            
            //这里需要发送的是x／y的变化较大者的绝对值
            CGFloat sendPercent = fabs(percentX) > fabs(percentY) ? fabs(percentX) : fabs(percentY);
            //轻微移动不做缩放操作 绝对值 -0.15
            sendPercent = sendPercent < 0.15 ? 0: sendPercent - 0.15;
            sendPercent = sendPercent >= 1 ? 1 : sendPercent;
            [[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX]}];
        } else if (sender.state == UIGestureRecognizerStateEnded) {
            if (fabs(newCenter.x - self.originalCenter.x) > DROP_DISTANCE) {
                BOOL choosedLike = NO;
                if ((newCenter.x - self.originalCenter.x) > 0) {
                    choosedLike = YES;
                }
                [[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike)}];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:RESETFRAME object:nil];
            }
        }
    }
}

- (void)dealloc {
    NSLog(@"cell dealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    [self moveWithParams:object];
}

- (void)moveWithParams:(NSDictionary *)params {
    if (self.currentState == OtherCard) return;//最底下的cell不做响应

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
        
        CGFloat percentX = [[params objectForKey:PERCENTX] floatValue];
//        [self setSignAlpha:percentX];
    } else {
        //中间cell 缩放+位移
        CGFloat percentMain = [[params objectForKey:PERCENTMAIN] floatValue];
        CGFloat scale = 1 - self.frameState * TRANSFORM_SPACE + TRANSFORM_SPACE * percentMain;
        CGFloat offsetY = self.cellMarginY * percentMain;
        
        self.transform = CGAffineTransformMakeScale(scale, scale);
        self.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - offsetY);
    }
}

- (void)stateChangeAction:(NSNotification *)notification {
    BOOL choosedLike = [[notification.object objectForKey:@"RESULT"] boolValue];
    BOOL isClickButton = [[notification.object objectForKey:@"CLICK"] boolValue];

    if (isClickButton) {
        if (self.currentState == FirstCard) {
            [self.delegate setAnimatingState:YES];
        }
#warning 这个动画时间可能有点长，找时间再调
        [UIView animateKeyframesWithDuration:0.8 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeCubicPaced animations:^{
            [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:1/4.0 animations:^{
                //FirstCard先回撤
                if (self.currentState == FirstCard) {
                    CGFloat angle = 5.0 / 180 * M_PI;
                    CGFloat centerOffsetX = 10;
                    if (choosedLike) {
                        angle = - angle;
                        centerOffsetX = - centerOffsetX;
                    }
                    self.center = CGPointMake(self.center.x + centerOffsetX, self.center.y);
                    self.transform = CGAffineTransformMakeRotation(angle);
                }
            }];
            [UIView addKeyframeWithRelativeStartTime:1/4.0 relativeDuration:1/4.0 animations:^{
                //FirstCard再恢复原位
                if (self.currentState == FirstCard) {
                    self.center = self.originalCenter;
                    self.transform = CGAffineTransformMakeRotation(0);
                }
            }];
            [UIView addKeyframeWithRelativeStartTime:1/2.0 relativeDuration:1/2.0 animations:^{
                CGFloat percentX = (0 - self.originalCenter.x) / DROP_DISTANCE;
                CGFloat moveToX = - SCRW;
                if (choosedLike) {
                    percentX = (SCRW - self.originalCenter.x) / DROP_DISTANCE;
                    moveToX = SCRW * 2;
                }
                CGFloat sendPercent = fabs(percentX);
                sendPercent = sendPercent >= 1 ? 1 : sendPercent;
                [self moveWithParams:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX], @"MoveToX":[NSNumber numberWithFloat:moveToX]}];
            }];
        } completion:^(BOOL finished) {
            [self stateChangeWithLike:choosedLike isClick:YES];
        }];
    } else {
        [self stateChangeWithLike:choosedLike isClick:NO];
    }
}

- (void)stateChangeWithLike:(BOOL)choosedLike isClick:(BOOL)isClick{
    if (self.currentState == FirstCard) {
        if (choosedLike) {
            [self likeActionWithDuration:isClick ? 0 : 0.3];
        } else {
            [self hateActionWithDuration:isClick ? 0 : 0.3];
        }
    } else {
        [self shouldDoSomethingWithState:self.currentState - 1];
    }
}

- (void)likeActionWithDuration:(NSTimeInterval)duration {
    CGPoint toPoint = CGPointMake(SCRW * 2, self.originalCenter.y);
//    self.iv_like.alpha = 1;
    [self.delegate setAnimatingState:YES];
    [UIView animateWithDuration:duration animations:^{
        self.center = toPoint;
        self.transform = CGAffineTransformMakeRotation(0);
//        [self setSignAlpha:0];
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self shouldDoSomethingWithState:OtherCard];
        [self.delegate setAnimatingState:NO];
    }];
}

- (void)hateActionWithDuration:(NSTimeInterval)duration {
    CGPoint toPoint = CGPointMake(- SCRW, self.originalCenter.y);
//    self.iv_hate.alpha = 1;
    [self.delegate setAnimatingState:YES];
    [UIView animateWithDuration:duration animations:^{
        self.center = toPoint;
        self.transform = CGAffineTransformMakeRotation(0);
        self.alpha = 0;
    } completion:^(BOOL finished) {
//        [self setSignAlpha:0];
        [self shouldDoSomethingWithState:OtherCard];
        [self.delegate setAnimatingState:NO];
    }];
}

- (void)resetFrame:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        [self.delegate setAnimatingState:YES];
    }
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (self.currentState == FirstCard) {
            self.center = self.originalCenter;
            self.transform = CGAffineTransformMakeRotation(0);
//            [self setSignAlpha:0];
        } else {
            self.center = self.originalCenter;
            CGFloat scale = 1 - self.frameState * TRANSFORM_SPACE;
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    } completion:^(BOOL finished) {
        if (self.currentState == FirstCard) {
            [self.delegate setAnimatingState:NO];
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

#pragma mark - getter

- (NSInteger)frameState {
    NSInteger state = self.currentState;
    if (state > 2) state = 2;
    return state;
}

- (UIView *)contentView {
    if (_contentView == nil) {
        _contentView = [[UIView alloc] initWithFrame:self.bounds];
        _contentView.backgroundColor = [UIColor whiteColor];
        _contentView.layer.borderColor = RGBA(220, 220, 220, 1).CGColor;
        _contentView.layer.borderWidth = 1.0;
        _contentView.layer.cornerRadius = 5.0;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

@end
