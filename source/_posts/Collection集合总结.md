---
title: Collection集合总结(掌握)
date: 2020-03-15 21:01:24
tags: [Collection]
categories: Java
---
### Collection集合总结(掌握)
<!--more--> 
    Collection  
        |--List    有序, 可重复  
            |--ArrayList  
                底层数据结构是数组，查询快，增删慢。  
                线程不安全，效率高  
            |--Vector  
                底层数据结构是数组，查询快，增删慢。  
                线程安全，效率低  
            |--LinkedList  
                底层数据结构是链表，查询慢，增删快。  
                线程不安全，效率高  
        |--Set    无序, 唯一  
            |--HashSet  
                底层数据结构是哈希表。  
                如何保证元素唯一性的呢?  
                    依赖两个方法：hashCode() 和 equals()  
                |--LinkedHashSet  
                    底层数据结构是链表和哈希表  
                    由链表保证元素有序  
                    由哈希表保证元素唯一  
            |--TreeSet  
                底层数据结构是红黑树。  
                如何保证元素排序的呢?  
                    自然排序  
                    比较器排序  
                如何保证元素唯一性的呢?  
                    根据比较的返回值是否是 0 来决定  
                      
针对 Collection 集合我们到底使用谁呢?(掌握)  
    唯一吗?  
        是：Set  
            排序吗?  
                是：TreeSet  
                否：HashSet  
        如果你知道是 Set，但是不知道是哪个 Set，就用 HashSet。  
              
        否：List  
            要安全吗?  
                是：Vector  
                否：ArrayList 或者 LinkedList  
                    查询多：ArrayList  
                    增删多：LinkedList  
        如果你知道是 List，但是不知道是哪个 List，就用 ArrayList。  
      
    如果你知道是 Collection 集合，但是不知道使用谁，就用 ArrayList。  
      
    如果你知道用集合，就用 ArrayList。  
      
在集合中常见的数据结构 (掌握)  
    ArrayXxx: 底层数据结构是数组，查询快，增删慢  
    LinkedXxx: 底层数据结构是链表，查询慢，增删快  
    HashXxx: 底层数据结构是哈希表。依赖两个方法：hashCode() 和 equals()  
    TreeXxx: 底层数据结构是二叉树。两种方式排序：自然排序和比较器排序
