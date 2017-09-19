//
//  V_BossJob.m
//  TanTanDemo
//
//  Created by zhujiamin on 2017/9/18.
//  Copyright © 2017年 zhujiamin. All rights reserved.
//

#import "V_BossJob.h"

/** UI样式仅供示意 */
@interface V_BossJob ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation V_BossJob

- (void)initUI {
    [super initUI];
    [self.contentView addSubview:self.tableView];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *reuseId = [NSString stringWithFormat:@"cell_%ld", indexPath.row];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseId];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:reuseId];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:14];

    }
    switch (indexPath.row) {
        case 0:{
            UIButton *dealLater = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 70, 20)];
            [dealLater setImage:[UIImage imageNamed:@"dealLater"] forState:UIControlStateNormal];
            dealLater.layer.borderColor = [UIColor colorWithRed:83.0/255.0 green:202.0/255.0 blue:196.0/255.0 alpha:1].CGColor;
            dealLater.layer.borderWidth = 1.0;
            dealLater.layer.cornerRadius = 5.0;
            dealLater.titleLabel.font = [UIFont systemFontOfSize:12];
            [dealLater setTitle:@"稍后处理" forState:UIControlStateNormal];
            [dealLater setTitleColor:[UIColor colorWithRed:83.0/255.0 green:202.0/255.0 blue:196.0/255.0 alpha:1] forState:UIControlStateNormal];
            cell.accessoryType = UITableViewCellAccessoryDetailButton;
            cell.accessoryView = dealLater;
        }
            break;
        case 1:{
            UIImageView *avatar = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, 50, 50)];
            avatar.image = [UIImage imageNamed:@"avatar"];
            [cell.contentView addSubview:avatar];
            
            UIImageView *msg = [[UIImageView alloc] initWithFrame:CGRectMake(70, 10, 220, 50)];
            msg.image = [[UIImage imageNamed:@"msgContainer"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
            msg.contentMode = UIViewContentModeScaleToFill;
            [cell.contentView addSubview:msg];
            
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(85, 10, 210, 50)];
            label.text = @"简历已经发至您邮箱, 请注意查收!";
            label.font = [UIFont systemFontOfSize:13];
            label.numberOfLines = 0;
            [cell.contentView addSubview:label];
        }
            break;
        case 2:{
            cell.textLabel.text = @"牛大神 应聘iOS工程师";
            cell.detailTextLabel.text = @"15k-20k";
            cell.detailTextLabel.textColor = [UIColor redColor];
        }
            break;
        case 3:{
            cell.textLabel.text = @"杭州 | 2年 | 本科";
            cell.textLabel.textColor = [UIColor grayColor];
        }
            break;
        case 4:{
            cell.textLabel.text = @"工作经历";
        }
            break;
        case 5:{
            cell.textLabel.text = @"iOS工程师 | 阿里巴巴";
            cell.detailTextLabel.text = @"2015.10-2017.8";
        }
            break;
        case 6:{
            cell.textLabel.text = @"1.负责淘宝聊天模块的功能实现和维护； \n2.负责支付宝蚂蚁森林模块的功能实现和维护";
            cell.textLabel.numberOfLines = 0;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.font = [UIFont systemFontOfSize:13];
        }
            break;
        case 7:{
            cell.textLabel.text = @"教育经历";
        }
            break;
        case 8:{
            cell.textLabel.text = @"电子科技大学";
            cell.detailTextLabel.text = @"软件工程 | 本科";
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 70;
    }
    if (indexPath.row == 6) {
        return 60;
    }
    return 30;
}

#pragma mark - getter

- (UITableView *)tableView {
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:self.frame];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
    }
    return _tableView;
}

@end
