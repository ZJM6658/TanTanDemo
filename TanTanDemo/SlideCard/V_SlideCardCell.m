//
//  V_SlideCardCell.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/16.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "V_SlideCardCell.h"

@interface V_SlideCardCell ()

@property (nonatomic, readwrite) CGPoint originalCenter;
//获取当前实际缩放的state  第三个卡片及以后的缩放比例状态值一样
@property (nonatomic) NSInteger     frameState;

@end

@implementation V_SlideCardCell

- (instancetype)init {
    return [self initWithFrame:[UIScreen mainScreen].bounds];
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
    [self addAllObserver];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - notification

- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
}

- (void)moveAction:(NSNotification *)notification {
    NSDictionary *object = notification.object;
    [self moveWithParams:object];
}

- (void)moveWithParams:(NSDictionary *)params {
    if (self.currentState == OtherCard) return;//最底下的cell不做响应

    if (self.currentState == FirstCard) {
        //当前cell 旋转+按钮alpha改变
        CGFloat width = [UIScreen mainScreen].bounds.size.width / 2;
        CGFloat moveToX = self.center.x;
        CGFloat angle = (1 - moveToX / width) * M_PI_4 / 2;

        //点击按钮时的动画效果
        if ([params objectForKey:@"MoveToX"]) {
            moveToX = [[params objectForKey:@"MoveToX"] floatValue];
            self.center = CGPointMake(moveToX, self.center.y);
            angle = (moveToX / width - 1)  * M_PI_4 / 2;
        }
        self.transform = CGAffineTransformMakeRotation(angle);
    } else {
        //中间cell 缩放+位移
        CGFloat percentMain = [[params objectForKey:PERCENTMAIN] floatValue];
        CGFloat scale = 1 - self.frameState * self.scaleSpace + self.scaleSpace * percentMain;

        //尝试过单独设置cell间Y方向的偏移间隔, 出现问题是缩放的改变和Y的改变不匹配, 松手时会抖动导致过渡不平滑
        CGFloat currentSpaceY = self.heightSpace * percentMain;
        if (self.offsetDirection == CellOffsetDirectionTop) {
            currentSpaceY *= -1;
        }
        self.transform = CGAffineTransformMakeScale(scale, scale);
        self.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - currentSpaceY);
    }
}

- (void)resetFrame:(NSNotification *)notification {
    if (self.currentState == FirstCard) {
        [self.delegate setAnimatingState:YES];
    }
    [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
        if (self.currentState == FirstCard) {
            self.center = self.originalCenter;
            self.transform = CGAffineTransformMakeRotation(0);
        } else {
            self.center = self.originalCenter;
            CGFloat scale = 1 - self.frameState * self.scaleSpace;
            self.transform = CGAffineTransformMakeScale(scale, scale);
        }
    } completion:^(BOOL finished) {
        if (self.currentState == FirstCard) {
            [self.delegate setAnimatingState:NO];
        }
    }];
}

#pragma mark - outside methods

- (void)hideToLeft {
    [self.superview sendSubviewToBack:self];
    self.center = CGPointMake(- self.frame.size.height, self.originalCenter.y);
    self.transform = CGAffineTransformMakeRotation(- M_PI_2);
}

#pragma mark - setter

/** 每次重新设置state时, originalCenter和transform需要设置为当前state的值*/
- (void)setCurrentState:(CardState)currentState {
    NSAssert(self.superview, @"必须先加入父试图,再设置state");
    _currentState = currentState;
   
    CGFloat spaceY = self.heightSpace * self.frameState;//除2后刚好平齐
    if (self.offsetDirection == CellOffsetDirectionTop) {
        spaceY *= -1;
    }
    CGPoint currentStateCenter = CGPointMake(self.superview.center.x, self.superview.center.y + self.centerYOffset + spaceY);
    self.originalCenter = currentStateCenter;
    self.center = currentStateCenter;
    CGFloat scale = 1 - self.scaleSpace * self.frameState;
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
        _contentView.layer.borderColor = [UIColor colorWithRed:220/255.0 green:220/255.0 blue:220/255.0 alpha:1].CGColor;
        _contentView.layer.borderWidth = 1.0;
        _contentView.layer.cornerRadius = 5.0;
        _contentView.layer.masksToBounds = YES;
    }
    return _contentView;
}

@end
