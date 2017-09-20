# V_SlideCard

轻量级层叠轮播控件V_SlideCard，轻松实现探探首页效果，Boss直聘新开聊，招财猫直聘职位浏览等等...

###先看几个示例：

探探（首页）：

![探探](https://github.com/ZJM6658/TanTanDemo/blob/master/SlideCardGif/tantan.gif?raw=true&alt="tantanGif.gif")

Boss直聘（查看新开聊）：

![探探](https://github.com/ZJM6658/TanTanDemo/blob/master/SlideCardGif/boss.gif?raw=true&alt="tantanGif.gif")

招财猫：
略

###怎么使用

下面的空白示例有助于你理解`V_SlideCard`这个控件，它只是一个层叠轮播控件，支持**自定义cell内容**以及在各个状态做出相应的处理，支持不同的层叠方向等等，cell被拖拽时会将拖拽的方向、百分比、当前拖拽的cell，数据源index等信息通过delegate提供给使用方，拖拽结束后的翻页or恢复，以及点击也会提供应有的信息给使用方，具体代码及使用请下载Demo查看；

![空白示例](https://github.com/ZJM6658/TanTanDemo/blob/master/SlideCardGif/empty.gif?raw=true&alt="tantanGif.gif")

### 协议方法如下
```

@protocol V_SlideCardDataSource<NSObject>

/** 加载一组新数据 */
- (void)loadNewDataInSlideCard:(V_SlideCard *)slideCard;

/** 返回数据数量 */
- (NSInteger)numberOfItemsInSlideCard:(V_SlideCard *)slideCard;

/** cell翻页后进入最底层时，需要重新加载数据, 将cell返回给开发者自己设置 */
- (void)slideCard:(V_SlideCard *)slideCard loadNewDataInCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end

@protocol V_SlideCardDelegate<NSObject>
@optional
/** 提供用户拖拽方向 & panDistance的百分比 0.0～1.0 & index*/
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell didPanPercent:(CGFloat)percent withDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供用户点击按钮调用翻页的时候将要翻的cell & 翻页方向 & index */
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell willScrollToDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供翻页完成后的cell & 翻页方向 & index */
- (void)slideCard:(V_SlideCard *)slideCard topCell:(V_SlideCardCell *)cell didChangedStateWithDirection:(PanDirection)direction atIndex:(NSInteger)index;

/** 提供拖拽距离不够翻页时松手恢复原状态的cell & index */
- (void)slideCard:(V_SlideCard *)slideCard didResetFrameInCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

/** 提供用户点击的cell & index */
- (void)slideCard:(V_SlideCard *)slideCard didSelectCell:(V_SlideCardCell *)cell atIndex:(NSInteger)index;

@end

```

使用者只需要将`SlideCard`文件夹拖入项目，**继承**`V_SlideCardCell`实现自己自定义cell内容，然后注册给`V_SlideCard`控件即可，此外，cell的**层叠方向**，**位置**，**大小**，**缩放间隔**，**拖拽阀值**等等都可以自定义。

希望对看到的你有帮助，欢迎交流（QQ：815187811），

------------

#### 本来一开始只想写个功能，后来慢慢抽象，知道可以随便扩展，还有很多可以优化的点，有时间会继续。。。

------
#### 旧的说明：


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

<del>
```
#define DROP_DISTANCE  100
#define TRANSFORM_SPACE  0.06
```

此外，宏定义`DROP_DISTANCE`控制着卡片拖拽松手后的处理，如果小于`DROP_DISTANCE`，则恢复原状态，否则翻过这页，进入下一个状态循环。

宏定义`TRANSFORM_SPACE`表示三张体现层叠效果的卡片之间的缩放比例之差，四个卡片的原始尺寸都是一样的，然后根据他们的状态设置他们的transform进行等比例缩小，这样在FirstCard进行拖拽的时候，地下的Card只需要同样进行缩放即可；</del>

[已经替换为属性方法，减少耦合.]

2 . Notification

整个过程我们需要只需要通过第一张卡片在拖拽过程中状态的变化，通过发送NSNotification通知的方式告知其他监听者做出相应的变化，四张卡片和他们的父视图都需要添加如下三个监听：

```
- (void)addAllObserver {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moveAction:) name:MOVEACTION object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame:) name:RESETFRAME object:nil];
}
```

a. `MOVEACTION`为滑动时候的通知，当FirstCard进行拖拽的时候，会发送`MOVEACTION`通知，

```  
[[NSNotificationCenter defaultCenter] postNotificationName:MOVEACTION object:@{PERCENTMAIN:[NSNumber numberWithFloat:sendPercent], PERCENTX:[NSNumber numberWithFloat:percentX]}];
```

`PERCENTMAIN`是  x，y方向拖拽变化的绝对值／`DROP_DISTANCE`较大的一方，让下方的SecondCard和ThirdCard做出相应的缩放和位移反应；`PERCENTX`是控制喜欢或不喜欢按钮的透明度或大小的变化；

b. `RESETFRAME`为松手的时候没有拖拽超过`DROP_DISTANCE`的通知，观察者收到通知需要恢复原状态；

 <del>
c. `STATECHANGE`为松手的时候拖拽距离超过`DROP_DISTANCE`，或者点击下方的两个按钮，需要进行状态切换了，动画FirstCard飞出屏外；
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stateChangeAction:) name:STATECHANGE object:nil];
[[NSNotificationCenter defaultCenter] postNotificationName:STATECHANGE object:@{@"RESULT":@(choosedLike), @"CLICK": @YES}];
RESULT表示是否选择了喜欢，CLICK表示是否由点击按钮触发，点击按钮触发需要进行动画过度，观察者需要根据参数进行状态切换或UI调整；

</del>

[为了更好地控制动画和取到`topCard`，将`stateChange`处理放在父容器中，RESULT替换为direction.]


3 .小tips

a. FirstCard在拖拽的过程中，根据左右方向会有一个轻微旋转；

b. 点击按钮进行卡片的切换需要额外处理，卡片的旋转方向与拖拽相反；

c. 动画的过程控制放在四张卡片的父试图中，采用代理方式传递，一个回合只允许一个Card处于动画中；


4 .详细实现，可以下载代码细看，我会把我想到的细节不断完善，欢迎交流学习，有需要可加我QQ：815187811。


#### TODO:
1.  <del> 点击按钮时，卡片可以加一个先反方向旋转10°左右，再飞出；</del>[已完成]
2. <del> 卡片可以加点shadow效果，飞入时候可以加点弹性阻尼动画效果；</del>[已完成]
3. <del> Card内容可以抽离出来，打算采用类似collectionView registerCell的方式；</del>[已完成]
4. 点击Card跳转详情VC的转场动画；