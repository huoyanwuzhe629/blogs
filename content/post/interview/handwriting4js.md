---
date: 2021-12-10
title: "前端基础面试手写题"
tags: [
    "javascript",
    "面试"
]
categories: [
    "面试"
]
---


前端面试会经常问一些js基础的手写题，如防抖节流，promise实现等等，需要经常查看与巩固。
<!--more-->

### 1. call的实现
- 第一个参数为null或者undefined时，this指向全局对象window，值为原始值的指向该原始值的自动包装对象，如 String、Number、Boolean
- 为了避免函数名与上下文(context)的属性发生冲突，使用Symbol类型作为唯一值
- 将函数作为传入的上下文(context)属性执行
- 函数执行完成后删除该属性
- 返回执行结果

```
Function.prototype.myCall = function(context,...args){
  let cxt = context || window;
  //将当前被调用的方法定义在cxt.func上.(为了能以对象调用形式绑定this)
  //新建一个唯一的Symbol变量避免重复
  let func = Symbol() 
  cxt[func] = this;
  args = args ? args : []
  //以对象调用形式调用func,此时this指向cxt 也就是传入的需要绑定的this指向
  const res = args.length > 0 ? cxt[func](...args) : cxt[func]();
  //删除该方法，不然会对传入对象造成污染（添加该方法）
  delete cxt[func];
  return res;
}
```

### 2. apply的实现
- 前部分与call一样
- 第二个参数可不传，为数组

```
Function.prototype.apply = function(context, args) {
  const ctx = context || window;
  const fn = new Symbol();
  ctx[fn] = this;
  const res = ctx[fn](...args);
  delete ctx[fn];
  return res;
}
```

### 3. bind的实现
需要考虑：

- bind除了this之外，还可以传入多个参数
- bind返回的是个函数，也可以传入多个参数
- 新函数可能被当做构造函数调用
- 函数可能有返回值

实现方法：

- bind方法不会立即执行，需要返回一个待执行的函数
- 要实现作用域的绑定（apply）
- 注意apply的传递参数格式（数组传参）
- 当作为构造函数时，进行原型继承

```
Function.prototype.myBind = function (context, ...args) {
  if (typeof this !== 'function') {
    throw new Error('type error');
  }
  const fn = this;
  const args = args ? args : [];
  return function F(...newFnArgs) {
    const conbineArgs = [...args, ...newFnArgs];
    // 因为返回了一个函数，我们可以 new F()，所以需要判断使用了new的情况
    if (this instanceof F) {
      return new fn(...conbineArgs);
    }
    return fn.apply(context, conbineArgs);
  };
};
```
- 测试

```
let name = '小王',age =17;
let obj = {
    name:'小张',
    age: this.age,
    myFun: function(from,to){
        console.log(this.name + ' 年龄 ' + this.age+'来自 '+from+'去往'+ to)
    }
}
let db = {
    name: '德玛',
    age: 99
}

//结果
obj.myFun.myCall(db,'成都','上海');     // 德玛 年龄 99  来自 成都去往上海
obj.myFun.myApply(db,['成都','上海']);      // 德玛 年龄 99  来自 成都去往上海
obj.myFun.myBind(db,'成都','上海')();       // 德玛 年龄 99  来自 成都去往上海
obj.myFun.myBind(db,['成都test','上海'])();   // 德玛 年龄 99  来自 成都test, 上海去往 undefined
```

### 4. 继承 圣杯模式
```
function inherit(Target, Origin){
  function F() {} // 函数F作为一个中间层，上连father，下连Son，使两函数互不干扰
  F.prototype = Origin.prototype;
  Target.prototype = new F();
  Target.prototype.constructor = Target;
  // son原型归位
  Target.prototype.uber = Origin.prototype;
}
```

### 5. ES6 继承
```
//class 相当于es5中构造函数
//class中定义方法时，前后不能加function，全部定义在class的prototyte属性中
//class中定义的所有方法是不可枚举的
//class中只能定义方法，不能定义对象，变量等
//class和方法内默认都是严格模式
//es5中constructor为隐式属性
class People{
  constructor(name='wang',age='27'){
    this.name = name;
    this.age = age;
  }
  eat(){
    console.log(`${this.name} ${this.age} eat food`)
  }
}
class Woman extends People {
  constructor(name='wang', age='27') {
    super(name, age);
  }
  eat(){
    super.eat();
  }
}
let wonmanObj=new Woman('xiaoxiami'); 
wonmanObj.eat();
//es5继承先创建子类的实例对象，然后再将父类的方法添加到this上（Parent.apply(this)）。 
//es6继承是使用关键字super先创建父类的实例对象this，最后在子类class中修改this。
```