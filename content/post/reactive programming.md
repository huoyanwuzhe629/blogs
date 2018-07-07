---
date: 2018-07-07
title: "响应式编程入门"
tags: [
    "JavaScript",
    "reactive programming"
]
categories: [
    "reactive programming"
]
---

## 什么是响应式编程

> 响应式编程就是用异步数据流进行编程

即使是最典型的点击事件也是一个异步事件流，从而可以对其进行侦测（observe）并进行相应操作。

可以基于任何东西创建数据流。流非常轻便，并且无处不在，任何东西都可以是一个流：变量，用户输入，属性，缓存，数据结构等等。例如，想象一下微博推文也可以是一个数据流，和点击事件一样。你可以对其进行侦听，并作相应反应。

在用户界面编程领域以及基于实时系统的动画方面都有广泛的应用。另一方面，在处理嵌套回调的异步事件，复杂的列表过滤和变换的时候也都有良好的表现。

<!--more-->

## 数据流

让我们首先来想象一个很常见的交互场景。当用户点击一个页面上的按钮，程序开始在后台执行一些工作（例如从网络获取数据）。在获取数据期间，按钮不能再被点击，而会显示成灰色的”disabled”状态。当加载完成后，页面展现数据，而后按钮又可以再次使用。

```javascript
var loading = false;

$('.load').click(function () {
  loading = true;

  var $btn = $(this);

  $btn.prop('disabled', loading);
  $btn.text('Loading ...');

  $.getJSON('https://www.reddit.com/r/cats.json')
    .done(function (data) {
      loading = false;
      $btn.prop('disabled', loading);
      $btn.text('Load');

      $('#result').text("Got " + data.data.children.length + " results");
    });
});
```

用图来描述其中的状态变化过程

![Alt text](/image/reactive_programming_images/clickState.png)

如果用户点击很多次的按钮的话，那么loading的值的变化将是这样的。

```javascript
loading: false -> true -> false -> true -> false -> true -> ...
```
loading其实就是应用程序的状态。上面的用箭头组成的示意图仅仅是我们对状态变化的一种展现形式（或者说建模）。然而，我们其实还可以用更加简单的模型来表现它—— 数组。

### 仅仅是数组么？

如果说loading变化的过程就是一个数组，那么不妨把它写作：

```javascript
var loadingProcess = [false, true, false, true, false, ...]
```
按钮的disabled状态的变化过程和loadingProcess的变化过程是一模一样的。我们将disabled的变化过程命名为disabledProcess

```javascript
var disabledProcess = [false, true, false, true, false, ...]
```
根据loadingProcess来获取disabledProcess

```javascript
var textProcess = loadingProcess.map(function(loading) {
    return loading ? "Loading ..." : "Load"
});
```

有了disabledProcess和textProcess 来更新ui
```javascript
disabledProcess.forEach(function (disabled) {
    $btn.prop('disabled', disabled);
});
textProcess.forEach(function (text) {
    $btn.text(text);
});
```

这个变换的过程看起来就像下图

![Alt text](/image/reactive_programming_images/processFlow.png)

但是有个问题，这些状态并不是一开始就全部知道，并且放在数组中的，还有个很重要的元素，时间！

### 加入时间
回过头来看loadingProcess是如何得出的？当用户触发按钮的点击事件的时候，loadingProcess会被置为false；而当HTTP请求完成的时候，我们将其置为true。在这里，用户触发点击事件，和HTTP请求完成都是一个需要时间的过程。用户的两次点击之间必定要有时间，这样把一个个点击事件放入数组中就十分奇怪

```javascript
var clickEventProcess = [ clickEvent, clickEvent, clickEvent, clickEvent, clickEvent, ... ]
```
如果去掉时间因素，上面这种的写法可能就是

```javascript
// 代码A
clickEventProcess.forEach(function (clickEvent) {
   // ... 
});
```

而其实我们真正的代码是

```javascript
// 代码B
document.querySelector('.load').addEventListener('click', function (clickEvent) {
    // ...
});
```

大家都知道，一个是迭代器模式，一个是观察者模式，而加入时间之后的数组，即clickEventProcess ，可以理解为数据流

##Observable
迭代器模式和观察者模式本质上是对称的。它们相同的地方在于：

 - 都是对集合的遍历
 - 每次都只获得一个元素

他们完全相反的地方只有一个：迭代器模式是你主动去要数据，而观察者模式是数据的提供方把数据推给你

我们改写代码

```javascript
// 代码B
clickEventProcess.forEach = function(fn) {
    this._fn = fn; 
};

clickEventProcess.onNext = function(clickEvent) {
    this._fn(clickEvent);  
};

document.querySelector('.load').addEventListener('click', function (clickEvent) {
    clickEventProcess.onNext(clickEvent);
});

clickEventProcess.forEach(function (clickEvent) {
   // ... 
});
```
1. 接受一个回调函数作为参数，并存储在this._fn里面。这是为了将来在clickEventProcess.onNext里面调用
2. 当clickEvent触发的时候，调用clickEventProcess.onNext(clickEvent)，将clickEvent传给了clickEventProcess
3. clickEventProcess.onNext将clickEvent传给了this._fn，也就是之前我们所存储的回调函数
4. 回调函数正确地接收到新的点击事件

我们最后获得了一个新的clickEventProcess，它不是一个真正意义上的集合，却被我们抽象成了一个集合，一个被时间所间隔开的集合。 Rx.js，也称作Reactive Extension提供给了抽象出这样集合的能力，它把这种集合命名为Observable（可观察的）

Observable 实际上是应用了观察者模式和迭代器模式的事件或者说消息序列

Observable可以被订阅(subscribe)，随后会将数据push给所有订阅者(subscribers)。

你可能在处理异步操作的时候，会应用到Promise这个技术。那么Observable和Promise相比，又有什么区别呢？

- Observable是不可变的，这也是函数式编程的思想。你每次需要获取新的序列的时候，都需要利用函数操作对其做变换，这也避免了无意中修改数据造成的Bug(这点与旭日以前的发布订阅不同，会生成新的数据流)
- 我们知道Promise对象一旦生成并触发后，是不可以取消的，而Observable是可以，这也提供了一些灵活性。同时，当你需要共享变量的时候，Observable是可以组合使用的。
- Promise每次只能返回一个值，而Observable可以返回多值。

因为Observable目前还未成为ECMAScript标准，因此有各种它的实现。如RxJS、Rx、XStream、Most.js。RxJS之于Observable，就如同Bluebird之于Promise

>Observables are lazy Push collections of multiple values.
>They fill the missing spot in the following table:
>
> ![Alt text](/image/reactive_programming_images/pullAndPush.png)

这里pull指的是消费者主动去获取数据
push指的是生产者主动推送数据

### 以Rxjs的方式来处理问题
只需要很简单的一句工厂函数（factory method）就可以将鼠标点击的事件抽象成一个Observable。Rx.js提供一个全局对象Rx，Rx.Observable就是Observable的类。

```javascript
var loadButton = document.querySelector('.load');
var resultPanel = document.getElementById('result');

var click$ = Rx.Observable.fromEvent(loadButton, 'click');
```
click$就是前面的clickEventProcess，点击事件是像下面这样子的：

```javascript
[click ... click ........ click .. click ..... click ..........]
```

每个点击事件后应该发起一个网络请求。

```javascript
var response$$ = click$.map(function () {
   // 为了不处理跨域问题，这里换了个地址，返回和前面是一样的
   return Rx.DOM.get('http://output.jsbin.com/tafulo.json');
});
```

Rx.DOM.ajax.get会发起HTTP GET请求，并返回响应（Response）的Observable。因为每次请求只会有一个响应，所以响应的Observable实际上只会有一个元素。它将会是这样的：

```
[...[.....response].......[........response]......[....response]...........[....response]......[....response]]
```
由于这是Observable的Observable，就好像二维数组一样，所以在变量名末尾是$$。 若将click$和response$$的对应关系勾勒出来，会更加清晰。
![Alt text](/image/reactive_programming_images/clickAndResProcess.png)

然而，我们更希望的是直接获得Response的Observble，而不是Response的Observble的Observble。Rx.js提供了.flatMap方法，可以将二维的Observable“摊平”成一维。
![Alt text](/image/reactive_programming_images/flatternProcess.png)

对于每一个click事件，我们都想将loading置为true；而对于每次HTTP请求返回，则置为false。于是，我们可以将click$映射成一个纯粹的只含有true的Observable，但其每个true到达的事件都和点击事件到达的时间一样；对于response$，同样，将其映射呈只含有false的Observable。最后，我们将两个Observable结合在一起（用Rx.Observable.merge），最终就可以形成loading$，也就是刚才我们的loadingProcess。
此外，$loading还应有一个初始值，可以用startWith方法来指定。

```javascript
var loading$ = Rx.Observable.merge(
    click$.map(function () { return true; }),
    response$.map(function () { return false; })
).startWith(false);
```
![Alt text](/image/reactive_programming_images/clickAndRes&Loading.png)

有了loading$之后，我们很快就能得出刚才我们所想要的textProcess和enabledProcess。enabledProcess和loading$是一致的，就无需再生成，只要生成textProcess即可（命名为text$）。

```javascript
var text$ = loading$.map(function (loading) {
    return loading ? 'Loading ...' : 'Load';
});
```

在Rx.js中没有forEach方法，但有一个更好名字的方法，和forEach效用一样，叫做subscribe。这样我们就可以更新按钮的样式了。

```javascript
text$.subscribe(function (text) {
  $loadButton.text(text);
});
loading$.subscribe(function (loading) {
  $loadButton.prop('disabled', loading);
});

// response$ 还可以拿来更新#result的内容
response$.subscribe(function (data) {
  $resultPanel.text('Got ' + JSON.parse(data.response).data.children.length + ' items');
});
```
响应式重构之后的代码

```javascript
var $loadButton = $('.load');
var $resultPanel = $('#result');

var click$ = Rx.Observable.fromEvent($loadButton, 'click');
var response$ = click$.flatMap(function () {
  // 为了不处理跨域问题，这里换了个地址，返回和前面是一样的
   return Rx.DOM.get('http://output.jsbin.com/tafulo.json');
});
var loading$ = Rx.Observable.merge(
    click$.map(function () { return true; }),
    response$.map(function () { return false; })
).startWith(false);
var text$ = loading$.map(function (loading) {
    return loading ? 'Loading ...' : 'Load';
});


text$.subscribe(function (text) {
  $loadButton.text(text);
});
loading$.subscribe(function (loading) {
  $loadButton.prop('disabled', loading);
});

response$.subscribe(function (data) {
  $resultPanel.text('Got ' + JSON.parse(data.response).data.children.length + ' items');
});
```
在我们重构后的方案中，消灭了所有的状态。状态都被Observable抽象了出去。于是，这样的代码如果放在一个函数里面，这个函数将是没有副作用的纯函数。

Observable作为对状态的抽象，统一了Iterative和Reactive，淡化了两者之间的边界。当然，最大的好处就是我们用抽象的形式将烦人的状态赶出了视野，取而代之的是可组合的、可变换的Observable。

> 事物之间的对立统一通常很难找到。实际上，即使是在《设计模式》这本书中，作者们也未曾看到迭代器模式和观察者模式之间存在的对称关系。在UI设计领域，我们更多地和用户驱动、通信驱动出来的事件打交道，这才促成了这两个模式的合并。


## Demo
具体的api和小demo大家自己参考以下两篇文章，我讲不动了
[Observable与RxJS](https://github.com/malash/frp-introduction/blob/master/docs/01-observable-and-rxjs.md#observablefromevent)
[The introduction to Reactive Programming you've been missing](https://gist.github.com/staltz/868e7e9bc2a7b8c1f754)

## 总结
- 首先要理解响应式编程的思想 => 万事万物皆为流
- 为了较好的管理事件队列，响应式编程组合了观察者模式和迭代器模式，并且提供了操作集合的函数式编程方法
	- 其中的操作集合使用了函数式编程，就是为了保持数据流的不变，减少副作用
- 这是一种面向数据流和变化传播的编程范式，数据更新是相关联的。比如很多时候，在写界面的时候，我们需要对事件做处理，伴随着前端事件的增多，对于事件的处理愈发需要更加方便的处理。