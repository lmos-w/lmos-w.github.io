---
title: Vue 组件内容分发（slot）
date: 2019-11-19 19:35:02
tags: [Vue, slot]
categories: Vue
---
在实际项目开发当中，时常会把父组件的内容与子组件自己的模板混合起来使用。而这样的一个过程在 Vue 中被称为**内容分发**。也常常被称为**`slot`（插槽）**。其主要参照了当前 [Web Components 规范草案](//github.com/w3c/webcomponents/blob/gh-pages/proposals/Slots-Proposal.md)，使用特殊的`<slot>`元素作为原始内容的插槽。今天主要来学习如何在 Vue 中使用`slot`的功能。

先简单的了解一个概念
----------

在深入理解 Vue 的`slot`之前，先来简单的了解一个有关于`slot`的概念，便于后续的学习和理解。

前面也说过了，Vue 中的`slot`源于 Web Components 规范草案，也被称之为插槽，是组件的一块 HTML 模板，而这块模板显示不显示，以及怎么显示由父组件来决定。那么，Vue 中一个`slot`最核心的两个问题就出来了：

*   **显示不显示**
*   **怎么显示**

由于`slot`是一块模板，因此对于任何一个组件，从模板种类的角度来分，共实都可分为**非插槽模板**和**插槽模板**。其中非插槽模板指的是 HTML 模板（也就是 HTML 的一些元素，比如`div`、`span`等构成的），其显与否及怎么显示完全由插件自身控制；但插槽模板（也就是`slot`）是一个空壳子，它显示与否以及怎么显示完全是由**父组件**来控制。不过，**插槽显示的位置由子组件自身决定，`slot`写在组件`template`的哪块，父组件传过来的模板将来就显示在哪块**。

Vue 的编译作用域
----------

简单的了解了`slot`中的基本概念，从基本概念中可以获知，使用`slot`会涉及 Vue 的模板，而 Vue 的模板在渲染成 UI 之前是有一个编译过程的，也会存在模板**编译作用域**一说。理解清楚这部分内容，也更有助于我们理解`slot`，所以花点时间先简单的理解一下 Vue 的编译作用域。

在前面的《[Vue 实例和生命周期](//www.w3cplus.com/vue/vue-instances-and-life-cycles.html)》一文中，我们了解了 Vue 的生命周期相关的知识点，此处不再阐述，上张介绍 Vue 生命周期的图：

![](https://www.w3cplus.com/sites/default/files/blogs/2017/1711/vue-instances-and-life-cycles-8.png)

碰到是否有`template`选项时，会询问是否要对`template`进行编译：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-1.png)

在`template`编译（渲染成 UI）有一个过程。模板通过编译生成 AST，再由 AST 生成 Vue 的渲染函数，渲染函数结合数据生成 Virtual DOM 树，对 Virtual DOM 进行`diff`和`patch`后生成新的 UI。将上图细化一下，也就是`template`编译的过程如下图所示：

![](https://www.w3cplus.com/sites/default/files/blogs/2017/1710/vue-template-9.jpg)

在深入一点，如下：

![](https://www.w3cplus.com/sites/default/files/blogs/2017/1710/vue-template-10.png)

> 有关于 Vue 中`template`的渲染的详细过程，可以阅读《[Vue 的模板](//www.w3cplus.com/vue/vue-template.html)》一文。

简理的理解就是 Vue 中的`template`编译成浏览器可识的过程会经过不少的过程。言外之意，最终在浏览器中呈现的并不是`<template>`，而是会解析成标准的 HTML，然后将组件的标签替换为对应的 HTML 片段。用个小示例来举例：

```
<div id="app">
    <my-component></my-component>
</div>

<template id="myComponent">
    <div>
        <h2>{{ message }}</h2>
        <button @click="show">Show Message</button>
    </div>
</template>

Vue.component('my-component', {
    template: '#myComponent',
    data () {
        return {
            message: '我是一个Vue组件!'
        }
    },
    methods: {
        show: function () {
            alert(this.message)
        }
    }
})

let app = new Vue({
    el: '#app'
})
```

Vue 将会通过其自身的编译机制（如前图所示的过程），将`<my-component>`编译成让浏览器可以识别的 HTML 代码。可以借助浏览器开发者工具一探究竟：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-2.png)

我的理解是这样的。上面的示例通过`new Vue()`创建一下人 Vue 的实例，并且将这个实例挂载到`div#app`的元素下，然后把组件`<my-component>`编译成 HTML，最终渲染所需要的 UI 效果。继续用张图来描述这个过程，一图胜过千言万语嘛。

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-3.png)

我们要说的是模板编译的作用域，在 Vue 中，组件是有一个作用域的：**组件模板（`<template>`）**内的就是组件作用域，而其之外的就不是组件的作用域了，比如上面的示例，`my-component`组件的作用域就是下面这部分：

```
<template id="myComponent">
    <div>
        <h2>{{ message }}</h2>
        <button @click="show">Show Message</button>
    </div>
</template>
```

组件的模板是在其作用域内编译的，因此组件选项对象中的`data`也是在组件模板中使用的。如果我们在前面的示例中的 Vue 实例的组件`my-component`中同时追加一个`display`属性：

```
Vue.component('my-component', {
    template: '#myComponent',
    data () {
        return {
            message: '我是一个Vue组件!',
            display: false
        }
    },
    methods: {
        show: function () {
            alert(this.message)
        }
    }
})

let app = new Vue({
    el: '#app',
    data () {
        return {
            display: true
        }
    }
})
```

然后在`<my-component>`中使用指令`v-show="display"`：

```
<div id="app">
    <my-component v-show="display"></my-component>
</div>
```

试问，此时`display`是来源于 Vue 实例，还是`my-component`组件呢？答案很简单：**`display`来源于 Vue 实例**。也就是说，在 Vue 中组件的作用域是独立的：

> **父组件模板的内容在父组件作用域内编译；子组件模板的内容在子组件作用域内编译。**

通俗地讲，在子组件中定义的数据，只能用在子组件的模板。在父组件中定义的数据，只能用在父组件的模板。如果父组件的数据要在子组件中使用，则需要子组件定义`props`。有关于这方面的内容可以阅读：

*   《[组件数据传递](//www.w3cplus.com/vue/component-data-and-props-part1.html)》
*   《[实现组件数据的双向绑定](//www.w3cplus.com/vue/component-data-and-props-part2.html)》
*   《[不同场景下组件间的数据通讯](//www.w3cplus.com/vue/component-data-and-props-part3.html)》

简单的了解了 Vue 编译的作用域之后，咱们接着回到我们今天要聊的主题，Vue 的`slot`。

`slot`大致用法
----------

先来简单的看一下 Vue 中的`slot`的使用方法。比如我们有一个类似`alert`的小组件：

```
<div id="app">
    <alert></alert>
</div>

<template id="alert">
    <div class="alert info">
        <button class="close">×</button>
        <slot>This is alert box!</slot>
    </div>
</template>

Vue.component('alert', {
    template: '#alert',
})

let app = new Vue({
    el: '#app'
})
```

上面的代码在`alert`组件的模板中指定了一个`<slot>`元素，并且在该元素中放置了一个默认内容 “This is alert box!”。在调用`alert`组件时，并没有向该组件分发任何内容，这个时候运行的结果如下：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-5.png)

从上面的效果中可以得知：**如果父组件未向模板中分发内容（插入内容），则显示插槽中默认内容（前提是`slot`中设置了默认内容）**。

接下来，在上面的示例上，做小小的修改，在`<alert>`使用的时候，插入你想要的内容（也就是指父组件向模板分发内容）：

```
<div id="app">
    <alert>
        <div>
            <h2>Hello W3cplus!</h2>
            <p>欢迎您来到w3cplus.com！</p>
        </div>
    </alert>
</div>
```

运行上面的代码得到的效果是：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-6.png)

从代码运行的结果可以得知：**父组件给模板分发了内容，则分发的内容会替换`slot`标签**。除此之外，假设**模板中未设置插槽，父组件依旧向其分发了内容，但最终任何分发的内容都不会显示**。比如下图所示：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1803/vue-slot-7.png)

在介绍编译作用域时，了解到，**父组件的内容是在父组件作用域编译，子组件的内容是在子组件作用域编译**。而 Vue 的`slot`一般用在父组件向子组件分发内容，该内容的编译作用域名为父组件作用域。

继续拿上面的`alert`组件来举例。在我们的`alert`组件中，很多时候有多种样式风格，除了`info`之外，还有`success`、`danger`和`warning`之类。我们可以在父组件的编译时绑定`status`状态。

```
<div id="app">
    <alert v-for="statu in status" :status=statu>
        <div>
            <h2>{{ statu }}</h2>
            <p>欢迎您来到w3cplus.com！</p>
        </div>
    </alert>
</div>

<template id="alert">
    <div class="alert" :class="[alertStatus]" v-show="isShow">
        <button class="close" @click="close">×</button>
        <slot>This is alert box!</slot>
    </div>
</template>

Vue.component('alert', {
    template: '#alert',
    props: ['status'],
    data () {
        return {
            isShow: true
        }
    },
    computed: {
        alertStatus: function () {
            return this.status
        }
    },
    methods: {
        close: function () {
            this.isShow = !this.isShow
        }
    }
})

let app = new Vue({
    el: '#app',
    data () {
        return {
            status: ['info', 'success', 'danger', 'warning']
        }
    }
})
```

最终效果如下：

slot 分类
-------

在 Vue 中，`slot`也分多种，从 Vue 的官网中可以获知，其主要分为：**单个插槽**、**具名插槽**和**作用域插槽**三种。接下来我们借助 [`modal`组件](//www.w3cplus.com/vue/vue-modal-component.html)为例，看看 Vue 中的这几种插槽怎么使用。

Web 中常见的`modal`弹框外形长得大致都如下图这样：

![](https://www.w3cplus.com/sites/default/files/blogs/2018/1801/modal-vue-2.png)

### 单个插槽

在介绍`slot`大致使用方法的一节中，已经知道了，如果子组件`template`中没有包含任何一个`<slot>`时，就算父组件分发再多的内容也将会被**丢弃**。只有子组件模板只要有一个没有属性的`slot`（因为在模板中可以有多个带属性的`slot`，后面的内容会介绍），父组件传入的整个内容片段将插入到`slot`所在的 DOM 位置，并将替换掉`slot`本身。

最初在`<slot>`中的任何内容都被视为**备用内容**（也可以在最初的`<slot>`中不放置任何默认内容）。备用内容在子组件的作用域内编译，并且只有在宿主元素（父组件没有分发任何内容）为空，且没有要插入的内容时才显示备用内容。

如果拿`modal`来举例，在单个插槽时，整个`modal`的内容都将需要通过父组件来进行分发。我们可以这样写（可能不太理想，但我们后面会慢慢让她变得更完善）：

```
<!-- modal组件模板 -->
<template id="modal">
    <div class="modal-backdrop">
        <div class="modal" @click.stop>
            <slot></slot>
        </div>
    </div>
</template>

// JavaScript Code
Vue.component('modal', {
    template: '#modal',
    methods: {
        close: function (event) {
            this.$emit('close');
        }
    }
})

let app = new Vue({
    el: '#app',
    data () {
        return {
            toggleModal: false
        }
    },
    methods: {
        showModal: function () {
            this.toggleModal = true
        },
        closeModal: function () {
            this.toggleModal = false
        }
    }
})
```

在`modal`组件的`template`中，只使用了一个`<slot>`，这个时候在父组件中使用`modal`组件时，父组件分发的内容就会替换`<slot>`中的内容：

```
<div id="app">
    <modal v-show="toggleModal" @click="closeModal">
        <div>
            <div class="modal-header">
                <div  class="close rotate" @click="closeModal">
                    <i class="fa-times fa"></i>
                </div>
                <h3 class="modal-title">Modal Header</h3>
            </div>
            <div class="modal-body">
                <h3>Modal Body</h3>
                <p>Modal body conent...</p>
            </div>
            <div class="modal-footer">
                <button class="btn" @click="closeModal">关闭</button>
            </div>
        </div>
    </modal>
    <button class="btn btn-open" @click="showModal">Show Modal</button>
</div
```

最终的效果如下：

这样写感觉是不是怪怪的。我也是这么认为的，这只是为了说明单个`slot`的使用。接下来我们看看具名插槽。

### 具名插槽

`<slot>`可以用一个特殊的属性`name`来进一步配置父组件如何分发内容。多个插槽可以有不同的名字。具名插槽将匹配内容片段中有对应`slot`特性的元素。

仍然可以有一个匿名插槽，它是**默认插槽**，作为找不到匹配的内容片段的备用插槽。如果没有默认插槽，这些找不到匹配的内容片段将被抛弃。

前面示例写的`modal`组件使用了一个匿名`slot`。如果我们使用多个`slot`时，会让`modal`组件变得更为灵活。众所周知，对于一个`modal`组件，其主体结构包括了`modal-header`、`modal-body`和`modal-footer`（当然，很多时候可能不会同时出现，根据需要选择）。那么在定义`modal`组件的`template`时，可以使用三个`slot`，它们的`name`属性分别命名为`header`、`body`和`footer`。

基于上例，把模板修改成：

```
<template id="modal">
    <div class="modal-backdrop">
        <div class="modal" @click.stop>
            <slot ></slot>
            <slot ></slot>
            <slot ></slot>
        </div>
    </div>
</template>
```

在使用模板的时候：

```
<div id="app">
    <modal v-show="toggleModal" @click="closeModal">
        <div class="modal-header" slot="header">
            <div  class="close rotate" @click="closeModal">
            <i class="fa-times fa"></i>
            </div>
            <h3 class="modal-title">Modal Header</h3>
        </div>
        <div class="modal-body" slot="body">
            <h3>Modal Body</h3>
            <p>Modal body conent...</p>
        </div>
        <div class="modal-footer" slot="footer">
            <button class="btn" @click="closeModal">关闭</button>
        </div>
    </modal>
    <button class="btn btn-open" @click="showModal">Show Modal</button>
</div>
```

其他不变，最终的效果如下：

这个时候，你可以根据你的需要，在使用的时候视项目情况去选择，使用具名的插槽。

> 在《[使用 Vue 创建 Modal 组件](//www.w3cplus.com/vue/vue-modal-component.html)》一文中，也涉及到了`slot`的内容，现在回过头来看，将会变得更轻松些。

### 作用域插槽

作用域插槽是一种特殊类型的插槽，用作一个（能被传递数据的）可重用模板，来代替已经渲染好的元素。

在子组件中，只需将数据传递到插槽，就像你将`prop`传递给组件一样：

```
<div class="child">
    <slot text="hello from child"></slot>
</div>
```

在父级中，具有特殊特性 `slot-scope` 的 `<template>` 元素必须存在，表示它是作用域插槽的模板。`slot-scope` 的值将被用作一个临时变量名，此变量接收从子组件传递过来的 `prop` 对象：

```
<div class="parent">
    <child>
        <template slot-scope="props">
            <span>hello from parent</span>
            <span>{{ props.text }}</span>
        </template>
    </child>
</div>
```

如果我们渲染上述模板，得到的输出会是：

```
<div class="parent">
    <div class="child">
        <span>hello from parent</span>
        <span>hello from child</span>
    </div>
</div>
```

> **在 2.5.0+，`slot-scope` 能被用在任意元素或组件中而不再局限于 `<template>`**。

作用域插槽更典型的用例是在列表组件中，允许使用者自定义如何渲染列表的每一项：

```
<my-awesome-list :items="items">
    <!-- 作用域插槽也可以是具名的 -->
    <li
        slot="item"
        slot-scope="props"
        class="my-fancy-item">
        {{ props.text }}
    </li>
</my-awesome-list>
```

列表组件的模板：

```
<ul>
    <slot
        v-for="item in items"
        :text="item.text">
        <!-- 这里写入备用内容 -->
    </slot>
</ul>
```

`slot-scope` 的值实际上是一个可以出现在函数签名参数位置的合法的 JavaScript 表达式。这意味着在受支持的环境 (单文件组件或现代浏览器) 中，您还可以在表达式中使用 ES2015 解构：

```
<child>
    <span slot-scope="{ text }">{{ text }}</span>
</child>
```

比如下面这个示例：

如果想进一步的了解`slot`中的作用域插槽，可以阅读《[Vue 的作用域插槽](//www.w3cplus.com/vue/vue-js-scoped-slots.html)》一文。

总结
--

这篇文章主要学习和了解了 Vue 中的插槽`<slot>`。是一个空壳子，它显示与否以及怎么显示完全是由**父组件**来控制。不过，**插槽显示的位置由子组件自身决定，`slot`写在组件`template`的哪块，父组件传过来的模板将来就显示在哪块**。在写一些组件的时候，`slot`能帮助我们做很多事情，也能让组件可复用性变得更为灵活。

[![](https://www.w3cplus.com/sites/default/files/blogs/author/airen.jpg)](//weibo.com/w3cplus)

### [大漠](//weibo.com/w3cplus)

常用昵称 “大漠”，W3CPlus 创始人，目前就职于手淘。对 HTML5、CSS3 和 Sass 等前端脚本语言有非常深入的认识和丰富的实践经验，尤其专注对 CSS3 的研究，是国内最早研究和使用 CSS3 技术的一批人。CSS3、Sass 和 Drupal 中国布道者。2014 年出版《[图解 CSS3：核心技术与案例实战](//www.w3cplus.com/book-comment.html)》。

如需转载，烦请注明出处：[https://www.w3cplus.com/vue/vue-slot.html](//www.w3cplus.com/vue/vue-slot.html)[Air Jordan 89 Shoes](https://www.febshoes.com/category/556)

如需转载，烦请注明出处：[https://www.w3cplus.com/vue/vue-slot.html](https://www.w3cplus.com/vue/vue-slot.html)

> **如果文章中有不对之处，烦请各位大神拍正。如果你觉得这篇文章对你有所帮助，[打个赏，让我有更大的动力去创作](//www.zhi12.com/paycenter/reward/widget?entity=user&id=5491)。(^_^)。看完了？还不过瘾？点击[向作者提问！](//www.zhi12.com/ask/5491/widget)**

赏杯咖啡，鼓励他创作更多优质内容！ [![](https://www.w3cplus.com/sites/default/files/blogs/2018/1807/shang1.png)](//www.zhi12.com/paycenter/reward/widget?entity=user&id=5491)
