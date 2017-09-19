//
//  VC_Example.m
//  TanTanDemo
//
//  Created by zhujiamin on 2016/11/15.
//  Copyright © 2016年 zhujiamin. All rights reserved.
//

#import "VC_Example.h"
#import "V_SlideCard.h"
#import "M_TanTan.h"
#import "V_TanTan.h"

@interface VC_Example ()<V_SlideCardDataSource, V_SlideCardDelegate, UICollectionViewDelegate> {
    NSInteger _pageNo;//数据页码
    CGFloat _buttonWidth;
    CGFloat _buttonBorderWidth;

}

@property (nonatomic, strong) NSMutableArray *listData;
@property (nonatomic, strong) V_SlideCard *slideCard;

@property (nonatomic, strong) UILabel *panInfo;

#pragma mark - BossJob
@property (nonatomic, strong) UIButton  *btn_;
@property (nonatomic, strong) UIButton  *btn_talk;

#pragma mark - TanTan
@property (nonatomic, strong) UIButton  *btn_like;
@property (nonatomic, strong) UIButton  *btn_hate;

@end

@implementation VC_Example

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    _pageNo = 0;
    _buttonWidth = 70;
    _buttonBorderWidth = 8;
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(leftBarButtonClick)];

    
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.slideCard];//加入滑动组件
    
    if (self.exampleType == ExampleTypeEmpty) {
        self.title = @"空白组件，没有自定义cell内容";
    } else if (self.exampleType == ExampleTypeTanTan) {
        self.title = @"探探";
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:220.0/255.0 green:100.0/255.0 blue:50.0/255.0 alpha:1];
        self.navigationController.navigationBar.translucent = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"消息" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarButtonClick)];
        
        [self.view addSubview:self.btn_like];
        [self.view addSubview:self.btn_hate];
    } else if (self.exampleType == ExampleTypeBoss) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor]};
        self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:83.0/255.0 green:202.0/255.0 blue:196.0/255.0 alpha:1];
        self.navigationController.navigationBar.translucent = NO;
        self.title = @"BOSS直聘";
        //磨砂背景
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        imageView.image = [UIImage imageNamed:@"bossBg"];
        [self .view addSubview:imageView];
        [self.view sendSubviewToBack:imageView];
        
        [self.view addSubview:self.btn_like];
        [self.view addSubview:self.btn_hate];
    }
    

//    self.automaticallyAdjustsScrollViewInsets = YES;
    
//    self.view.height -= 64;
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
//    self.modalPresentationCapturesStatusBarAppearance = NO;
}

#pragma mark - event response

- (void)likeOrHateAction:(UIButton *)sender {
     // 按钮点击缩放效果
     CABasicAnimation*pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
     pulse.timingFunction= [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     pulse.duration = 0.08;
     pulse.repeatCount= 1;
     pulse.autoreverses= YES;
     pulse.fromValue= [NSNumber numberWithFloat:0.9];
     pulse.toValue= [NSNumber numberWithFloat:1.1];
     [sender.layer addAnimation:pulse forKey:nil];
     
    if (sender.tag == 520) {
        [self.slideCard animateTopCardToDirection:PanDirectionRight];
    } else {
        [self.slideCard animateTopCardToDirection:PanDirectionLeft];
    }
}
#pragma mark - V_SlideCardDataSource

- (void)loadNewData {
    _pageNo ++;
    self.listData = [self getDataSourceWithPageNo:_pageNo];
    [self.slideCard reloadData];
}

- (void)loadNewDataInCell:(V_TanTan *)cell atIndex:(NSInteger)index {
    if (self.exampleType == ExampleTypeTanTan) {
        M_TanTan *item = [self.listData objectAtIndex:index];
        cell.dataItem = item;
    }
}

- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard {
    return self.listData.count;
}

#pragma mark - V_SlideCardDelegate

- (void)slideCardCell:(V_TanTan *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction {
    
#warning 现在空白cell 不走代理的  那么判断代理那里 还是得更完善才行
    NSString *directionDesc = (direction == PanDirectionLeft) ? @"左" : @"右";
    self.panInfo.text = [NSString stringWithFormat:@"拖拽方向：%@, 百分比：%.2f", directionDesc, percent];
    
    if (self.exampleType == ExampleTypeTanTan) {
        if (direction == PanDirectionRight) {
            cell.iv_like.alpha = percent;
            self.btn_like.layer.borderWidth = _buttonBorderWidth * (1 - percent);
        } else {
            cell.iv_hate.alpha = percent;
            self.btn_hate.layer.borderWidth = _buttonBorderWidth * (1 - percent);
        }
    }
}

- (void)slideCardCell:(V_TanTan *)cell willScrollToDirection:(PanDirection)direction {
    if (self.exampleType == ExampleTypeTanTan) {
        if (direction == PanDirectionRight) {
            cell.iv_like.alpha = 1;
        } else {
            cell.iv_hate.alpha = 1;
        }
    }
}

- (void)slideCardCell:(V_TanTan *)cell didChangedStateWithDirection:(PanDirection)direction atIndex:(NSInteger)index {
    
#warning 底部按钮borderWidth不支持动画，抽时间改成底部有个圆圈，上面有个button改变transform\
然后按钮点击时也添加个跳动效果
    
    if (self.exampleType == ExampleTypeTanTan) {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.btn_like.layer.borderWidth = _buttonBorderWidth;
            self.btn_hate.layer.borderWidth = _buttonBorderWidth;
            cell.iv_like.alpha = 0;
            cell.iv_hate.alpha = 0;
        } completion:nil];
    }
}

- (void)slideCardCellDidResetFrame:(V_TanTan *)cell {
    if (self.exampleType == ExampleTypeTanTan) {
        [UIView animateWithDuration:0.5 delay:0.0 usingSpringWithDamping:0.5 initialSpringVelocity:0.0 options:UIViewAnimationOptionAllowUserInteraction animations:^{
            self.btn_like.layer.borderWidth = _buttonBorderWidth;
            self.btn_hate.layer.borderWidth = _buttonBorderWidth;
            cell.iv_like.alpha = 0;
            cell.iv_hate.alpha = 0;
        } completion:nil];
    }
}

#pragma mark - private methods

- (void)leftBarButtonClick {
    if (self.navigationController.viewControllers.count > 1) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor blackColor]};
        self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
        self.navigationController.navigationBar.translucent = YES;
        
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)rightBarButtonClick { }

#pragma mark - getter

- (V_SlideCard *)slideCard {
    if (_slideCard == nil) {
        _slideCard = [[V_SlideCard alloc] initWithFrame:self.view.bounds];
        _slideCard.cellScaleSpace = 0.06;
        _slideCard.cellCenterYOffset = - 100;

        _slideCard.cellSize = CGSizeMake(350, 400);
        NSString *cellClassName = @"";
        if (self.exampleType == ExampleTypeTanTan) {
            cellClassName = @"V_TanTan";
        } else if (self.exampleType == ExampleTypeBoss) {
            cellClassName = @"V_BossJob";
            _slideCard.cellSize = CGSizeMake(320, 350);
            _slideCard.cellOffsetDirection = CellOffsetDirectionTop;
        }
        
        [_slideCard registerCellClassName:cellClassName];
        _slideCard.dataSource = self;
        _slideCard.delegate = self;
    }
    return _slideCard;
}

- (NSMutableArray *)listData {
    if (_listData == nil) {
        _listData = [[NSMutableArray alloc] init];
        _listData = [[self getDataSourceWithPageNo:0] copy];
    }
    return _listData;
}

- (NSMutableArray *)getDataSourceWithPageNo:(NSInteger)pageNo {
    NSMutableArray *itemArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = 0; i < 10; i++) {
        NSString *imageName = [NSString stringWithFormat:@"tantan%d%lu", 0,i];
        NSString *nickName = [NSString stringWithFormat:@"姓名%lu%lu", pageNo,i];
        
        [itemArray addObject:[[M_TanTan alloc] initWithImage:imageName andName:nickName andConstellation:@"某星座" andJob:@"职位" andDistance:[NSString stringWithFormat:@"%lu%lukm", pageNo,i] andAge:@"23岁"]];
    }
    return itemArray;
}

- (UIButton *)btn_like {
    if (_btn_like == nil) {
        _btn_like = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - _buttonWidth * 2) / 3 * 2 + _buttonWidth, self.view.frame.size.height - _buttonWidth - 30 - 64, _buttonWidth, _buttonWidth)];
        _btn_like.tag = 520;
        [_btn_like addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.exampleType == ExampleTypeTanTan) {
            _btn_like.layer.borderColor = [UIColor colorWithWhite:0.2 alpha:0.9].CGColor;
            _btn_like.layer.borderWidth = _buttonBorderWidth;
            _btn_like.layer.masksToBounds = YES;
            _btn_like.layer.cornerRadius = _buttonWidth / 2;
            [_btn_like setBackgroundImage:[UIImage imageNamed:@"tantanLike"]
                                 forState:UIControlStateNormal];
        } else if (self.exampleType == ExampleTypeBoss) {
            [_btn_like setBackgroundImage:[UIImage imageNamed:@"bossLike"]
                                 forState:UIControlStateNormal];
        }
    }
    return _btn_like;
}

- (UIButton *)btn_hate {
    if (_btn_hate == nil) {
        _btn_hate = [[UIButton alloc] initWithFrame:CGRectMake((self.view.frame.size.width - _buttonWidth * 2) / 3, self.view.frame.size.height - _buttonWidth - 30 - 64, _buttonWidth, _buttonWidth)];
        _btn_hate.tag = 521;
        [_btn_hate addTarget:self action:@selector(likeOrHateAction:) forControlEvents:UIControlEventTouchUpInside];
        if (self.exampleType == ExampleTypeTanTan) {
            _btn_hate.layer.borderColor = [UIColor colorWithWhite:0.4 alpha:0.9].CGColor;
            _btn_hate.layer.borderWidth = _buttonBorderWidth;
            _btn_hate.layer.masksToBounds = YES;
            _btn_hate.layer.cornerRadius = _buttonWidth / 2;
            [_btn_hate setBackgroundImage:[UIImage imageNamed:@"tantanHate"] forState:UIControlStateNormal];
        } else if (self.exampleType == ExampleTypeBoss) {
            [_btn_hate setBackgroundImage:[UIImage imageNamed:@"bossHate"] forState:UIControlStateNormal];
        }
        
    }
    return _btn_hate;
}

- (UILabel *)panInfo {
    if (_panInfo == nil) {
        _panInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 80, self.view.frame.size.width, 80)];
        _panInfo.numberOfLines = 0;
    }
    return _panInfo;
}
@end
