---
title: Java中的多态
date: 2020-03-08 21:01:24
tags: [multi]
categories: Java
---
### Java中的多态
<!--more-->
多态一般分为两种：重写式多态和重载式多态。重写和重载这两个知识点前面的文章已经详细将结果了，这里就不多说了。

*   重载式多态，也叫编译时多态。也就是说这种多态再编译时已经确定好了。重载大家都知道，方法名相同而参数列表不同的一组方法就是重载。在调用这种重载的方法时，通过传入不同的参数最后得到不同的结果。

    > 但是这里是有歧义的，有的人觉得不应该把重载也算作多态。因为很多人对多态的理解是：程序中定义的引用变量所指向的具体类型和通过该引用变量发出的方法调用在编程时并不确定，而是在程序运行期间才确定，这种情况叫做多态。 这个定义中描述的就是我们的第二种多态—重写式多态。并且，重载式多态并不是面向对象编程特有的，而多态却是面向对象三大特性之一（如果我说的不对，记得告诉我。。）。
    >
    > 我觉得大家也没有必要在定义上去深究这些，我的理解是：同一个行为具有多个不同表现形式或形态的能力就是多态，所以我认为重载也是一种多态，如果你不同意这种观点，我也接受。

*   重写式多态，也叫运行时多态。这种多态通过动态绑定（dynamic binding）技术来实现，是指在执行期间判断所引用对象的实际类型，根据其实际的类型调用其相应的方法。也就是说，只有程序运行起来，你才知道调用的是哪个子类的方法。   
    这种多态通过函数的重写以及向上转型来实现，我们上面代码中的例子就是一个完整的重写式多态。我们接下来讲的所有多态都是重写式多态，因为它才是面向对象编程中真正的多态。


### 向上转型

子类引用的对象转换为父类类型称为向上转型。通俗地说就是是将子类对象转为父类对象。此处父类对象可以是接口。

看一个大家都知道的例子：

```
public class Animal {
    public void eat(){
        System.out.println("animal eatting...");
    }
}

public class Cat extends Animal{

    public void eat(){

        System.out.println("我吃鱼");
    }
}

public class Dog extends Animal{

    public void eat(){

        System.out.println("我吃骨头");
    }

    public void run(){
        System.out.println("我会跑");
    }
}

public class Main {

    public static void main(String[] args) {

        Animal animal = new Cat(); //向上转型
        animal.eat();

        animal = new Dog();
        animal.eat();
    }

}

//结果:
//我吃鱼
//我吃骨头
```

这就是向上转型，Animal animal = new Cat(); 将子类对象 Cat 转化为父类对象 Animal。这个时候 animal 这个引用调用的方法是子类方法。

#### 转型过程中需要注意的问题

*   向上转型时，子类单独定义的方法会丢失。比如上面 Dog 类中定义的 run 方法，当 animal 引用指向 Dog 类实例时是访问不到 run 方法的，`animal.run()`会报错。
*   子类引用不能指向父类对象。`Cat c = (Cat)new Animal()`这样是不行的。

#### 向上转型的好处

*   减少重复代码，使代码变得简洁。
*   提高系统扩展性。

### 向下转型

与向上转型相对应的就是向下转型了。向下转型是把父类对象转为子类对象。(请注意！这里是有坑的。)

#### 案例驱动

先看一个例子：

```
//还是上面的animal和cat dog
Animal a = new Cat();
Cat c = ((Cat) a);
c.eat();
//输出  我吃鱼
Dog d = ((Dog) a);
d.eat();
// 报错 ： java.lang.ClassCastException：com.chengfan.animal.Cat cannot be cast to com.chengfan.animal.Dog
Animal a1 = new Animal();
Cat c1 = ((Cat) a1);
c1.eat();
// 报错 ： java.lang.ClassCastException：com.chengfan.animal.Animal cannot be cast to com.chengfan.animal.Cat
```

为什么第一段代码不报错呢？相比你也知道了，因为 a 本身就是 Cat 对象，所以它理所当然的可以向下转型为 Cat，也理所当然的不能转为 Dog，你见过一条狗突然就变成一只猫这种操蛋现象？

而 a1 为 Animal 对象，它也不能被向下转型为任何子类对象。比如你去考古，发现了一个新生物，知道它是一种动物，但是你不能直接说，啊，它是猫，或者说它是狗。

#### 向下转型注意事项

*   向下转型的前提是父类对象指向的是子类对象（也就是说，在向下转型之前，它得先向上转型）
*   向下转型只能转型为本类对象（猫是不能变成狗的）。


看一个经典案例：

```
class A {
    public String show(D obj) {
        return ("A and D");
    }

    public String show(A obj) {
        return ("A and A");
    }

}

class B extends A{
    public String show(B obj){
        return ("B and B");
    }

    public String show(A obj){
        return ("B and A");
    }
}

class C extends B{

}

class D extends B{

}

public class Demo {
    public static void main(String[] args) {
        A a1 = new A();
        A a2 = new B();
        B b = new B();
        C c = new C();
        D d = new D();

        System.out.println("1--" + a1.show(b));
        System.out.println("2--" + a1.show(c));
        System.out.println("3--" + a1.show(d));
        System.out.println("4--" + a2.show(b));
        System.out.println("5--" + a2.show(c));
        System.out.println("6--" + a2.show(d));
        System.out.println("7--" + b.show(b));
        System.out.println("8--" + b.show(c));
        System.out.println("9--" + b.show(d));
    }
}
//结果：
//1--A and A
//2--A and A
//3--A and D
//4--B and A
//5--B and A
//6--A and D
//7--B and B
//8--B and B
//9--A and D

//能看懂这个结果么？先自分析一下。
```

前三个，强行分析，还能看得懂。但是第四个，大概你就傻了吧。为什么不是 b and b 呢？

这里就要学点新东西了。

> 当父类对象引用变量引用子类对象时，被引用对象的类型决定了调用谁的成员方法，引用变量类型决定可调用的方法。如果子类中没有覆盖该方法，那么会去父类中寻找。

可能读起来比较拗口，我们先来看一个简单的例子：

```
class X {
    public void show(Y y){
        System.out.println("x and y");
    }

    public void show(){
        System.out.println("only x");
    }
}

class Y extends X {
    public void show(Y y){
        System.out.println("y and y");
    }
    public void show(int i){

    }
}

class main{
    public static void main(String[] args) {
        X x = new Y();
        x.show(new Y());
        x.show();
    }
}
//结果
//y and y
//only x
```

Y 继承了 X，覆盖了 X 中的 show（Y y) 方法，但是没有覆盖 show（）方法。

这个时候，引用类型为 X 的 x 指向的对象为 Y，这个时候，调用的方法由 Y 决定，会先从 Y 中寻找。执行`x.show(new Y());`，该方法在 Y 中定义了，所以执行的是 Y 里面的方法；

但是执行`x.show();`的时候，有的人会说，Y 中没有这个方法啊？它好像是去父类中找该方法了，因为调用了 X 中的方法。

事实上，Y 类中是有 show（）方法的，这个方法继承自 X，只不过没有覆盖该方法，所以没有在 Y 中明确写出来而已，看起来像是调用了 X 中的方法，实际上调用的还是 Y 中的。

> 这个时候再看上面那句难理解的话就不难理解了吧。X 是引用变量类型，它决定哪些方法可以调用；show（）和 show(Y y) 可以调用，而 show(int i) 不可以调用。Y 是被引用对象的类型，它决定了调用谁的方法：调用 y 的方法。

上面的是一个简单的知识，它还不足以让我们理解那个复杂的例子。我们再来看这样一个知识：

> **继承链中对象方法的调用的优先级：this.show(O)、super.show(O)、this.show((super)O)、super.show((super)O)。**

如果你能理解这个调用关系，那么多态你就掌握了。我们回到那个复杂的例子：

abcd 的关系是这样的：C/D —> B —> A

我们先来分析 4 ： `a2.show(b)`

> *   首先，a2 是类型为 A 的引用类型，它指向类型为 B 的对象。A 确定可调用的方法：show(D obj) 和 show(A obj)。
> *   `a2.show(b)` ==> `this.show(b)`，这里 this 指的是 B。
> *   然后. 在 B 类中找 show（B obj），找到了，可惜没用，因为 show（B obj）方法不在可调用范围内，`this.show(O)`失败，进入下一级别：`super.show(O)`，super 指的是 A。
> *   在 A 中寻找 show（B obj)，失败，因为没用定义这个方法。进入第三级别：`this.show((super)O)`，this 指的是 B。
> *   在 B 中找 show（（A）O）, 找到了：show(A obj)，选择调用该方法。
> *   输出：B and A

如果你能看懂这个过程，并且能分析出其他的情况，那你就真的掌握了。

我们再来看一下 9：`b.show(d)`

> *   首先，b 为类型为 B 的引用对象，指向类型为 B 的对象。没有涉及向上转型，只会调用本类中的方法。
> *   在 B 中寻找 show(D obj)，方法。现在你不会说没找到了吧？找到了，直接调用该方法。
> *   输出 A and D。

总结
--

本篇文章的内容大体上就是这些了。我们来总结一下。

1.  多态，简而言之就是同一个行为具有多个不同表现形式或形态的能力。
2.  多态的分类：运行时多态和编译时多态。
3.  运行时多态的前提：继承（实现），重写，向上转型
4.  向上转型与向下转型。
5.  继承链中对象方法的调用的优先级：this.show(O)、super.show(O)、this.show((super)O)、super.show((super)O)。

原文地址 https://www.cnblogs.com/kexianting/p/8689031.html
