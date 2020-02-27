# NNCodeToolBox说明文档
### 丑话说在前头
丑是真的丑，由于作者直男属性导致该项目的界面设计非常硬核，也请不要期待后期我会进行美颜。该项目界面使用vue开发，用webview加载，这一切都是因为我的任性和善变，只有web开发的便捷性才能跟上我的善变。所以，体验上不要有太高的期待，能用就行。

### 一、为什么要做这个项目呢
因为工作职责和公司性质的要求，我通常一天上班会同时运行四五个node项目以及各种各样的其他项目，而且我基本上三四个月才会重启一次电脑，所以大量项目同时运行是常态。时间一长就会忘记各种各样的窗口是在干嘛的，而且会造成大量资源的浪费。而且在日常的工作中会遇到大量重复而无意义的操作，所以打算做个项目助手来管理日常的项目开发工作。好的，想在这个助手来了，那么它到底能做些什么呢？

### 二、能做些什么
#### 1、浏览目录

![-w1174](https://github.com/ljnjiannan/nntoolbox/blob/master/img/15826965178596.jpg)

首先是可以浏览磁盘目录，并且在目录列表的名称后面会标记该目录是否使用了版本控制系统，目前支持标记的仅有git和svn。目录的操作还有在Finder中打开、在终端中打开和在IDE打开，当然终端和IDE的常用软件是可以在设置中配置的。

![-w1181](https://github.com/ljnjiannan/nntoolbox/blob/master/img/15826976323581.jpg)


#### 2、git管理
虽然现在目录支持svn和git的标记，但是版本控制的操作实际仅支持git。有可能永远不会支持svn，没错，svn伤害过我。
git的管理目前有查看本地和远程分支，分支的follow，代码的push、pull、add、commit等，后面会根据实际使用情况不断的增加。

#### 3、node项目管理
因为现在工作中遇到的最多的是node项目，所以从node项目的相关信息做起，之后会酌情加入其它类型的项目。node项目中可以查看可执行的命令并执行。可以查看各种已安装依赖，之后会加入依赖版本管理。

#### 4、项目概览
![-w1181](https://github.com/ljnjiannan/nntoolbox/blob/master/img/15827017631605.jpg)

项目概览中现在可以看到正在运行中的项目（当然目前只有node项目）和历史项目。还可以直接搜索GitHub，后期会看心情加入npm之类的各种搜索。还可以在项目概览中添加常用网站，个人觉得比打开浏览器的收藏夹方便多了。

### 三、开始使用


```
// 克隆项目
git clone https://e.coding.net/ljnjiannan/tools-box.git
// pod初始化项目，需要先安装好cocopods环境
cd tools-box && pod install
// 生成web端文件，需要先安装好node环境
cd web && npm install && npm run build 

用xcode打开nnpa.xcworkspace，编译运行
```
