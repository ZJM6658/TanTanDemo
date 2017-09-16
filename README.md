# TanTanDemo
高效仿写探探首页效果（左滑hate，右滑like）

先看效果：

![示意图](https://github.com/ZJM6658/TanTanDemo/blob/master/gif/tantanGif.gif?raw=true&alt="tantanGif.gif")

#### 说明：

16年的时候，公司产品经理推荐我玩玩探探，体验一下首页交互，然后自己实现了一下，那时候完全是为了实现而实现，实现方式非常不灵活，当然，先前只是自己用用，现在大半年过去，自己对于iOS的理解无疑更深了一些，恰巧另一个项目要用到这样的控件，所以抽了点时间，采用新的方式重构了这个控件，便于复用，同时将代码托管在github，与大家互相交流学习。

#### 需求分析：
1. 四张卡片循环使用，叠在一起，前三张等比例缩小，最后一张与第三张一致；
2. 
	a. 第一张卡片支持手势拖拽移动位置;

	b. 根据拖拽的幅度和方向进行轻微旋转，同时第二、三张卡片向前一张卡片的尺寸进行缩放;

	c. 松手时拖拽距离小于一定值， 所有卡片回到初始状态；

	d. 松手时拖拽距离大于一定值，就动画飞出屏外，底下卡片位置向前进1，动画完成后卡片更新数据后填充到最底部等待被查看；
3. 
	a.向左拖拽表示不喜欢，拖拽过程卡片左上角的讨厌按钮逐渐清晰，下方讨厌按钮逐渐扩大；

	b.向右拖拽表示喜欢，拖拽过程卡片右上角的喜欢按钮逐渐清晰，下方喜欢按钮逐渐扩大；
4. 
	a. 下方两个按钮（不喜欢，喜欢），点击的时候自动完成拖拽翻页的动画；

	b. 点击卡片，采用平滑的转场动画，打开详情页面，点击详情页面中的喜欢和不喜欢按钮，先退回到卡片浏览页，再执行按钮事件；

#### 实现原理摘要：

1 . 层次结构图如下：

![层次结构图](https://github.com/ZJM6658/TanTanDemo/blob/master/QQ20170915-155709%402x.png?raw=true)

如图，我决定使用四张卡片无限轮换展示数据，于是设计了CardState（如下）这个枚举，四张卡片从上到下依次为上述四个state；

```
typedef NS_ENUM(NSInteger, CardState) {
    FirstCard = 0,
    SecondCard,
    ThirdCard,
    OtherCard,
};
```

当state==FirstCard时，card的userInteractionEnabled为YES，能响应拖拽事件；

当FirstCard拖拽移动的时候，SecondCard和ThirdCard会在区间内缩放和位移；

当FirstCard移出之后，下方的card的CardState都往上移，移出去的FirstCard会刷新数据后状态变为OtherCard放置在最底部，如此循环显示数据。

```
#define DROP_DISTANCE  100
#define TRANSFORM_SPACE  0.06
```

此外，宏定义`DROP_DISTANCE`控制着卡片拖拽松手后的处理，如果小于`DROP_DISTANCE`，则恢复原状态，否则翻过这页，进入下一个状态循环。

宏定义`TRANSFORM_SPACE`表示三张体现层叠效果的卡片之间的缩放比例之差，四个卡片的原始尺寸都是一样的，然后根据他们的状态设置他们的transform进行等比例缩小，这样在FirstCard进行拖拽的时候，地下的Card只需要同样进行缩放即可；

2 . Notification

整个过程我们需要只需要通过第一张卡片在拖拽过程中状态的变化，通过发送NSNotification通知的方式告知其他监听者做出相应的变化，四张卡片和他们的父视图都需要添加如下三个监听：

```
- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
}
```

a. `MOVEACTION`为滑动时候的通知，当FirstCard进行拖拽的时候，会发送`MOVEACTION`通知，

```  
[[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX]}];
```

`PERCENTMAIN`是  x，y方向拖拽变化的绝对值／`DROP_DISTANCE`较大的一方，让下方的SecondCard和ThirdCard做出相应的缩放和位移反应；`PERCENTX`是控制喜欢或不喜欢按钮的透明度或大小的变化；

b. `RESETFRAME`为松手的时候没有拖拽超过`DROP_DISTANCE`的通知，观察者收到通知需要恢复原状态；

c. `STATECHANGE`为松手的时候拖拽距离超过`DROP_DISTANCE`，或者点击下方的两个按钮，需要进行状态切换了，动画FirstCard飞出屏外

```
[[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike), @"CLICK": @YES}];
```

RESULT表示是否选择了喜欢，CLICK表示是否由点击按钮触发，点击按钮触发需要进行动画过度，观察者需要根据参数进行状态切换或UI调整；

3 .小tips

a. FirstCard在拖拽的过程中，根据左右方向会有一个轻微旋转；

b. 点击按钮进行卡片的切换需要额外处理，卡片的旋转方向与拖拽相反；

c. 动画的过程控制放在四张卡片的父试图中，采用代理方式传递，一个回合只允许一个Card处于动画中；


4 .详细实现，可以下载代码细看，我会把我想到的细节不断完善，欢迎交流学习，有需要可加我QQ：815187811。


#### TODO:
1.  <del> 点击按钮时，卡片可以加一个先反方向旋转10°左右，再飞出；</del>[已完成]
2. <del> 卡片可以加点shadow效果，飞入时候可以加点弹性阻尼动画效果；</del>[已完成]
3. Card内容可以抽离出来，打算采用类似collectionView registerCell的方式；
4. 点击Card跳转详情VC的转场动画；