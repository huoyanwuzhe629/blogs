---
date: 2019-04-02
title: "小程序开发选型"
tags: [
    "小程序",
    "框架选型"
]
categories: [
    "小程序"
]
---

## 小程序开发选型分享

现在小程序的开发也越来越成熟了，完善了很多的API、组件、架构等，社区也由原来的零星点点到现在的不大不小，但也算是有了，期间也诞生了很多的开发框架，下面简单介绍下

### 开发框架

1. [wepy](https://github.com/Tencent/wepy "wepy")
	
腾讯官方的开发框架，WePY (发音: /'wepi/)是一款让小程序支持组件化开发的框架，通过预编译的手段让开发者可以选择自己喜欢的开发风格去开发小程序。框架的细节优化，Promise，Async Functions的引入都是为了能让开发小程序项目变得更加简单，高效。

借鉴了Vue的语法风格和功能特性,支持了Vue的诸多特征，比如父子组件、组件之间的通信、computed属性计算、wathcer监听器、props传值、slot槽分发，还有很多高级的特征支持：Mixin混合、拦截器等

特点： 

- 类Vue开发风格
- 支持自定义组件开发
- 支持引入NPM包
- 支持Promise
- 支持ES2015+特性，如Async Functions
- 支持多种编译器，Less/Sass/Stylus/PostCSS、Babel/Typescript、Pug
- 支持多种插件处理，文件压缩，图片压缩，内容替换等
- 支持 Sourcemap，ESLint等
- 小程序细节优化，如请求列队，事件优化等

目录结构：

```
├── dist                   小程序运行代码目录（该目录由WePY的build指令自动编译生成，请不要直接修改该目录下的文件）
├── node_modules           
├── src                    代码编写的目录（该目录为使用WePY后的开发目录）
|   ├── components         WePY组件目录（组件不属于完整页面，仅供完整页面或其他组件引用）
|   |   ├── com_a.wpy      可复用的WePY组件a
|   |   └── com_b.wpy      可复用的WePY组件b
|   ├── pages              WePY页面目录（属于完整页面）
|   |   ├── index.wpy      index页面（经build后，会在dist目录下的pages目录生成index.js、index.json、index.wxml和index.wxss文件）
|   |   └── other.wpy      other页面（经build后，会在dist目录下的pages目录生成other.js、other.json、other.wxml和other.wxss文件）
|   └── app.wpy            小程序配置项（全局数据、样式、声明钩子等；经build后，会在dist目录下生成app.js、app.json和app.wxss文件）
└── package.json           项目的package配置
```

代码编写方式:
```
<style lang="less">
    @color: #4D926F;
    .userinfo {
        color: @color;
    }
</style>
<template lang="pug">
    view(class='container')
        view(class='userinfo' @tap='tap')
            mycom(:prop.sync='myprop' @fn.user='myevent')
            text {{now}}
</template>

<script>
    import wepy from 'wepy';
    import mycom from '../components/mycom';

    export default class Index extends wepy.page {
        
        components = { mycom };
        data = {
            myprop: {}
        };
        computed = {
            now () { return +new Date(); }
        };
        async onLoad() {
            await sleep(3);
            console.log('Hello World');
        }
        sleep(time) {
            return new Promise((resolve, reject) => setTimeout(() => resolve, time * 1000));
        }
    }
</script>
```


原生项目目录结构
```
project
├── pages
|   ├── index
|   |   ├── index.js    index 页面逻辑
|   |   ├── index.json  index 页面配置
|   |   ├── index.wxml  index 页面结构
|   |   └── index.wxss  index 页面样式
|   └── log
|       ├── log.js      log 页面逻辑
|       ├── log.json    log 页面配置
|       ├── log.wxml    log 页面结构
|       └── log.wxss    log 页面样式
├── app.js              小程序逻辑
├── app.json            小程序公共配置
└── app.wxss            小程序公共样式
```
原理：
   代码解析和编译
   
![](https://bizimg.sogoucdn.com/201901/11/14/01/bizinput-pro-fe/QQ图片20190111140100.png)

注意点：

- 开发模式转换 WePY框架在开发过程中参考了Vue等现有框架的一些语法风格和功能特性，对原生小程序的开发模式进行了再次封装，更贴近于MVVM架构模式
- 项目配置需要注意，es6转es5，样式补全等处理需要关闭，由框架处理
- 使用第三方组件得使用基于wepy开发的
- 数据管理问题：组件之间可以使用框架方法，页面直接得使用发布订阅、global、wepy-redux之类的方法

[使用文档](https://tencent.github.io/wepy/document.html#/)


2. [mpvue](https://github.com/Meituan-Dianping/mpvue)
	
mpvue是美团团队开源的一款使用 Vue.js 开发微信小程序的前端框架。框架基于Vue.js核心，mpvue修改了Vue.js的runtime和compiler实现，使其可以运行在小程序环境中，从而为小程序开发引入了整套 Vue.js 开发体验。

特点：

- 彻底的组件化开发能力：提高代码复用性
- 完整的 Vue.js 开发体验
- 方便的 Vuex 数据管理方案：方便构建复杂应用
- 快捷的 webpack 构建机制：自定义构建策略、开发阶段 hotReload
- 支持使用 npm 外部依赖
- 使用 Vue.js 命令行工具 vue-cli 快速初始化项目
- H5 代码转换编译成小程序目标代码的能力

目录结构：
```
firstapp
├── package.json
├── project.config.json       
├── static            
├── src
│    ├── components
│    ├── pages
│    ├── utils
│    ├── App.vue
│    └── main.js
├── config
│   ├── index.js
│   ├── dev.env.js
│   └── prod.env.js
└── build

```

原理： 

![mpvue实现原理](https://bizimg.sogoucdn.com/201901/11/11/41/bizinput-pro-fe/2443851932-5b9a0870497c4_articlex.png)

- vuejs实例与小程序page实例建立关联
- 小程序与vuejs生命周期建立映射关系，能在小程序生命周期中触发 Vue.js 生命周期
- 小程序事件建立代理机制，在事件代理函数中触发与之对应的vuejs组件事件响应
- vue与小程序的数据同步

注意点：

- 支持微信小程序原生组件，事件处理方式需要改为vue方式
- 模板语法与小程序原生有部分差异
	- 小程序里所有的 BOM／DOM 都不能用，也就是说 v-html 指令不能用
	- 不支持部分复杂的 JavaScript 渲染表达式
	- 不支持过滤器 渲染部分会转成 wxml ，wxml 不支持过滤器，所以这部分功能不支持。
	- 不支持在 template 内使用 methods 中的函数
	- 暂不支持在组件上使用 Class 与 Style 绑定

- mpvue 除了 Vue 本身的生命周期外，还兼容了小程序生命周期，这部分生命周期钩子的来源于微信小程序的 Page， 除特殊情况外，不建议使用小程序的生命周期 钩子。
- 受制于 vue & 小程序自身实现和理念的不同，在处理数据更新页面渲染等方面会存在很多问题，而且浪费性能

[使用文档](http://mpvue.com/mpvue)

3. [taro](https://github.com/NervJS/taro)

京东凹凸实验室开源的一款使用 React.js 开发微信小程序的前端框架。它采用与 React 一致的组件化思想，组件生命周期与 React 保持一致，同时支持使用 JSX 语法，让代码具有更丰富的表现力，使用 Taro 进行开发可以获得和 React 一致的开发体验。,同时因为使用了react的原因所以除了能编译h5, 小程序外还可以编译为ReactNative

Taro 是一套遵循 React 语法规范的 多端开发 解决方案。现如今市面上端的形态多种多样，Web、React-Native、微信小程序等各种端大行其道，当业务要求同时在不同的端都要求有所表现的时候，针对不同的端去编写多套代码的成本显然非常高，这时候只编写一套代码就能够适配到多端的能力就显得极为需要。

使用 Taro，我们可以只书写一套代码，再通过 Taro 的编译工具，将源代码分别编译出可以在不同端（微信/百度/支付宝/字节跳动小程序、H5、React-Native 等）运行的代码。

特点：
 
- 支持使用 npm/yarn 安装管理第三方依赖
- 支持使用 ES7/ES8 甚至更新的 ES 规范，一切都可自行配置
- 支持使用 CSS 预编译器，例如 Sass 等
- 支持使用 Redux 进行状态管理
- 支持使用 Mobx 进行状态管理
- 小程序 API 优化，异步 API Promise 化等等
- 支持多端开发转化
- react 技术栈

目录结构：
```
├── config                 配置目录
|   ├── dev.js             开发时配置
|   ├── index.js           默认配置
|   └── prod.js            打包时配置
├── src                    源码目录
|   ├── components         公共组件目录
|   ├── pages              页面文件目录
|   |   ├── index          index 页面目录
|   |   |   ├── banner     页面 index 私有组件
|   |   |   ├── index.js   index 页面逻辑
|   |   |   └── index.css  index 页面样式
|   ├── utils              公共方法库
|   ├── app.css            项目总通用样式
|   └── app.js             项目入口文件
└── package.json
```

原理：

> 在一个优秀且严格的规范限制下，从更高抽象的视角（语法树）来看，每个人写的代码都差不多。

也就是说，对于微信小程序这样不开放不开源的端，我们可以先把 React 代码分析成一颗抽象语法树，根据这颗树生成小程序支持的模板代码，再做一个小程序运行时框架处理事件和生命周期与小程序框架兼容，然后把业务代码跑在运行时框架就完成了小程序端的适配。

对于 React 已经支持的端，例如 Web、React Native 甚至未来的 React VR，我们只要包一层组件库再做些许样式支持即可。鉴于时下小程序的热度和我们团队本身的业务侧重程度，组件库的 API 是以小程序为标准，其他端的组件库的 API 都会和小程序端的组件保持一致。

![](http://img30.360buyimg.com/uba/jfs/t22360/120/839096197/151922/229ceba4/5b1a6fcdNed7d4039.jpg)

注意点：

- 多终端转化只是理想情况而已，存在着许多转换问题，而且一旦发生问题，很难妥善解决，所以并不可靠



[使用文档](https://nervjs.github.io/taro/docs/README.html)

### 原生开发痛点
- 组件化支持能力太弱(217年11月开始支持)
- 不能使用 less、jade 等
- 无法使用 ES 高级语法
- request 并发次数限制 5次
- 一个页面对应4个文件，看的眼花缭乱
- 页面间数据通信，数据状态管理

## 技术选型

各种开发方式的对比


|  |微信小程序  | mpvue | wepy | Taro |
| --- | --- | --- | --- | --- |
| 语法规范 | 小程序规范 | vuejs规范 | 类vuejs规范 | React规范 |
| 模板系统 | 字符串模板 | 字符串模板 | 字符串模板 | JSX |
| 类型系统 | 不支持 | 业务代码 | 业务代码 | 业务代码 + JSX |
| 组件规范 | 小程序组件 | html标签+小程序组件 | 小程序组件 | 小程序组件 | 
| 样式规范 | wxss | sass,less,postcss | sass,less,styus | sass,less,postcss |
| 组件化 | 小程序组件化 | vue组件化规范 | 自定义组件化 | React组件化规范 |
| 多段复用 | 无 | 复用为h5 | 复用为h5  | 复用为h5 |
| 自动构建 | 无 | webpack构建 | 内建构建系统 | 内建构建系统 + webpack |
| 上手成本 | 全新学习 | 熟悉vuejs | 熟悉vuejs+wepy | 熟悉react |
| 数据流管理 | 不支持 | vuex  | redux | redux |

- 如果只需要做一个微信小程序则根据自己的擅长框架选择mpvue或taro
- 如果是当前老项目想像向程序迁移同时老项目又是使用vue开发,建议使用mpvue或wepy
- 如果是老项目使用react开发且需要部分迁移小程序,建议使用taro
- 如果是新项目且新项目需要同时支持微信小程序和支付宝小程序, 建议使用原生开发,因为目前框架的转译支付宝小程序支持并不是很好,且出了问题不好定位修改, 但如果是小demo不涉及太多逻辑的项目都可以使用框架作为尝鲜; 但如果是涉及太多交互逻辑的则不建议使用框架转译,由于支付宝小程序在视图层基本与小程序一致所以建议手动更改替换部分方法和全局替换一些属性或文件名,如wxml替换为axml这种, 手动转换都靠谱点 

选型问题可以参考这个[issue](https://github.com/Tencent/wepy/issues/813)


## 最佳实践

为什么需要第三方框架？
因为原生开发存在痛点，需要第三方框架来解决这些问题
但是第三方框架的不稳定性以及小程序生态本身的飞速发展，为第三方框架的使用带来了极大的风险。
最佳的微信小程序开发实践应该是无痛的，且舒服的，无痛的是指在小程序的飞速发展变更中，我们不用重复的浪费学习第三方框架和原生框架。舒服的是指，我们能用上我们熟悉的流行工程流，如：less 预编译、async/await 异步请求，redux数据管理等。

- 优化小程序API
  1. Promise化异步接口
  2. 突破请求数量限制（队列）
- 使用 async/await
- 接入Redux管理页面数据流
  1. 直接接入，添加可配置项
  2. 添加saga管理操作
- 样式书写采用 less预编译
  1. 使用Gulp或者webpack管理自动编译，持续集成
- 按需加载，子页面分包（除却tab页面的其他页面）
  1. 按功能模块分包加载（推荐）
  2. 按tab分包
  * ps: 小程序[原生分包](https://mp.weixin.qq.com/debug/wxadoc/dev/framework/subpackages.html)
- 资源自动化管理
  1. 上传 CDN


## 组件库推荐

 1. [weui-wxss](https://github.com/Tencent/weui-wxss)
 WeUI WXSS是腾讯官方UI组件库WeUI的小程序版，提供了跟微信界面风格一致的用户体验。
 2. [iView WeApp](https://github.com/TalkingData/iview-weapp)
 iView是TalkingData发布的一款高质量的基于Vue.js组件库，而iView weapp则是它们的小程序版本。
 3. [vant-weapp](https://github.com/youzan/vant-weapp)
 原生，有人开发了支持mpvue的版本，star不多
 4. [minui](https://github.com/meili/minui)
 MinUI 是蘑菇街前端开发团队开发的基于微信小程序自定义组件特性开发而成的一套简洁、易用、高效的组件库，适用场景广，覆盖小程序原生框架，各种小程序组件主流框架等，并且提供了专门的命令行工具。
 
使用mpvue框架时，可以在框架的配置中进行配置
wepy和taro使用组件需要以他们的规范进行开发，所以相应选择较小