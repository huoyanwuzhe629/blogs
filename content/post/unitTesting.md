---
date: 2018-08-09
title: "nodejs单元测试"
tags: [
    "nodejs",
    "单元测试"
]
categories: [
    "单元测试"
]
---

## 为什么需要单元测试

代码部署之前，进行一定的单元测试是十分必要的，这样能够有效并且持续保证代码质量。而实践表明，高质量的单元测试还可以帮助我们完善自己的代码。
<!--more-->

所谓单元测试，就是对于某个函数或者API进行正确性测试，比如：

```
	function add(a,b) {
		return a + b;
	}
	
	> add = function(a, b){return a + b}
		[Function: add]
	> add(1)
	NaN
```

当add函数仅给定一个参数1的时候，a为1，b为undefined，两者相加为NaN。

这时候问题来了：

- 你考虑过只有一个参数的情形么？
- 一个参数时，返回的NAN是你要的么？
- 如果参数的类型有没有要求？

这时候就需要加单元测试来验证各种可能性

写代码的时候容易陷入思维漏洞，而在写测试用例时，容易考虑到各种情况，而且就算暂时没有考虑到，过后加入测试用例，以方便后续的维护，降低修改代码的风险

意义：

- 验证代码的正确性
- 避免修改代码时出错
- 避免其他团队成员修改代码时出错
- 便于自动化测试和部署

## 测试方法

### 测试框架

这里推荐使用Mocha，Mocha是一个功能丰富的Javascript测试框架，它能运行在Node.js和浏览器中，支持BDD、TDD、QUnit、Exports式的测试。这里以BDD为例为大家做示例。

#### 安装

```
npm install mocha -g
```

#### 编写业务代码

简单的返回绝对值的方法

```
exports.absoluteValue = function (num) {
  if (num < 0) {
    return 0-num;
  }
  return num;
};
```
#### 编写测试脚本

在目录新建test文件夹，存放所有测试用例文件，新建index.test.js,后缀名需要为*.test.js*(表示测试)或者*.spec.js*（表示规格）

```
// index.test.js
var lib = require('../index');

describe('绝对值函数的测试', function () {
  describe('absoluteValue', function () {
    it('方法能运行', function () {
      lib.absoluteValue(10);
    });
  });
});
```

其中describe块称为"测试套件"（test suite），表示一组相关的测试。它是一个函数，第一个参数是测试套件的名称（"绝对值函数的测试"），第二个参数是一个实际执行的函数。

it块称为"测试用例"（test case），表示一个单独的测试，是测试的最小单位。它也是一个函数，第一个参数是测试用例的名称（"方法能运行"），第二个参数是一个实际执行的函数。

测试脚本里面应该包括一个或多个describe块，每个describe块应该包括一个或多个it块。
Mocha的作用是运行测试脚本。但这只是运行了代码，并没有对结果进行检查。

#### 断言库

对代码进行检查的话，就需要用到断言库了，nodejs常用断言库有：

- should.js
- expect.js
- chai

这里以should为例

##### 加上断言

```
it('10的绝对值等于-10的绝对值', function () {
	lib.absoluteValue(-10).should.be.equal(lib.absoluteValue(10))
});
```

#### 后续维护

后续在整个项目的迭代过程中，只要这个用例能正确执行，就能保证你的改动没有对你原有的功能造成破坏，这时候你只要为你的新需求编写新的测试用例即可，这就是测试用例的价值所在。


#### 异步测试

在为服务的项目写测试用例时，需要测试异步回调的情况

Mocha默认每个测试用例最多执行2000毫秒，如果到时没有得到结果，就报错。对于涉及异步操作的测试用例，这个时间往往是不够的，需要用-t或--timeout参数指定超时门槛，或者使用api式，this.timeout(2000)来设置超时时间

编写异步代码

```
exports.async = function (callback) {
  setTimeout(function () {
    callback(10);
  }, 10);
};
```

测试异步代码

```
describe('异步回调的测试', function () {
  it('回调的参数为10', function (done) {
    lib.async(function (result) {
      result.should.be.equal(10);
      done();
    });
  });
});
```

上面的测试用例里面，有一个done函数。it块执行的时候，传入一个done参数，当测试结束的时候，必须显式调用这个函数，告诉Mocha测试结束了。否则，Mocha就无法知道，测试是否结束，会一直等到超时报错。


#### 测试promise

使用should提供的promise断言接口

- finally | eventually
- fulfilled
- fulfilledWith
- rejected
- rejectedWith
- then

直接上测试代码

```
describe('promise测试', function () {
  it('should.reject', function () {
    (new Promise(function (resolve, reject) {
      reject(new Error('wrong'));
    })).should.be.rejectedWith('wrong');
  });

  it('should.fulfilled', function () {
    (new Promise(function (resolve, reject) {
      resolve({ username: 'jc', age: 18, gender: 'male' })
    })).should.be.fulfilled().then(function (it) {
      it.should.have.property('username', 'jc');
    })
  });
});
```

#### 异常测试

在开发web项目时，我们可能对异常不太重视，而开发node服务时，我们需要对异常进行处理，所以针对异常的测试就十分必要了

下面有一个*getContent*方法，他会读取指定文件的内容，但是不一定成功，会抛出异常

我们去人为的制造读取失败的情况有点太麻烦了，这时候应该模拟错误环境

手写mock

```
describe("getContent", function () {
  var _readFile;
  before(function () {
    _readFile = fs.readFile;
    fs.readFile = function (filename, encoding, callback) {
      process.nextTick(function () {
        callback(new Error("mock readFile error"));
      });
    };
  });
  // it();
  after(function () {
    // 用完之后记得还原。否则影响其他case
    fs.readFile = _readFile;
  })
});
```
上面先把fs.readFile这个方法替换成一个必然会报错的fuction，执行完测试用例，再还原，很巧妙，但是稍显麻烦

Mock库：muk
优美点的写法：

```
var fs = require('fs');
var muk = require('muk');

before(function () {
  muk(fs, 'readFile', function(path, encoding, callback) {
    process.nextTick(function () {
      callback(new Error("mock readFile error"));
    });
  });
});
// it();
after(function () {
  muk.restore();
});
```
原理是一样的，只是封装了下

#### 测试私有方法

有些方法是私有方法，测试脚本不能把他们导出来进行测试,我不可能为了测试临时export出来，完事再改回去

```
function _adding(num1, num2) {
  return num1 + num2;
}
```

我们可以通过rewire模块把这个方法在测试代码中导出来

```
describe('私有模块测试', function () {
  it('limit should return success', function () {
    var lib = rewire('../index.js');
    var add = lib.__get__('_adding');
    add(10,2);
  });
});
```

#### 测试web应用
开发web项目时，需要测某个api，比如：*/getUser.action*
可以使用*supertest*模块来处理这种需求：

```
var express = require("express");
var request = require("supertest");
var app = express();

// 定义路由
app.get('/getUser.action', function(req, res){
  res.send(200, { name: 'xs' });
});

describe('GET /getUser.action', function(){
  it('respond with json', function(done){
    request(app)
      .get('/user')
      .set('Accept', 'application/json')
      .expect('Content-Type', /json/)
      .expect(200)
      .end(function (err, res) {
        if (err){
          done(err);
        }
        res.body.name.should.be.equal('xs');
        done();
      })
  });
});
```

#### 覆盖率

虽然我们可能写了不少测试用例，但是是否覆盖了所有的代码呢？这个指标就叫做*代码覆盖率*，有四个测量维度：

- 行覆盖率：执行了多少行
- 函数覆盖率：执行了多少函数
- 分支覆盖率：是否每个if代码块都执行了
- 语句覆盖率：每个语句都执行了么

我们使用*istanbul*来测试代码覆盖率

安装：

```
$ npm install -g istanbul
```
编写完测试用例之后，执行命令：
```
istanbul cover _mocha
```
也可以编写npm scripts来执行，这样就不用全局安装*istanbul*了
控制台会显示测试情况以及代码覆盖率情况，就是上面说的4个指标

同时，还会生成一个*coverage*子目录，其中的*coverage.json*文件包含覆盖率的原始数据，*coverage/lcov-report*是可以在浏览器打开的覆盖率报告，其中有详细信息，可以查看代码的执行情况。

需要注意的是，上面执行cover后面跟的是*_mocha*，而不是*mocha*，因为这是两个指令，前者是在当前进程（即istanbul所在的进程）执行测试，后者是另起一个进程，只有在同一个进程，istanbul才能捕捉代码执行情况。

如果需要往*mocha*中传入参数，在后面加上”--“即可，否则会当成*istanbul*的参数

```
$ istanbul cover _mocha -- tests/test.sqrt.js -R spec
```

#### 持续集成

一些大型的开源项目可能需要引入持续集成，在push代码之后自动执行test脚本，通过则build-passing，否则build-failing

使用[Travis-cli](https://travis-ci.org/)，有以下几步：

- 绑定Github账号
- 在Github仓库的Admin打开Services hook
- 打开Travis
- 每次push将会hook触发执行npm test命令

需要在根目录下加入*.travis.yml*文件：

```
language: node_js
node_js:
  - "8.9.0"
```
没有此文件的话会默认视为*ruby*项目


## 单元测试度的把握

进行单元测试的过程中，很难把控“度”，测试范围太小，有点没有必要，测试范围太大，会涉及别人的工作内容，面面俱到工作量太大，以点概面又容易忽略问题，所有团队内需要一份通用的[单元测试准则](https://petroware.no/unittesting.html)

## 总结

- 框架：mocha
- 断言库：should.js、expect.js、chai
- 覆盖率：istanbul、jscover、blanket
- mock库：muk
- 测试私有方法：rewire
- web测试：supertest
- 持续集成：Travis-cli



