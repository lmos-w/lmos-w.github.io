---
title: JavaScript 的this
date: 2019-11-19 22:57:27
tags: this
categories: JavaScript
---
## 1\. `this`之谜

许多时候，`this`关键词对我以及许多刚起步的 JavaScript 程序员来说，都是一个谜。它是一种很强大的特性，但是理解它需要花不少功夫。
<!--more-->
对有 Java, PHP 或者其他常见的编程语言背景的人来说，[`this`](https://en.wikipedia.org/wiki/This_(computer_programming))仅仅被看成是类方法中当前对象的一个实例：不会多也不会少。多数时候，它不能在方法外被使用。正是这样一种简单的使用方法，避免了混淆。

在 JavaScript 中，`this`是当前执行函数的上下文。因为 JavaScript 有 4 种不同的函数调用方式：

*   函数调用: `alert('Hello World!')`
*   方法调用: `console.log('Hello World!')`
*   构造函数调用: `new RegExp('\\d')`
*   隐式调用: `alert.call(undefined, 'Hello World!')`

并且每种方法都定义了自己的上下文，`this`会表现得跟程序员预期的不太一样。同时，[strict 模式](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Strict_mode)也会影响函数执行时的上下文。

理解`this`的关键点就是要对函数调用以及它如何影响上下文有个清晰的观点。这篇文章将会着重于对函数调用的解释、函数调用如何影响`this`以及展示确定上下文时常见的陷阱。

在开始之前，让我们来熟悉一些术语：

*   **函数调用** 指执行构成一个函数的代码（简单说就是 call 一个函数）例如 `parseInt('15')`是`parseInt`函数**调用**.
*   **函数调用**的**上下文**指`this`在函数体中的值。
*   函数的**作用域**指的是在函数体内可以使用的变量、对象以及函数的集合。

## 2\. 函数调用

当一个表达式为函数接着一个`(`，一些用逗号分隔的参数以及一个`）`时，**函数调用**被执行。例如`parseInt('18')`。这个表达式不能是[属性访问](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/Property_accessors)，如`myObject.myFunction`，因为这会变成一个方法调用。举个例子，`[1,5].join(',')`**不是**一个函数调用，而是一个方法调用。

一个简单的函数调用例子:
```
<pre class="hljs javascript">function hello(name) {
    return 'Hello ' + name + '!';
}
// Function invocation
var message = hello('World');
console.log(message); // => 'Hello World!'</pre>
```
`hello('World')`是函数调用: `hello`表达式等价于一个函数，跟在它后面的是一对括号以及`'World'`参数。

更加高级的例子是 [IIFE](https://en.wikipedia.org/wiki/Immediately-invoked_function_expression) (立即调用的函数表达式):
```
<pre class="hljs javascript">var message = (function(name) {
   return 'Hello ' + name + '!';
})('World');
console.log(message) // => 'Hello World!'</pre>
```
IIFE 也是一个函数调用: 第一对括号`(function(name) {...})` 是一个等价于函数的表达式, 紧接着一对括号以及`'World'`参数: `('World')`。

### 2.1\. 在函数调用中的`this`

> `this` 在函数调用中是一个**全局对象**

全局对象是由执行的环境决定的。在浏览器里它是 [`window`](https://developer.mozilla.org/en-US/docs/Web/API/Window)对象。

在函数调用里，函数执行的上下文是全局对象。让我们一起看看下面函数里的上下文：
```
<pre class="hljs javascript">function sum(a, b) {
   console.log(this === window); // => true
   this.myNumber = 20; // add 'myNumber' property to global object
   return a + b;
}
// sum() is invoked as a function
// this in sum() is a global object (window)
sum(15, 16);     // => 31
window.myNumber; // => 20</pre>
```
在`sum(15, 16)`被调用的时候，JavaScript 自动设置`this`指向全局对象，也就是浏览器里的`window`。

当`this`在所有函数作用域以外 (最上层的作用域：全局执行的上下文) 调用时，它也指向全局对象：
```
<pre class="hljs coffeescript">console.log(this === window); // => true
this.myString = 'Hello World!';
console.log(window.myString); // => 'Hello World!'</pre>
```
* * *
```
<pre class="hljs xml"><!-- In an html file -->
<script type="text/javascript"> console.log(this === window); // => true </script></pre>
```
### 2.2\. 函数调用中的`this`, strict 模式

> strict 模式下，函数调用中的`this`是**`undefined`**

strict 模式在 [ECMAScript 5.1](http://www.ecma-international.org/ecma-262/5.1/#sec-10.1.1) 中被引入，它是一个受限制的 JavaScript 变种，提供了更好的安全性以及错误检查。为了使用它，把`'use strict'`放在函数体的开始。这个模式会影响执行的上下文，把`this`变成`undefined`。函数执行的上下文跟上面的例子 [2.1](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#21thisinfunctioninvocation) 相反，不再是全局对象

在 strict 模式下执行函数的例子:
```
<pre class="hljs javascript">function multiply(a, b) {
    'use strict'; // enable the strict mode
    console.log(this === undefined); // => true
    return a * b;
}
// multiply() function invocation with strict mode enabled
// this in multiply() is undefined
multiply(2, 5); // => 10</pre>
```
当`multiply(2, 5)`作为函数被调用时，`this`是`undefined`。

strict 模式不仅在当前作用域起作用，也会对内部的作用域起作用 (对所有在内部定义的函数有效)：
```
<pre class="hljs javascript">function execute() {
    'use strict'; // activate the strict mode
    function concat(str1, str2) {
        // the strict mode is enabled too
        console.log(this === undefined); // => true
        return str1 + str2;
    }
    // concat() is invoked as a function in strict mode
    // this in concat() is undefined
    concat('Hello', ' World!'); // => "Hello World!"
}
execute();</pre>
```
`'use strict'` 插入在`execute`函数体的一开始, 使它在`execute`函数的作用域内起作用。 因为`concat`定义在`execute`的作用域内, 它也会继承 strict 模式， 这导致调用`concat('Hello', ' World!')`时， `this`是`undefined`。

单个的 JavaScript 文件可能既包含 strict 模式又包含非 strict 模式。所以，在单个的脚本内，同样的调用方法可能有不同的上下文行为：
```
<pre class="hljs javascript">function nonStrictSum(a, b) {
    // non-strict mode
    console.log(this === window); // => true
    return a + b;
}
function strictSum(a, b) {
    'use strict';
    // strict mode is enabled
    console.log(this === undefined); // => true
    return a + b;
}
// nonStrictSum() is invoked as a function in non-strict mode
// this in nonStrictSum() is the window object
nonStrictSum(5, 6); // => 11
// strictSum() is invoked as a function in strict mode
// this in strictSum() is undefined
strictSum(8, 12); // => 20</pre>
```
### 2.3\. 陷阱: 内部函数中的`this`

一个函数调用中的常见错误就是以为`this`在内部函数中跟在外部函数中一样。 正确来说，内部函数的上下文依赖于调用方法，而不是外部函数的上下文。 为了能使`this`跟预期的一样，用隐式调用来修改内部函数的上下文 (用[`.call()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call)或者[`.apply()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply), 如 [5.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#5indirectinvocation) 所示) 或者创建一个绑定函数 (用[`.bind()`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_objects/Function/bind), 如 [6.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#6boundfunction) 所示）。

下面的例子计算了 2 个数字的和：
```
<pre class="hljs javascript">var numbers = {
   numberA: 5,
   numberB: 10,
   sum: function() {
     console.log(this === numbers); // => true
     function calculate() {
       // this is window or undefined in strict mode
       console.log(this === numbers); // => false
       return this.numberA + this.numberB;
     }
     return calculate();
   }
};
numbers.sum(); // => NaN or throws TypeError in strict mode</pre>
```
`numbers.sum()`是一个对象上的方法调用 (见 [3.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/3methodonanobjectinvocation))，所以`sum`中的上下文是`numbers`对象。`calculate`函数定义在`sum`内部，所以你会指望`calculate()`中的`this`也是`numbers`对象。然而，`calculate()`是一个函数调用（而**不是**方法调用），它的`this`是全局对象`window`(例子 [2.1.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#21thisinfunctioninvocation)) 或者 strict 模式下的`undefined`(例子 [2.2.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#22thisinfunctioninvocationstrictmode))。即使外部函数`sum`的上下文是`numbers`对象，它在这里也没有影响。`numbers.sum()`的调用结果是`NaN`或者 strict 模式下的`TypeError: Cannot read property 'numberA' of undefined`错误。因为`calculate`没有被正确调用，结果绝不是预期的`5 + 10 = 15`。

为了解决这个问题，`calculate`应该跟`sum`有一样的上下文，以便于使用`numberA`和`numberB`。解决方法之一是使用`.call()`方法 (见章节 [5.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#5indirectinvocation)):
```
<pre class="hljs javascript">var numbers = {
   numberA: 5,
   numberB: 10,
   sum: function() {
     console.log(this === numbers); // => true
     function calculate() {
       console.log(this === numbers); // => true
       return this.numberA + this.numberB;
     }
     // use .call() method to modify the context
     return calculate.call(this);
   }
};
numbers.sum(); // => 15</pre>
```
`calculate.call(this)`像往常一样执行`calculate`，但是上下文由第一个参数指定。现在`this.numberA + this.numberB`相当于`numbers.numberA + numbers.numberB`，函数会返回预期的结果`5 + 10 = 15`。

## 3\. 方法调用

一个**方法**是作为一个对象的属性存储的函数。例如:
```
<pre class="hljs javascript">var myObject = {
    // helloFunction is a method
    helloFunction: function() {
        return 'Hello World!';
    }
};
var message = myObject.helloFunction();</pre>
```
`helloFunction`是`myObject`的一个方法。为了使用这个方法, 使用属性访问：`myObject.helloFunction`。

当一个表达式以属性访问的形式执行时，执行的是**方法调用**，它相当于以个函数接着`(`，一组用逗号分隔的参数以及`)`。 利用前面的例子，`myObject.helloFunction()`是对象`myObject`上的一个`helloFunction`的方法调用。`[1, 2].join(',')` 或`/\s/.test('beautiful world')`也被认为是方法调用。

区分**函数调用** (见 [2.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#2functioninvocation)) 跟**方法调用**是很重要的，因为他们完全不同。他们最主要的区别在于方法调用要求函数以属性访问的形式调用 (如`<expression>.functionProperty()`或者`<expression>['functionProperty']()`)，而函数调用并没有这样的要求 (如`<expression>()`)。
```
<pre class="hljs javascript">['Hello', 'World'].join(', '); // method invocation
({ ten: function() { return 10; } }).ten(); // method invocation
var obj = {};
obj.myFunction = function() {
  return new Date().toString();
};
obj.myFunction(); // method invocation

var otherFunction = obj.myFunction;
otherFunction();     // function invocation
parseFloat('16.60'); // function invocation
isNaN(0);            // function invocation</pre>
```
### 3.1\. 方法调用中的`this`

> 在方法调用中，`this`是**拥有这个方法的对象**

当调用一个对象上的方法时，`this`变成这个对象自身。 让我们一起来创建一个对象，它带有一个可以增大数字的方法：
```
<pre class="hljs javascript">var calc = {
  num: 0,
  increment: function() {
    console.log(this === calc); // => true
    this.num += 1;
    return this.num;
  }
};
// method invocation. this is calc
calc.increment(); // => 1
calc.increment(); // => 2</pre>
```
调用`calc.increment()`会把`increment`函数的上下文变成`calc`对象。所以，用`this.num`来增加 num 这个属性跟预期一样工作。

javaScript 对象会从它的`prototype`继承方法。当这个继承的方法在新的对象上被调用时，上下文仍然是该对象本身：
```
<pre class="hljs javascript">var myDog = Object.create({
  sayName: function() {
     console.log(this === myDog); // => true
     return this.name;
  }
});
myDog.name = 'Milo';
// method invocation. this is myDog
myDog.sayName(); // => 'Milo'</pre>
```
[`Object.create()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object/create)创建了一个新的对象`myDog`，并且设置了它的 prototype。`myDog`继承了`sayName`方法。当执行`myDog.sayName()`时，`myDog`是调用的上下文。

在 ECMAScript 6 的 [`class`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Classes)语法中，方法调用的上下文也是这个实例本身：
```
<pre class="hljs javascript">class Planet {
  constructor(name) {
    this.name = name;
  }
  getName() {
    console.log(this === earth); // => true
    return this.name;
  }
}
var earth = new Planet('Earth');
// method invocation. the context is earth
earth.getName(); // => 'Earth'</pre>
```
### 3.2\. 陷阱: 从 object 中分离方法

一个对象中的方法可以赋值给另一个变量。当用这个变量调用方法时，你可能以为`this`指向定义这个方法的对象。

正确来说如果这个方法在没有对象的时候被调用，它会变成函数调用：`this`变成全局对象`window`或者 strict 模式下的`undefined`(见 [2.1](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#21thisinfunctioninvocation) 和 [2.2](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#22thisinfunctioninvocationstrictmode))。 用绑定函数 (用[`.bind()`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_objects/Function/bind), 见 [6.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#6boundfunction)) 可以修正上下文，使它变成拥有这个方法的对象。

下面的例子创建了`Animal`构造函数并创造了它的一个实例 - `myCat`。 `setTimout()`会在 1 秒钟之后输出`myCat`对象的信息：
```
<pre class="hljs javascript">function Animal(type, legs) {
    this.type = type;
    this.legs = legs;
    this.logInfo = function() {
        console.log(this === myCat); // => false
        console.log('The ' + this.type + ' has ' + this.legs + ' legs');
    }
}
var myCat = new Animal('Cat', 4);
// logs "The undefined has undefined legs"
// or throws a TypeError in strict mode
setTimeout(myCat.logInfo, 1000);</pre>
```
你可能会以为`setTimout`会调用`myCat.logInfo()`，输出关于`myCat`对象的信息。实际上，这个方法在作为参数传递给`setTimout(myCat.logInfo)`时已经从原对象上分离了，1 秒钟之后发生的是一个函数调用。当`logInfo`作为函数被调用时，`this`是全局对象，或者 strict 模式下的`undefined`（反正**不是**`myCat`对象），所以不会正确地输出信息。

函数可以通过[`.bind()`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_objects/Function/bind)方法跟一个对象绑定 (见 [6.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#6boundfunction))。如果这个分离的方法与`myCat`绑定，那么上下文的问题就解决了：
```
<pre class="hljs javascript">function Animal(type, legs) {
    this.type = type;
    this.legs = legs;
    this.logInfo = function() {
        console.log(this === myCat); // => true
        console.log('The ' + this.type + ' has ' + this.legs + ' legs');
    };
}
var myCat = new Animal('Cat', 4);
// logs "The Cat has 4 legs"
setTimeout(myCat.logInfo.bind(myCat), 1000);</pre>
```
`myCat.logInfo.bind(myCat)`返回一个跟`logInfo`执行效果一样的函数，但是它的`this`即使在函数调用情况下也是`myCat`。

## 4\. 构造函数调用

当 [`new`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Operators/new)关键词紧接着函数对象,`(`, 一组逗号分隔的参数以及`)`时被调用，执行的是**构造函数调用**如`new RegExp('\\d')`。

这个例子声明了一个`Country`函数，并且将它作为一个构造函数调用：
```
<pre class="hljs javascript">function Country(name, traveled) {
    this.name = name ? name : 'United Kingdom';
    this.traveled = Boolean(traveled); // transform to a boolean
}
Country.prototype.travel = function() {
    this.traveled = true;
};
// Constructor invocation
var france = new Country('France', false);
// Constructor invocation
var unitedKingdom = new Country;

france.travel(); // Travel to France</pre>
```
`new Country('France', false)`是`Country`函数的构造函数调用。它的执行结果是一个`name`属性为`'France'`的新的对象。 如果这个构造函数调用时不需要参数，那么括号可以省略：`new Country`。

从 ECMAScript 6 开始，JavaScript 允许用 [`class`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Classes)关键词来定义构造函数：
```
<pre class="hljs javascript">class City {
  constructor(name, traveled) {
    this.name = name;
    this.traveled = false;
  }
  travel() {
    this.traveled = true;
  }
}
// Constructor invocation
var paris = new City('Paris', false);
paris.travel();</pre>
```
`new City('Paris')`是构造函数调用。这个对象的初始化由这个类中一个特殊的方法 [`constructor`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/constructor)来处理。其中，`this`指向新创建的对象。

构造函数创建了一个新的空的对象，它从构造函数的原型继承了属性。构造函数的作用就是去初始化这个对象。 可能你已经知道了，在这种类型的调用中，上下文指向新创建的实例。这是我们下一章的主题。

当属性访问`myObject.myFunction`前面有一个`new`关键词时，JavaScript 会执行**构造函数调用**而**不是**原来的**方法调用**。例如`new myObject.myFunction()`：它相当于先用属性访问把方法提取出来`extractedFunction = myObject.myFunction`，然后利用把它作为构造函数创建一个新的对象： `new extractedFunction()`。

### 4.1\. 构造函数中的`this`

> 在构造函数调用中`this`指向**新创建的对象**

构造函数调用的上下文是新创建的对象。它利用构造函数的参数初始化新的对象，设定属性的初始值，添加时间处理函数等等。

让我们来看看下面例子里的上下文：
```
<pre class="hljs javascript">function Foo () {
    console.log(this instanceof Foo); // => true
    this.property = 'Default Value';
}
// Constructor invocation
var fooInstance = new Foo();
fooInstance.property; // => 'Default Value'</pre>
```
`new Foo()`正在调用一个构造函数，它的上下文是`fooInstance`。其中，`Foo`被初始化了：`this.property`被赋予了一个默认值。

同样的情况在用 [`class`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes)语法（从 ES6 起）时也会发生，唯一的区别是初始化在`constructor`方法中进行：
```
<pre class="hljs javascript">class Bar {
    constructor() {
        console.log(this instanceof Bar); // => true
        this.property = 'Default Value';
    }
}
// Constructor invocation
var barInstance = new Bar();
barInstance.property; // => 'Default Value'</pre>
```
当`new Bar()`执行时，JavaScript 创建了一个空的对象，把它作为`constructor`方法的上下文。现在，你可以用`this`关键词给它添加属性：`this.property = 'Default Value'`。

### 4.2\. 陷阱: 忘了`new`

有些 JavaScirpt 函数不是只在作为构造函数调用的时候才创建新的对象，作为函数调用时也会，例如`RegExp`：

<pre class="hljs javascript">var reg1 = new RegExp('\\w+');
var reg2 = RegExp('\\w+');

reg1 instanceof RegExp;      // => true
reg2 instanceof RegExp;      // => true
reg1.source === reg2.source; // => true</pre>

当执行`new RegExp('\\w+')`和`RegExp('\\w+')`时，JavaScrit 会创建相同的正则表达式对象。

因为有些构造函数在`new`关键词缺失的情况下，可能跳过对象初始化，用函数调用创建对象会存在问题（不包括[工厂模式](http://javascript.info/tutorial/factory-constructor-pattern)）。 下面的例子就说明了这个问题：
```
<pre class="hljs javascript">function Vehicle(type, wheelsCount) {
    this.type = type;
    this.wheelsCount = wheelsCount;
    return this;
}
// Function invocation
var car = Vehicle('Car', 4);
car.type;       // => 'Car'
car.wheelsCount // => 4
car === window  // => true</pre>
```
`Vehicle`是一个在上下文上设置了`type`跟`wheelsCount`属性的函数。当执行`Vehicle('Car', 4)`时，返回了一个`car`对象，它的属性是正确的：`car.type`是`'Car'`， `car.wheelsCount`是`4`。你可能以为它正确地创建并初始化了对象。 然而，在函数调用中，`this`是`window`对象 (见 [2.1.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#21thisinfunctioninvocation))，`Vehicle('Car', 4)`实际上是在给`window`对象设置属性 -- 这是错的。它并没有创建一个新的对象。

当你希望调用构造函数时，确保你使用了`new`操作符：
```
<pre class="hljs javascript">function Vehicle(type, wheelsCount) {
    if (!(this instanceof Vehicle)) {
        throw Error('Error: Incorrect invocation');
    }
    this.type = type;
    this.wheelsCount = wheelsCount;
    return this;
}
// Constructor invocation
var car = new Vehicle('Car', 4);
car.type               // => 'Car'
car.wheelsCount        // => 4
car instanceof Vehicle // => true

// Function invocation. Generates an error.
var brokenCat = Vehicle('Broken Car', 3);</pre>
```
`new Vehicle('Car', 4)`工作正常：因为`new`关键词出现在构造函数调用前，一个新的对象被创建并初始化。 在构造函数里我们添加了一个验证`this instanceof Vehicle`来确保执行的上下文是正确的对象类型。如果`this`不是`Vehicle`，那么就会报错。这样，如果执行`Vehicle('Broken Car', 3)`(没有`new`)，我们会得到一个异常：`Error: Incorrect invocation`。

## 5\. 隐式调用

当函数被`.call()`或者`.apply()`调用时，执行的是**隐式调用**。

函数在 JavaScript 中是第一类对象，这意味着函数也是对象。它的类型是 [`Function`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function)。根据这个函数对象所拥有的[方法列表](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function#Methods)，[`.call()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/call)和[`.apply()`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/apply)可以跟一个可变的上下文一起调用函数。

方法`.call(thisArg[, arg1[, arg2[, ...]]])`将接受的第一个参数`thisArg`作为调用时的上下文，`arg1, arg2, ...`这些则作为参数传入被调用的函数。方法`.apply(thisArg, [args])`将接受的第一个参数`thisArg`作为调用时的上下文，并且接受另一个[类似数组的对象](http://www.2ality.com/2013/05/quirk-array-like-objects.html)`[args]`作为被调用函数的参数传入。

下面是一个隐式调用的例子：
```
<pre class="hljs javascript">function increment(number) {
    return ++number;
}
increment.call(undefined, 10);    // => 11
increment.apply(undefined, [10]); // => 11</pre>
```
`increment.call()`和`increment.apply()`都用参数`10`调用了这个自增函数。

这两者的主要区别是`.call()`接受一组参数，例如`myFunction.call(thisValue, 'value1', 'value2')`。然而`.apply()`接受的一组参数必须是一个类似数组的对象，例如`myFunction.apply(thisValue, ['value1', 'value2'])`。

### 5.1\. 隐式调用中的`this`

> 在隐式调用`.call()`或`.apply()`中，`this`是**第一个参数**

很明显，在隐式调用中，`this`是传入`.call()`或`.apply()`中的第一个参数。下面的这个例子就说明了这一点：
```
<pre class="hljs javascript">var rabbit = { name: 'White Rabbit' };
function concatName(string) {
    console.log(this === rabbit); // => true
    return string + this.name;
}
// Indirect invocations
concatName.call(rabbit, 'Hello ');  // => 'Hello White Rabbit'
concatName.apply(rabbit, ['Bye ']); // => 'Bye White Rabbit'</pre>
```
当一个函数应该在特定的上下文中执行时，隐式调用就非常有用。例如为了解决方法调用时，`this`总是`window`或 strict 模式下的`undefined`的上下文问题 (见 [2.3.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#23pitfallthisinaninnerfunction))。隐式调用可以用于模拟在一个对象上调用某个方法（见之前的代码样例）。

另一个实际的例子是在 ES5 中，在创建的类的结构层次中中，调用父类的构造函数：
```
<pre class="hljs javascript">function Runner(name) {
    console.log(this instanceof Rabbit); // => true
    this.name = name;
}
function Rabbit(name, countLegs) {
    console.log(this instanceof Rabbit); // => true
    // Indirect invocation. Call parent constructor.
    Runner.call(this, name);
    this.countLegs = countLegs;
}
var myRabbit = new Rabbit('White Rabbit', 4);
myRabbit; // { name: 'White Rabbit', countLegs: 4 }</pre>
```
`Rabbit`中的`Runner.call(this, name)`隐式调用了父类的函数来初始化这个对象。

## 6\. 绑定函数

**绑定函数**是一个与对象绑定的函数。通常它是通过在原函数上使用 [`.bind()`](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Global_objects/Function/bind)来创建的。原函数和绑定的函数共享代码跟作用域，但是在执行时有不同的上下文。

方法`.bind(thisArg[, arg1[, arg2[, ...]]])`接受第一个参数`thisArg`作为绑定函数执行时的上下文，并且它接受一组可选的参数 `arg1, arg2, ...`作为被调用函数的参数。它返回一个绑定了`thisArg`的新函数。

下面的代码创建了一个绑定函数并在之后调用它：
```
<pre class="hljs javascript">function multiply(number) {
    'use strict';
    return this * number;
}
// create a bound function with context
var double = multiply.bind(2);
// invoke the bound function
double(3);  // => 6
double(10); // => 20</pre>
```
`multiply.bind(2)`返回了一个新的函数对象`double`，`double`绑定了数字`2`。`multiply`跟`double`有相同的代码跟作用域。

跟`.apply()`以及`.call()`方法 (见 [5.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#5indirectinvocation)) 马上调用函数不同，`.bind()`函数返回一个新的方法，它应该在之后被调用，只是`this`已经被提前设置好了。

### 6.1\. 绑定函数中的`this`

> 在调用绑定函数时，`this`是`.bind()`的**第一个参数**。

`.bind()`的作用是创建一个新的函数，它在被调用时的上下文是传入`.bind()`的第一个参数。它是一种非常强大的技巧，使你可以创建一个定义了`this`值的函数。

让我们来看看如何在一个绑定函数中设置`this`：
```
<pre class="hljs php">var numbers = {
    array: [3, 5, 10],
    getNumbers: function() {
        return this.array;
    }
};
// Create a bound function
var boundGetNumbers = numbers.getNumbers.bind(numbers);
boundGetNumbers(); // => [3, 5, 10]
// Extract method from object
var simpleGetNumbers = numbers.getNumbers;
simpleGetNumbers(); // => undefined or throws an error in strict mode</pre>
```
`numbers.getNumbers.bind(numbers)`返回了一个绑定了`number`对象的`boundGetNumbers`函数。`boundGetNumbers()`调用时的`this`是`number`对象，并能够返回正确的数组对象。`numbers.getNumbers`函数能在不绑定的情况下赋值给变量`simpleGetNumbers`。在之后的函数调用中，`simpleGetNumbers()`的`this`是`window`或者 strict 模式下的`undefined`，不是`number`对象 (见 [3.2\. 陷阱](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#32pitfallseparatingmethodfromitsobject))。在这个情况下，`simpleGetNumbers()`不会正确返回数组。

`.bind()`永久性地建立了一个上下文的链接，并且会一直保持它。一个绑定函数不能通过`.call()`或者`.apply()`来改变它的上下文，甚至是再次绑定也不会有什么作用。 只有用绑定函数的构造函数调用方法能够改变上下文，但并不推荐这个方法（因为构造函数调用用的是_常规函数_而不是绑定函数）。 下面的例子声明了一个绑定函数，接着试图改变它预先定义好的上下文：
```
<pre class="hljs javascript">function getThis() {
    'use strict';
    return this;
}
var one = getThis.bind(1);
// Bound function invocation
one(); // => 1
// Use bound function with .apply() and .call()
one.call(2);  // => 1
one.apply(2); // => 1
// Bind again
one.bind(2)(); // => 1
// Call the bound function as a constructor
new one(); // => Object</pre>
```
只有`new one()`改变了绑定函数的上下文，其他方式的调用中`this`总是等于`1`。

## 7\. 箭头函数

**箭头函数**被设计来以更简短的形式定义函数。并且能从[词法](https://en.wikipedia.org/wiki/Scope_(computer_science)#Lexical_scoping)上绑定上下文。它能以下面的方式被使用：
```
<pre class="hljs javascript">var hello = (name) => {
    return 'Hello ' + name;
};
hello('World'); // => 'Hello World'
// Keep only even numbers
[1, 2, 5, 6].filter(item => item % 2 === 0); // => [2, 6]</pre>
```
箭头函数带来了更轻量的语法，避免了冗长的`function`关键词。你甚至可以在函数只有一个语句的时候省略`return`。

因为箭头函数是[匿名的](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Function/name)，这意味着它的`name`属性是个空字符串`''`。这样一来，它就没有一个词法上的函数名（函数名在递归跟事件解绑时会比较有用）。同时，跟常规函数相反，它也不提供 [`arguments`](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Functions/arguments)对象。但是，这在 ES6 中通过 [rest parameters](https://developer.mozilla.org/en/docs/Web/JavaScript/Reference/Functions/rest_parameters) 修复了：
```
<pre class="hljs javascript">var sumArguments = (...args) => {
   console.log(typeof arguments); // => 'undefined'
   return args.reduce((result, item) => result + item);
};
sumArguments.name      // => ''
sumArguments(5, 5, 6); // => 16</pre>
```
### 7.1\. 箭头函数中的`this`

> `this`是箭头函数定义时**封装好的上下文**

箭头函数并不会创建它自己的上下文，它从它定义处的外部函数获得`this`上下文。下面的例子说明了这个上下文透明的特性：
```
<pre class="hljs javascript">class Point {
    constructor(x, y) {
        this.x = x;
        this.y = y;
    }
    log() {
        console.log(this === myPoint); // => true
        setTimeout(()=> {
            console.log(this === myPoint);      // => true
            console.log(this.x + ':' + this.y); // => '95:165'
        }, 1000);
    }
}
var myPoint = new Point(95, 165);
myPoint.log();</pre>
```
`setTimeout`在调用箭头函数时跟`log()`使用了相同的上下文 (`myPoint`对象)。正如所见，箭头函数从它定义处 “继承” 了函数的上下文。 如果在这个例子里尝试用常规函数，它会建立自己的上下文(`window`或 strict 模式下的`undefined`)。所以，为了让同样的代码能在函数表达式中正确运行，需要手动绑定上下文：`setTimeout(function() {...}.bind(this))`。这样一来就显得很啰嗦，不如用箭头函数来得简短。

如果箭头函数定义在最上层的作用域（在所有函数之外），那么上下文就总是全局对象（浏览器中的`window`对象）：
```
<pre class="hljs coffeescript">var getContext = () => {
   console.log(this === window); // => true
   return this;
};
console.log(getContext() === window); // => true</pre>
```
箭头函数会**一劳永逸**地绑定词法作用域。即使使用修改上下文的方法，`this`也不能被改变：
```
<pre class="hljs cs">var numbers = [1, 2];
(function() {
    var get = () => {
        console.log(this === numbers); // => true
        return this;
    };
    console.log(this === numbers); // => true
    get(); // => [1, 2]
    // Use arrow function with .apply() and .call()
    get.call([0]);  // => [1, 2]
    get.apply([0]); // => [1, 2]
    // Bind
    get.bind([0])(); // => [1, 2]
}).call(numbers);</pre>
```
一个函数表达式通过`.call(numbers)`被隐式调用了，这使得这个调用的`this`变成了`numbers`。这样一来，箭头函数`get`的`this`也变成了`numbers`，因为它是从词法上获得的上下文。

无论`get`是怎么被调用的，它一直保持了一开始的上下文`numbers`。用其他上下文的隐式调用 (通过`.call()`或`.apply()`) 或者重新绑定 (通过`.bind()`) 都不会起作用

箭头函数不能用作构造函数。如果像构造函数一样调用`new get()`， JavaScript 会抛出异常：`TypeError: get is not a constructor`。

### 7.2\. 陷阱: 用箭头函数定义方法

你可能想用箭头函数在一个对象上定义方法。这很合情合理：箭头函数的定义相比于[函数表达式](https://developer.mozilla.org/en/docs/web/JavaScript/Reference/Operators/function)短得多：例如`(param) => {...}`而不是`function(param) {..}`。

这个例子用箭头函数在`Period`类上定义了`format()`方法：
```
<pre class="hljs javascript">function Period (hours, minutes) {
    this.hours = hours;
    this.minutes = minutes;
}
Period.prototype.format = () => {
    console.log(this === window); // => true
    return this.hours + ' hours and ' + this.minutes + ' minutes';
};
var walkPeriod = new Period(2, 30);
walkPeriod.format(); // => 'undefined hours and undefined minutes'</pre>
```
由于`format`是一个箭头函数，并且它定义在全局上下文（最顶层的作用域）中，它的`this`指向`window`对象。即使`format`作为方法在一个对象上被调用如`walkPeriod.format()`，`window`仍然是这次调用的上下文。之所以会这样是因为箭头函数有静态的上下文，并不会随着调用方式的改变而改变。

函数表达式可以解决这个问题，因为一个常规的函数会随着调用方法而改变其上下文:
```
<pre class="hljs javascript">function Period (hours, minutes) {
    this.hours = hours;
    this.minutes = minutes;
}
Period.prototype.format = function() {
    console.log(this === walkPeriod); // => true
    return this.hours + ' hours and ' + this.minutes + ' minutes';
};
var walkPeriod = new Period(2, 30);
walkPeriod.format(); // => '2 hours and 30 minutes'</pre>
```
`walkPeriod.format()`是一个对象上的方法调用 (见 [3.1.](https://rainsoft.io/gentle-explanation-of-this-in-javascript/#31thisinmethodinvocation))，它的上下文是`walkPeriod`对象。`this.hours`等于`2`，`this.minutes`等于`30`，所以这个方法返回了正确的结果：`'2 hours and 30 minutes'`。

## 8\. 结论

因为函数调用对`this`有最大的影响，从现在起，**不要**再问你自己：

> `this`是从哪里来的？

而**要**问自己：

> 函数是怎么`被调用`的？

对于箭头函数，问问你自己：

> 在这个箭头函数被`定义`的地方，`this`是什么？

这是处理`this`时的正确想法，它们可以让你免于头痛。

[!转载]：[https://www.w3cplus.com/javascript/gentle-explanation-of-this-in-javascript.html](https://www.w3cplus.com/javascript/gentle-explanation-of-this-in-javascript.html)
