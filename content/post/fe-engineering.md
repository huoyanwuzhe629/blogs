---
date: 2018-07-18
title: "前端工程化之代码规范化及测试规范化"
tags: [
    "nodejs",
    "eslint",
    "mocha"
]
categories: [
    "前端工程化"
]
---


前端开发项目工程复杂度越来越高，需要用一些规范来保证经手开发人员较多之后，扔能保证相当的可维护性与稳定性，这就需要项目代码保持稳定的规范和质量，因此，引入代码规范和单元测试就十分必要了。
<!--more-->

## 代码规范

### eslint用法

先全局安装eslint

```
 npm i eslint -g
```

然后初始化eslint

```
 eslint --init
```

选择好遵守的规范，配置文件类型（js,json,yaml），会在项目中安装好*eslint*，*eslint-config-airbnb*，*eslint-plugin-import*，*eslint-plugin-jsx-a11y*, *eslint-plugin-react*等包，*eslint-config-airbnb*是airbnb规范的配置包，*eslint-plugin-react*是react相关包。

eslint的配置文件中需要进行配置，以js类型的配置文件*.eslintrc.js*为例：

```javascript
module.exports = {
  "extends": "airbnb",//继承Airbnb规范
  "env": {            //运行环境node，使用es6规范
    "node": true,
    "es6": true
  },
  "rules": {          //自定义配置，会覆盖Airbnb规范
    "no-console": "off", 
    // 每条规则有三个选项 0 关闭，1 违反该规则抛出警告，2 违反该规则抛出错误
    "guard-for-in": "off",
    "no-restricted-syntax": "off"
  }
};
```
具体每一项配置代表的意思见[eslint中文文档](http://eslint.cn/docs/rules/)
带黄色扳手的规则，是可以通过--fix自动修复的

- 执行```eslint *路径*```即可检验代码规范，加上--fix可自动修复部分规范
- 可以在npm中的script中加上一条eslint的脚本
- 也可以使用vscode，并安装eslint插件，可以直接下面的问题页面报错
- 可以配置.eslintignore文件来排除对部分路径文件或文件夹的规则校验，但是使用eslint指令强行校验仍然会生效，还可以加上no-ignore配置


## 单元测试

### mocha

### Istanbul