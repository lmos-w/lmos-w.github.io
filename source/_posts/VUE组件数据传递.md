---
title: VUE组件数据传递
date: 2019-11-19 22:30:20
tags: [Vue, component]
categories: Vue
---
在项目中使用组件，目的一般就是提高代码复用率，增强模块化，从而降低开发成本。在文章结尾处，我们提到了 Vue 中组合组件，就是`A`组件中包含了`B`组件。而组件与组件之间的相互使用避免不了数据之间的传递。那么 Vue 中组件的数据是如何传递的呢？这就是这一节将要了解和学习的内容。
<!--more-->
首先要说明，组件数据传递不同于 Vue 全局的数据传递，**组件实例的数据作用域名是孤立的**，这里的孤立并不仅仅在组件内独立，而且是指上下层之间的数据隔离，**即不能在子组件的模板内直接引用父组件的数据**。如果要把数据从父组件传递到子组件，就需要使用`props`属性。这是父组件用来传递数据的一个自定义属性。也就是说，如果要彻底了解清楚 Vue 组件的数据传递，就很有必要了解清楚`props`属性。

## 组件数据流向

在 Vue 的官方文档中提到，在 Vue 中，父子组件的关系总结为：**`prop`向下传递，事件向上传递。**父组件通过`prop`给子组件下发数据，子组件通过事件给父组件发送消息。如下图所示：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-8.png)

常把这种数据流称之为单向数据流。`prop`是单向绑定的：**当父组件的属性变化时，将传给子组件，但是反过来不会**。这是为了防止子组件无意间修改了父组件的状态，来避免应用的数据流变得难以理解。

另外，每次父组件更新时，子组件的所有`prop`都会更新为最新值。这意味着你不应该在子组件内部改变`prop`。如果你这么做了，Vue 会在控制台给出警告。用一张更细化的图来表示 Vue 组件系统中父子组件的数据流动：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-1.png)

使用`props`向子组件传递数据，首先要在子组件中定义子组件能接受的`props`，然后在父组件中子组件的自定义元素上将数据传递给它。

## props 的使用

前面提到过了，**组件实例的作用域是孤立的**。父组件需要通过`props`把数据传给子组件。要真正了解其中的原委，就很有必要了解清楚`props`的使用。那么我们从一些简单的示例开始吧。

### props 基础示例

首先来创建一个子组件`child`，并且在 Vue 的实例中定义了`data`选项。
```
<pre class="hljs cs">let parent = new Vue({
    el: '#app',
    data () {
        return {
            name: 'w3cplus',
            age: 7
        }
    },
    components: {
        'child': {
            template: '#child',
            props: ['myName', 'myAge']
        }
    }
})</pre>
```
这里直接把 Vue 实例`parent`当作组件`child`的父组件。如果我们想要使用父组件的数据，则必须先在子组件中定义`props`，即：`props:['myName', 'myAge']`。

接下来定义`child`组件的模板：
```
<pre class="hljs xml"><template id="child">
    <div class="child">
        <h3>子组件child数据</h3>
        <ul>
            <li>
                <label>姓名</label>
                <span>{{ myName }}</span>
            </li>
            <li>
                <label>年龄</label>
                <span>{{ myAge }}</span>
            </li>
        </ul>
    </div>
</template></pre>
```
将父组件`parent`的`data`通过已定义好的`props`属性传递给子组件：
```
<pre class="hljs ruby"><div id="app">
    <child :my-></child>
</div></pre>
```
给上面的示例，添加一点 CSS，最终看到的效果如下：

<iframe src="//codepen.io/airen/embed/QQKKqg?height=400&amp;theme-id=0&amp;slug-hash=QQKKqg&amp;default-tab=result&amp;user=airen" scrolling="no" frameborder="0" height="400" allowtransparency="true" allowfullscreen="true" class="sr-rd-content-nobeautify"></iframe>

> **注意：**由于 HTML 特性不区分大小写，在子组件定义`prop`时，使用了驼峰式大小写（camelCase）命名法。驼峰式大小写的`prop`用于特性时，需要转为短横线隔开（kebab-case）。例如，在`prop`中定义的`myName`，在用作特性时需要转换为`my-name`。

用下图简单的剖析一下父组件`parent`是如何将数据传给子组件`child`，或许这样对于初学者更易于理解：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-2.png)

在父组件使用子组件时，通过以下语法将数据传递给子组件：
```
<pre class="hljs xml"><child :子组件的prop="父组件数据属性"></child></pre>
```
> `:`其实相当于`v-bind`，也就是 Vue 中的`v-bind`指令。这是属于动态绑定，让它的值被当作 JavaScript 表达式计算。稍后会做相关的介绍。

### prop 的绑定类型

在 Vue 中的`prop`绑定主要有单向绑定和双向绑定。先来了解一下单向绑定。

#### 单向绑定

通过上面的示例，咱们简单的了解了怎么将父组件数据传递给子组件。而且在 Vue 2.0 中组件的`props`的数据流动改为了单向流动，即**只能由组件外（调用组件方）通过组件的 DOM 属性`attribute`传递`props`给组件内，组件内只能被动接受组件外传递过来的数据，并且在组件内，不能修改由外层传来的`props`数据**。

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-3.png)

但很多时候我们还是会修改子组件数据，那么问题来了，如果子组件修改了数据，对父组件是否有影响呢？我们基于上面的示例，做一下相应的调整：
```
<pre class="hljs xml"><div id="app">
    <div class="parent">
        <h3>父组件Parent数据</h3>
        <ul>
            <li>
                <label>姓名:</label>
                <span>{{ name }}</span>
                <input type="text" v-model="name" />
            </li>
            <li>
                <label>年龄:</label>
                <span>{{ age }}</span>
                <input type="text" v-model="age" />
            </li>
        </ul>
    </div>
    <child :my-></child>
</div>

<template id="child">
    <div class="child">
        <h3>子组件child数据</h3>
        <ul>
            <li>
                <label>姓名</label>
                <span>{{ myName }}</span>
                <input type="text" v-model="myName" />
            </li>
            <li>
                <label>年龄</label>
                <span>{{ myAge }}</span>
                <input type="text" v-model="myAge" />
            </li>
        </ul>
    </div>
</template></pre>
```
看到的效果如下：

<iframe src="//codepen.io/airen/embed/JpbYeM?height=400&amp;theme-id=0&amp;slug-hash=JpbYeM&amp;default-tab=result&amp;user=airen" scrolling="no" frameborder="0" height="400" allowtransparency="true" allowfullscreen="true" class="sr-rd-content-nobeautify"></iframe>

在这个 Demo 中我们来做两个小修改。首先修改父组件中的数据：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-4.gif)

从上面修改父组件数据得到的效果可以告诉我们：**修改父组件的数据将会影响子组件，子组件的数据也会对应的修改**。

接下来再反过来，修改子组件的数据：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-5.gif)

从效果中可以看出：**修改子组件数据并不会影响父组件的数据**。

> `prop`默认是单向绑定：**当父组件的属性变化时，将传给子组件，但反过来不会。这是为了防止子组件无意修改了父组件的状态**。

用一个更真实的示例来进一步的阐述。假设我们要做一个 iOS 风格的开关按钮：

*   点击按钮实现 “开 / 关” 状态切换
*   不点击按钮，也可以通过外部修改数据切换 “开 / 关” 状态

代码大致如下：
```
<pre class="hljs cs"><div id="app">
    <switch-button :result="result"></switch-button>

    <div class="switch-button" @click="change" :class="result ? 'on' : 'off'">
        <span>{{ result ? "开" : "关" }}</span>
    </div>
</div>

Vue.component('switch-button', {
    template: `
        <div class="switch-button" @click="change" :class="result ? 'on' : 'off'">
            <span>{{ result ? "开" : "关" }}</span>
        </div>
    `,
    props: ['result'],
    methods: {
        change: function () {
            this.result = !this.result
        }
    }
})

let app = new Vue({
    el: '#app',
    data () {
        return {
            result: true
        }
    },
    methods: {
        change: function () {
            this.result = !this.result;
        }
    }
})</pre>
```
上面的示例得到的效果如下：

<iframe src="//codepen.io/airen/embed/WMorBE?height=400&amp;theme-id=0&amp;slug-hash=WMorBE&amp;default-tab=result&amp;user=airen" scrolling="no" frameborder="0" height="400" allowtransparency="true" allowfullscreen="true" class="sr-rd-content-nobeautify"></iframe>

来操作一下两个切换按钮的效果：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-6.gif)

虽然效果上没有问题，但事实上，当我们点击 “开关组件” 时，将会发出一个警告信息：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-7.png)

再次验证：**组件内不能修改`props`的值，同时修改的值也不会同步到组件外层，即调用组件方不知道组件内部当前的状态是什么。**

> 至于这个 Demo 的操作会发出警告信息，以及怎么处理，这里先不说了。后续我们将会深入了解怎么处理这个 Demo 的警告信息。

#### 双向绑定

咱们回到前面的示例中来。前面的示例演示告诉我们，父组件和子组件的操作：

> **修改父组件的数据将会影响子组件，子组件的数据也会对应的修改；修改子组件数据并不会影响父组件的数据**。

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-8.gif)

要改变这一状态。可以通过`props`的双向绑定来完成。在 Vue 中，可以使用`.sync`显式地指定双向绑定，这样能让**子组件的数据修改会回传给父组件**。

在上面的示例中调用子组件时，像下面这样操作：
```
<pre class="hljs perl"><child v-bind:my-name.sync="name" v-bind:my-age.sync="age"></child></pre>
```
<iframe src="//codepen.io/airen/embed/rJWMZK?height=400&amp;theme-id=0&amp;slug-hash=rJWMZK&amp;default-tab=result&amp;user=airen" scrolling="no" frameborder="0" height="400" allowtransparency="true" allowfullscreen="true" class="sr-rd-content-nobeautify"></iframe>

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1802/vue-component-prop-9.gif)

这正是 Vue 1.x 中的 `.sync` 修饰符所提供的功能。当一个子组件改变了一个带 `.sync` 的 `prop` 的值时，这个变化也会同步到父组件中所绑定的值。这很方便，但也会导致问题，因为它破坏了单向数据流。由于子组件改变 `prop` 的代码和普通的状态改动代码毫无区别，当光看子组件的代码时，你完全不知道它何时悄悄地改变了父组件的状态。这在 debug 复杂结构的应用时会带来很高的维护成本。

上面所说的正是我们在 2.0 中移除 `.sync` 的理由。但是在 2.0 发布之后的实际应用中，我们发现 `.sync` 还是有其适用之处，比如在开发可复用的组件库时。我们需要做的只是让子组件改变父组件状态的代码更容易被区分。

从 2.3.0 起我们重新引入了 `.sync` 修饰符，但是这次它只是作为一个编译时的语法糖存在。它会被扩展为一个自动更新父组件属性的 `v-on` 监听器。

如下代码
```
<pre class="hljs xml"><comp :foo.sync="bar"></comp></pre>
```
会被扩展为：
```
<pre class="hljs ruby"><comp :foo="bar" @update:foo="val => bar = val"></comp></pre>
```
当子组件需要更新 `foo` 的值时，它需要显式地触发一个更新事件：
```
<pre class="hljs bash">this.$emit('update:foo', newValue)</pre>
```
感觉`props`双向绑定还是蛮复杂的。这也正是前面把切换按钮示例中解决警告信息留下来没有阐述的原因之一。下一节将学习解决父子组件数据和`props`的双向绑定。

## 总结

通过这篇文章的学习，了解了在 Vue 2.0 中，父子组件的数据流是单向的。即：`prop`默认是单向绑定，**当父组件的属性变化时，将传给子组件，但反过来不会。这是为了防止子组件无意修改了父组件的状态**。而很多时候我们又需要子组件修改数据时，在父组件中要有所反应。这个时候就需要涉及到双向数据绑定。在下一节中，将学习 Vue 2.0 中的数据双向绑定。

[!转载]：[https://www.w3cplus.com/vue/component-data-and-props-part1.html](//www.w3cplus.com/vue/component-data-and-props-part1.html)[Women's Clothing, Footwear & Accessories](https://m2film.dk/eshop/collections/womens)
