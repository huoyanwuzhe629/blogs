---
date: 2018-07-06
title: "移动端自适应实践"
tags: [
    "mobile",
    "rem"
]
categories: [
    "移动开发"
]
---

### 市面上的方案

- 流式布局

也就是固定高度，宽度使用百分比的方法，这种方法会导致一些元素在大屏手机上拉伸严重的情况，影响视觉效果，只有在很少一部分手机上能完美的展示设计师想要的效果。携程之前用的就是流式布局，但之后也改版了。

- 固定宽度做法

比如早期的淘宝webpage，页面设置成320的宽度，超出部分留白，在大屏幕手机上，就会出现两条大百边，分辨率高的手机，页面看起来就会特别小，按钮，文字也很小，之后淘宝改了布局方案，也就是接下来要讲的rem布局

<!--more-->

- 响应式做法

使用响应式框架以及大量使用媒体查询来写样式，这种方式维护成本高

- 设置viewport进行缩放

天猫的web app的首页就是采用这种方式去做的，以320宽度为基准，进行缩放，最大缩放为320*1.3 = 416，基本缩放到416都就可以兼容iphone6 plus的屏幕了，这个方法简单粗暴，又高效，不过缩放会导致有些页面元素会糊

- rem布局

rem是css3新引入的单位，在pc端会有兼容性的问题，对移动端比较友好。简而言之就是通过动态设置html根元素的fontsize，等比缩放元素大小来自适应移动设备。


### rem方案

#### 原理

rem布局的本质就是等比缩放，一般是基于宽度

假设我们将屏幕宽度平均分成100份，每一份的宽度用x表示，x = 屏幕宽度 / 100，如果将x作为单位，x前面的数值就代表屏幕宽度的百分比

```
p {width: 50x} /* 屏幕宽度的50% */ 
```

如果想要页面元素随着屏幕宽度等比变化，我们需要上面的x单位，我们可以通过rem来实现x，子元素设置rem单位的属性，通过更改html元素的字体大小，就可以让子元素实际大小发生变化

```
html {font-size: 16px}
p {width: 2rem} /* 32px*/

html {font-size: 32px}
p {width: 2rem} /*64px*/
```
如果让html元素字体的大小，恒等于屏幕宽度的1/100，那1rem和1x就等价了

```
html {fons-size: width / 100}
p {width: 50rem} /* 50rem = 50x = 屏幕宽度的50% */ 
```

所以只要做到以下两步即可

- 根据设备屏幕的DPR（设备像素比，比如dpr=2时，表示1个CSS像素由2X2个物理像素点组成） 动态设置 html 的font-size
- 同时根据设备DPR调整页面的缩放值，进而达到高清效果。

#### 设置流程

-  设置viewport

	通过脚本设置html的viewport，脚本写到所有 css 引用之前, 否则部分安卓机有问题
	
```
<head>
    <meta charset="UTF-8">
    <meta content="yes" name="apple-mobile-web-app-capable">
    <meta content="yes" name="apple-touch-fullscreen">
    <meta content="telephone=no,email=no" name="format-detection">
    <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, minimum-scale=1, user-scalable=no" />
    <title>手机搜索就用搜狗</title>
    <script>
        (function () {
            var dpr, scale;
            var docEl = document.documentElement;
            var metaEl = document.querySelector('meta[name="viewport"]');
            dpr = window.devicePixelRatio || 1;

            scale = 1 / dpr;
            // 设置viewport，进行缩放，达到高清效果
            metaEl.setAttribute('content', 'width=device-width' + ',initial-scale=' + scale + ',maximum-scale=' + scale + ', minimum-scale=' + scale + ',user-scalable=no');
            // 设置data-dpr属性，留作的css hack之用
            docEl.setAttribute('data-dpr', dpr);
            var updateView = function (width) {
                docEl.style.fontSize = width / 10 + 'px';
            }
            updateView(docEl.getBoundingClientRect().width);
            var a = null;
            window.addEventListener("resize", function () {
                clearTimeout(a);
                a = setTimeout(function () {
                    updateView(docEl.getBoundingClientRect().width);
                }, 300);
            }, false)

            //alert(docEl.getBoundingClientRect().width)
        })();
    </script>
    <link href="/dist/mobileApp.css" rel="stylesheet" type="text/css">

</head>
```

- 设置rem

业务代码可以继续根据设计稿以px为单位，但是要做好单位转化，比如在webpack中，使用pxtorem进行配置，即最后页面运行的代码中，单位是rem

我们的项目目前1rem的单位是十分之一个设备宽度，业内也有把初始rem单位设置为100px的，不同的设置单位，脚本中设置html节点的fontsize逻辑也不一样

```
const pxtoremOpts = {
  rootValue: 37.5,
  // unitPrecision: 5,
  propWhiteList: [],
  // selectorBlackList: [],
  // replace: true,
  // mediaQuery: false,
  // minPixelValue: 2
};

module.exports = {
  plugins: [
    require('autoprefixer')(),
    require('postcss-pxtorem')(pxtoremOpts)
  ]
}
```

- 检查是否生效

设置完毕后，在页面上 console.log(document.documentElement.clientWidth) 查看 iPhone6 是否为 750


### 比rem更好的方案

上面提到想让页面元素随着页面宽度变化，需要一个新的单位x，x等于屏幕宽度的百分之一，css3带来了rem的同时，也带来了vw和vh

> vw —— 视口宽度的 1/100；vh —— 视口高度的 1/100 —— MDN

根据定义可以发现1vw=1x，有了vw我们完全可以绕过rem这个中介了，下面两种方案是等价的，可以看到vw比rem更简单，毕竟rem本来就是为了实现vw的效果

```
/* rem方案 */
html {fons-size: width / 100}
p {width: 15.625rem}

/* vw方案 */
p {width: 15.625vw}
```

vw还可以和rem方案结合，这样计算html字体大小就不需要用js了

```
html {fons-size: 1vw} /* 1vw = width / 100 */
p {width: 15.625rem}
```

#### 缺点

- vw的兼容性不如rem好

| 兼容性 | Ios | 安卓 |

| ---- | ---- | ---- |

| rem | 4.1+ | 2.1+ |

| vw | 6.1+ | 4.4+ |

- pc端查看无法限制最大宽度，保证pc端样式不随着屏幕宽度而变化


### rem方案的适用范围

rem是弹性布局的一种实现方式，弹性布局可以算作响应式布局的一种，但响应式布局不是弹性布局，弹性布局强调等比缩放，100%还原；响应式布局强调不同屏幕要有不同的显示，比如媒体查询

- 一般内容型的网站，都不太适合使用rem，因为大屏用户可以自己选择是要更大字体，还是要更多内容，一旦使用了rem，就剥夺了用户的自由，比如百度知道，百度经验都没有使用rem布局；一些偏向app类的，图标类的，图片类的，比如淘宝，活动页面，比较适合使用rem，因为调大字体时并不能调大图标的大小

- 字体的问题

字体大小并不能使用rem，字体的大小和字体宽度，并不成线性关系，所以字体大小不能使用rem；由于设置了根元素字体的大小，会影响所有没有设置字体大小的元素，因为字体大小是会继承的

可以通过修改body字体的大小来实现响应式，同时所有设置字体大小的地方都是用em单位

```
@media screen and (min-width: 320px) {
	body {font-size: 16px}
}
@media screen and (min-width: 481px) and (max-width:640px) {
	body {font-size: 18px}
}
@media screen and (min-width: 641px) {
	body {font-size: 20px}
}

p {font-size: 1.2em}
p a {font-size: 1.2em}
```


- PC端浏览

一般我们都会设置一个最大宽度，大于这个宽度的话页面居中，两边留白

```
var clientWidth = document.documentElement.clientWidth;
clientWidth = clientWidth < 780 ? clientWidth : 780;
document.documentElement.style.fontSize = clientWidth / 100 + 'px';
```

设置body的宽度为100rem，并水平居中

```
body { margin: auto; width: 100rem } 
```

- 禁用js

放弃！noscript提示

- 更好的体验（媒体查询）

```
@media screen and (min-width: 320px) {
	html {font-size: 3.2px}
}
@media screen and (min-width: 481px) and (max-width:640px) {
	html {font-size: 4.8px}
}
@media screen and (min-width: 641px) {
	html {font-size: 6.4px}
}
```

### 总结

>rem不是银弹，这个世上也没有银弹，每个方案都有其优点，也有其缺点，学会做出选择和妥协

