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


前端面试会经常问一些js基础的手写题，如防抖节流，promise实现等等，需要经常查看与巩固
<!--more-->

### call的实现
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