---
date: 2018-07-07
title: "nodejs异常处理"
tags: [
    "node",
    "exception"
]
categories: [
    "nodejs"
]
---

## 好的错误处理
- 出现错误时能将任务中断在一个合适的位置

    比如用户请求服务数据，服务在向其他服务请求或者查数据库时出问题，如果直接停在出问题的地方，用户就得一直等服务响应直至超时，我们应该通过合理的错误处理，返回一个错误响应，以让用户明白情况

- 能记录错误的摘要、调用栈及其他上下文

  我们的程序也需要在出现错误的情况下能够显示（或记录）一个错误的摘要、调用栈，以及其他的上下文。调用栈通常语言本身会提供，但很多时候仅有调用栈是不足以定位问题的，所以我们还需要去记录那些可能与这个错误有关的「上下文」，比如当时某几个关键的变量的值。对于一个服务器端项目，如果我们决定不向用户展示错误的详情，可能还需要为用户提供一个唯一的错误编号，以便用户事后反馈的时候我们可以根据编号还原当时的现场。
  
- 通过这些记录能够快速地发现和解决问题

<!--more-->

## 坏的错误处理
- 出现错误后程序崩溃退出
- 出现错误后 HTTP 请求无响应
- 出现错误后数据被修改了「一半」，出现不一致
- 出现错误后没有记录日志或重复记录
- 在日志中打印了错误但没有提供调用栈和上下文

## 层次化架构

controller service dataAccess
控制层 业务逻辑层 数据层

那么如果在这样一个复杂的层次化架构中，某个环节发生了错误怎么办？我们很可能会面临一个问题：我们在某一个层级可能没有足够的信息去决定如何处理这个错误。例如在 Data Access 层，一个数据库查询发生了错误，在 Data Access 这一层我们并不知道这个失败的查询对于更上层的业务逻辑意味着什么，而仅仅知道这个查询失败了。

所以我们需要有一种机制，将错误从底层不断地向上层传递，直到错误到达某个层级有足够的信息去决定如何处理这个错误。例如一个数据库查询的失败，根据不同的业务逻辑，可能会采取忽略、重试、中断整个任务这些完全不同的处理方式。

## 异常
异常让原本唯一的、正确的执行路径变得可以从任何一处中断，并进入一个所谓的「异常处理流程」

```
try {
  step1();
} catch (err) {
  console.error(err.stack);
}

function step1() {
  // ...
  step2()
  // ...
}

function step2() {
  if ( ... )
    throw new Error('some error');
}
```
在前面的例子中，我们定义了 step1 和 step2 两个函数，step1 调用了 step2，而 step2 中有可能抛出一个异常。我们仅需将对 step1 的调用放在一个 try 的语句块里，便可在后面的 catch 块中捕捉到 step2 抛出的异常，而不需要在 step1 和 step2 中进行任何处理 —— 即使它们再调用了其他函数。

这是因为异常会随着调用栈逆向地回溯，然后被第一个 catch 块捕捉到。这恰好符合我们前面提到的需求：在某个较底层（调用层次较深）的函数中我们没有足够的信息去处理这个错误，我们便不必在代码中特别地处理这个错误，因为异常会沿着调用栈回溯，直到某个层次有信息去处理这个异常，我们再去 catch, 一旦一个异常被 catch 了，便不会再继续回溯了（除非你再次 throw），这时我们称这个异常被处理了。

###如果没有异常

如果没有异常，每个函数都必须提供一种方式，告诉它的调用者是否有错误发生，在这里我们选择通过返回值的方式来表示错误，即如果返回空代表执行成功，返回了非空值则表示发生了一个错误。可以看到在每一次函数调用时，我们都需要去检查返回值来确定是否发生了错误，如果有错误发生了，就要提前中断这个函数的执行，将同样的错误返回。如果 step1 或 step2 中再去调用其他的函数，也需要检查每个函数的返回值 —— 这是一项非常机械化的工作，即使我们不去处理错误也必须手动检查，并在有错误时提前结束。


```
var err = step1();
if (err) console.error(err);

function step1() {
  // ...
  var err = step2();
  if (err) return 'step1: ' + err;
  // ...
}

function step2() {
  if ( ... )
    return 'step2: some error';
}
```

### 调用栈
语言内建的异常还提供了的一项非常有用的功能，打印err.stack，出现以下的结果

```
Error: some error
    at step2 (~/exception.js:14:9)
    at step1 (~/exception.js:9:3)
    at <anonymous> (~/exception.js:2:3)
```
跟我们平时网页开发遇到错误时的报错一样，调用栈中越靠上的部分越接近异常实际产生的位置，而下面的调用栈则会帮助我们的还原程序执行的路径。
babel编译之后，使用sourcemap使得调用栈显示源码位置(待研究)

## 抛异常
异常分两类：

 - 预期的异常： 比如参数不合法，前提条件不满足等
  通常是我们在代码中主动抛出的，目的是为了向调用者报告一种错误，希望外部的逻辑能够感知到这个错误，在某些情况下也可能是希望外部的逻辑能够给用户展示一个错误提示
 - 非预期的异常： JavaScript引擎运行时的异常
  非预期的异常通常说明我们的程序有错误或者考虑不周到，比如语法错误、运行时的类型错误。

主动抛异常注意事项：

- 总是抛出一个继承自 Error 的对象

  你应该总是抛出一个继承自 JavaScript 内建的 Error 类型的对象，而不要抛出 String 或普通的 Object, 因为只有语言内建的 Error 对象上才会有调用栈，抛出其他类型的对象将可能会导致调用栈无法正确地被记录
- 慎用自定义的异常类型

	慎重地使用自定义的异常类型，因为目前 JavaScript 中和调用栈有关的 API（如 Error.captureStackTrace）还不在标准中，各个引擎的实现也不同，你很难写出一个在所有引擎都可用的自定义异常类型。因此如果你的代码可能会同时运行在 Node.js 和浏览器中，或者你在编写一个开源项目，那么建议你不要使用自定义的异常类型；牛逼人物例外
- 可以直接向异常上附加属性来提供上下文

```
var err = new Error('Permission denied');
err.statusCode = 403;
throw err;

var err = new Error('Error while downloading');
err.url = url;
err.responseCode = res.statusCode;
throw err;
```
加上合适的上下文信息有利于外层逻辑定位问题，这一点在callback的第一个参数error也适用


## 异步任务
语言内建的异常是基于调用栈的，所以它只能在「同步」的代码中使用。
之前我们也讨论过，「异步」任务是通过所谓的「事件队列」来实现的，每当引擎从事件队列中取出一个回调函数来执行时，实际上这个函数是在调用栈的最顶层执行的，如果它抛出了一个异常，也是无法沿着调用栈回溯到这个异步任务的创建者的，所以你无法在异步代码中直接使用 try … catch 来捕捉异常。

nodejs中常见的异步类型：

- nodejs style callback
- Promise（co、async/await）
- EventEmitter（Stream）

nodejs style callback：

```
function copyFileContent(from, to, callback) {
  fs.readFile(from, (err, buffer) => {
    if (err) {
      callback(err);
    } else {
      try {
        fs.writeFile(to, buffer, callback);
      } catch (err) {
        callback(err);
      }
    }
  });
}

try {
  copyFileContent(from, to, (err) => {
    if (err) {
      console.error(err);
    } else {
      console.log('success');
    }
  });
} catch (err) {
  console.error(err);
}
```
每次回调中，我们都需要去检查 err 的值，如果发现 err 有值就代表发生了错误，那么需要提前结束，并以同样的错误调用 callback 来将错误传递给调用者。

然后在回调中的代码也必须要包裹在 try … catch 中来捕捉同步的异常，如果捕捉到了同步的异常，那么也需要通过 callback 将错误传递给调用者。这里是一个比较大的坑，很多人会忘记，但按照 Node.js style callback 的风格，一个函数既有可能同步地抛出一个异常，也有可能异步地通过 callback 报告一个错误，Node.js 标准库中的很多函数也是如此。

在使用这个 copyFileContent 时，我们也需要同时去捕捉同步抛出的异常和异步返回的错误，实际上这样导致了错误情况下的逻辑分散到了两处，处理起来很麻烦。

- 需要同时处理同步异常和异步回调
- 每次处理回调先检查err的值，有值则提前return
- 回调的代码也得捕捉同步异常
- 确保无论成功或者失败，callback要么被调用，要么同步的抛出异常

promise:

```
function copyFileContent(from, to) {
  return fs.readFile(from).then( (buffer) => {
    return fs.writeFile(to, buffer);
  });
}

Promise.try( () => {
  return copyFileContent(from, to);
}).then( () => {
  console.log('success');
}).catch( (err) => {
  console.error(err);
});
```
Pormise 的版本相比于前面的 Node.js style callback 要短了许多，主要是我们不需要在 copyFileContent 中处理错误了，而只需要去考虑正常的流程。fs.readFile、fs.writeFile 和 copyFileContent 的返回值都是一个 Promise, 它会帮助我们传递错误，在 Promise 上调用 .then 相当于绑定一个成功分支的回调函数，而 .catch 相当于绑定一个失败分支的错误处理函数，实际上我们的代码已经非常类似于语言内建的异常机制了。

但是得尽量避免手动创建Promise

```
function copyFileContent(from, to) {
  return new Promise( (resolve, reject) => {
    fs.readFile(from, (err, buffer) => {
      if (err) {
        reject(err);
      } else {
        try {
          fs.writeFile(to, buffer, resolve);
        } catch (err) {
          reject(err);
        }
      }
    });
  });
}
```
Promise 也有一个构造函数，通常用于将一段 Node.js style callback 风格的逻辑封装为 Promise, 在其中你需要手动在成功或失败的情况下调用 resolve 或 reject, 也需要手动处理 Node.js style callback 中各种琐碎的细节，十分容易出现疏漏，也麻烦

尽量用promise库提供的工具函数去调用callback风格代码

```
function copyFileContent(from, to) {
  return Promise.promisify(fs.readFile)(from).then( (buffer) => {
    return Promise.promisify(fs.writeFile)(to, buffer);
  });
}
```
或者直接用co/generator 和 async/await的方式

generator 提供了一种中断函数的执行而后再继续的能力，这种能力让它可以被用作异步流程控制：

```
var copyFileContent = co.wrap(function*(from, to) {
  return yield fs.writeFile(to, yield fs.readFile(from));
});

co(function*() {
  try {
    console.log(yield copyFileContent(from, to));
  } catch (err) {
    console.error(err);
  }
});
```
难理解，不太会用
而 async/await 则是基于 generator 的进一步优化，使代码更加简洁而且具有语义：

```
async function copyFileContent(from, to) {
  return await fs.writeFile(to, await fs.readFile(from));
}

try {
  console.log(await copyFileContent(from, to));
} catch (err) {
  console.error(err);
}
```
promise可以记录异步调用栈，因为所有异步任务的回调都被包裹在一个 .then 中，异步调用都是间接地通过 Promise 完成的，这给了 Promise 实现记录异步调用栈的机会
而在 Node.js style callback 中，我们是直接在使用调用者传递进来的 callback, 中间没有任何的胶合代码允许我们插入记录调用栈的逻辑，除非手动在每一次调用时去添加调用栈，这样便会对业务代码产生侵入式的影响

## EventEmitter 
Node.js 还有个 events 模块，提供了基于事件的异步流程控制机制

EventEmitter 提供了一种基于事件的通知机制，每个事件的含义其实是由使用者自己定义的，但它对于 error 事件却有一些特殊处理：如果发生了 error 事件，但却没有任何一个监听器监听 error 事件，EventEmiter 就会把这个错误直接抛出 —— 通常会导致程序崩溃退出。

标准库里的很多组件和一些第三方库都会使用 EventEmitter, 尤其是例如数据库这类的长链接，我们要确保监听了它们的 error 事件 —— 哪怕是打印到日志中。其实这里也比较坑，因为当我们在使用第三方库的时候，除非文档上写了，否则我们可能并不知道它在哪里用到了 EventEmitter（有的库可能有多个地方都用到了）。

Node.js 中的 Stream 也是基于 EventEmitter 的：

```
try {
  var source = fs.createReadStream(from);
  var target = fs.createWriteStream(to);

  source.on('error', (err) => {
    console.error(err);
  }).pipe(target).on('error', (err) => {
    console.error(err);
  });
} catch (err) {
  console.error(err);
}
```
在上面的例子中，我创建了一个读文件的流和一个写文件的流，并将读文件的流 .pipe 到写文件的流，实现一个复制文件内容的功能。我们一开始看到 pipe 这个函数，可能会以为它会将前面的流的错误一起传递给后面的流，然后仅需在最后加一个 error 事件的处理器即可。但其实不然，我们需要去为每一个流去监听 error 事件。

如果有异常没有捕捉到怎么样？如果有一个异常一直被传递到最顶层调用栈还没有被捕捉，那么就会导致进程的崩溃退出，不过我们还有大招：

```
process.on('uncaughtException', (err) => {
  console.error(err);
});

process.on('unhandledRejection', (reason, p) => {
  console.error(reason, p);
});
```

uncaughtException 事件可以捕捉到那些已经被抛出到最顶层调用栈的异常，一旦添加了这个监听器，这些异常便不再会导致进程退出。有些人认为程序一旦出现事先没有预料到的错误，就应该立刻崩溃，以免造成进一步的不可控状态，也为了提起开发人员足够的重视。但如果是服务器端程序，一个进程崩溃重启可能需要一分钟左右的时间，这段时间会造成服务的处理能力下降，也会造成一部分连接没有被正确地处理完成，这个后果很可能是更加严重的。

我们应当将在这个事件中捕捉到的错误视作非常严重的错误，因为在此时已经丢失了和这个错误有关的全部上下文，必然无法妥善地处理这个错误，唯一能做的就是打印一条日志，过后排查问题

unhandledRejection 事件可以捕捉到那些被 reject 但没有被添加 .catch 回调的 Promise

## 传递异常

当捕获的异常在当前层级不适宜处理时，应该向上传递，这里总结一些传递异常时的注意事项：

- 只处理已知的、必须在这里处理的异常，其他异常继续向外抛出

```
function writeLogs(logs) {
  return fs.writeFile('out/logs', logs).catch( (err) => {
    if (err.code === 'ENOENT') {
      return fs.mkdir('out').then( () => {
        return fs.writeFile('out/logs', logs);
      });
    } else {
      throw err;
    }
  });
}
```
- 不要轻易地丢弃一个异常

```
copyFileContent('a', 'b').catch( err => {
  // ignored
});
```
  最起码也得判断下异常再决定是否忽略
- 传递的过程中可以向 err 对象上添加属性，补充上下文

## 在程序边界处理异常
我们不要轻易地处理异常，而是让异常沿着调用栈向外层传递，在传递的过程中可能有一部分异常被忽略或以重试的方式被处理了，但还有一些「无法恢复」的异常被传递到了程序的「边界」，这些异常可能是预期的（无法成功执行的任务）或者非预期的（程序错误），所谓程序的边界可能是：

- Routers（对于服务端而言）
- UI Layer（对于网页应用而言）
- Command Dispatcher（对于命令行工具而言）

我们需要在程序的边界来处理这些错误，例如：

- 展示错误摘要
- 发送响应、断开 HTTP 连接（Web-backend）
- 退出程序（CLI Tools）
- 记录日志

因为这些错误最后被汇总到了一处，我们可以以一种统一的、健壮的方式去处理这些错误，比如以express服务为例

```
app.get('/', (req, res, next) => {
  copyFileContent(req.query.from, req.query.to).then( () => {
    res.send();
  }).catch(next);
});

app.use((err, req, res, next) => {
  err.userId = req.user.id;
  err.url = req.originalUrl;
  logger.error(err);
  res.status(err.statusCode || 500).send(err.message);
});
```
Express 是没有对 Promise 提供支持的，因此 Express 的中间件可以算是 Promise 代码的边界，我们需要手动地将异常传递给 Express 的 next, 以便进入到 Express 的错误处理流程。

Express 提供了一种错误处理中间件，在这里我们依然保留着有关 HTTP 连接的上下文，一个比较好的实践是在这里将 HTTP 连接所关联的用户、请求的 URL 等信息作为上下文附加到错误对象上，然后将错误记录到日志系统中，最后向客户端发送一个错误摘要。

## 小结
- 在层次化的架构中，很多时候在当前的层级没有足够的信息去决定如何处理错误，因此我们需要使用异常来将错误沿着调用栈逆向抛出，直到某个层级有足够的信息来处理这个错误。
- 在异步的场景下我们应该使用 Promise 或相兼容的流程控制工具来模拟异常机制。
- 传递异常时可以回滚数据或向其补充上下文，但如非必要，需要继续向外抛出。
- 让所有无法被恢复的错误传递到程序的「边界」处，统一处理。

## 未完成
日志的最佳实践