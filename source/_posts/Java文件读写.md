---
title: Java文件读写
date: 2019-11-18 19:25:19
tags: [File, Java]
categories: Java
---
## Java文件读写
<!--more-->
![](http://upload-images.jianshu.io/upload_images/13863123-3b31b9635a45a269.jpg) ![](http://upload-images.jianshu.io/upload_images/13863123-e669017cd996500b.jpg)

### **IO 流**

1. IO 流：用于处理设备上的数据。

设备：硬盘，内存，键盘录入。

2. IO 有具体的分类：

（1）根据处理的数据类型不同：字节流和字符流。

（2）根据流向不同：输入流和输出流。

字符流的由来：

因为文件编码的不同，而有了对字符进行高效操作的字符流对象。

原理：其实就是基于字节流读取字节时，去查了指定的码表。

字节流和字符流的区别：

（1）字节流读取的时候，读到一个字节就返回一个字节。

字符流使用了字节流读到一个或多个字节（中文对应的字节数是两个，在 UTF-8 码表中是 3 个字节）时，先去查指定的编码表，将查到的字符返回。

**（2）字节流可以处理所有类型数据，如 MP3，图片，avi。而字符流只能处理字符数据。**

**结论：只要是处理纯文本数据，就要优先考虑使用字符流，除此之外都要用字节流。**

IO 的体系，所具备的基本功能就有两个：读和写。

1. 字节流：InputStream(读)，OutputStream（写）。

2. 字符流：Reader（读），Writer（写）。

### **一. 字符流:**

#### Reader  

|--InputStreamReader  

　　 |--FileReader: 专门用于处理文件的字符读取流对象。  

#### Writer

 |--OutputStreamWriter  

　　 |--FileWriter: 专门用于处理文件的字符写入流对象

#### Reader 中的常见的方法：  

1. int read()：  

　　 读取一个字符。返回的是读到的那个字符。如果读到流的末尾，返回 - 1.  

**2. int read(char[])：    **

**　　将读到的字符存入指定的数组中，返回的是读到的字符个数，也就是往数组里装的元素的个数。如果读到流的末尾，返回 - 1.  **

3. close():    

　　读取字符其实用的是 window 系统的功能，就希望使用完毕后，进行资源的释放。

#### Writer 中的常见的方法：  

1，write(ch): 将一个字符写入到流中。  

2，write(char[]): 将一个字符数组写入到流中。

3，write(String): 将一个字符串写入到流中。  

4，flush(): 刷新流，将流中的数据刷新到目的地中，流还存在。  

5，close(): 关闭资源：在关闭前会先调用 flush()，刷新流中的数据去目的地。然流关闭。

#### FileWriter:  

该类没有特有的方法。只有自己的构造函数。  

该类特点在于，  

1，用于处理文本文件。  

2，该类中有默认的编码表，  

3，该类中有临时缓冲。

构造函数：在写入流对象初始化时，必须要有一个存储数据的目的地。

  FileWriter(String filename):   该构造函数做了什么事情呢？  

1，调用系统资源。  

2，在指定位置，创建一个文件。  

 注意：如果该文件已存在，将会被覆盖。  

FileWriter(String filename,boolean append):  

 　　该构造函数：当传入的 boolean 类型值为 true 时，会在指定文件末尾处进行数据的续写。

#### FileReader：  

1，用于读取文本文件的流对象。  

2，用于关联文本文件。

 构造函数：在读取流对象初始化的时候，必须要指定一个被读取的文件。    

如果该文件不存在会发生 FileNotFoundException.  

#### FileReader(String filename);

对于读取或者写入流对象的构造函数，以及读写方法，还有刷新关闭功能都会抛出 IOException 或其子类。

所以都要进行处理，或者 throws 抛出，或者 try、catch 处理。

#### **另一个小细节：  **

**当指定绝对路径时，定义目录分隔符有两种方式：**

**1，反斜线 但是一定要写两个。\\  new FileWriter("c:\\demo.txt");**

**2，斜线  /  写一个即可。 new FileWriter("c:/demo.txt");**

#### **字符流的缓冲区：**

缓冲区的出现提高了对流的操作效率。

原理：其实就是将数组进行封装。

对应的对象：

BufferedWriter：

　　特有方法：

**newLine（）：跨平台的换行符。**

BufferedReader：

　　特有方法：

**readLine（）：一次读一行，到行标记时，将行标记之前的字符数据作为字符串返回。当读到末尾时，返回 null。**

使用缓冲区对象时，要明确，缓冲的存在是为了增强流的功能而存在，所以在简历缓冲区对象时，要现有流对象存在。

其实缓冲内部就是在使用流对象的方法，只不过加入了数组对数据进行了临时存储，为了提高操作数据的效率。

代码上的体现:

**写入缓冲区对象：**

// 建立缓冲区对象必须把流对象作为参数传递给缓冲区的构造函数。

BufferedWriter bw=new BufferedWriter（new FileWriter（“abc.txt”））；

bw.write("abce");// 将数据写入到了缓冲区。

bw.flush();// 对缓冲区的数据进行刷新。将数据刷到目的地中。

bw.close();// 关闭缓冲区，其实关闭的是被包装在内部的流对象。



### **二. 字节流:**

抽象基类: InputStream，OutputStream。

字节流可以操作任何数据。

注意：字符流使用的数组是字符数组，char[] chs ；

　　　字节流使用的数组是字节数组，byte[] bt ；

FileOutputStream fos=new FileOutputStream(“a.txt”)；

fos.write("abcde"); // 直接将数据写入到了目的地。

fos.close();// 只关闭资源。

FileInputSteam fls=new FileInputStream("a.txt");

//fis.available();// 获取关联的文件字节数。如果文件体积不大，可以这样操作。

byte[]buf=new byte[fis.available()];// 创建一个刚刚好的缓冲区。// 但是这有一个弊端，就是文件过大，大小超出 Jvm 的内容空间时，会内存溢出。

fis.read(buf);

System.out.println(new String(buf));

例子:

　　需求: copy 一个图片。

BufferedInputStream bufis=new BufferedInputStream(new FileInputStream("1.jpg"));

BufferedOutputStream bufos=new BufferedOutputStream(new FileOutputStream("2.jpg"));

int by=0;

while(by=bufis.read()!=-1){

　　bufos.write(by);

　　bufos.newLine();

}

bufis.close();

bufos.close();

### **小结:**

目前学习的流对象:

字符流: FileReader  FileWriter  BuffereedReader  BufferedWriter

字节流: FileInputStream  FileOutputStream   BufferedInputStream  BufferedOutputStream

补充：

1. 字节流的 read（）方法读取的是一个字节。为什么返回的不是 byte 类型，而是 int 类型呢？

因为 read 方法读到末尾时返回的是 - 1，而在所操作的数据中很容易出现连续多个 1 的情况，而连续读到 8 个 1，就是 - 1，导致读取会提前停止。所以将读到的一个字节提升为一个 int 类型的数值，但是只保留原字节，并在剩余二进制位补 0。

具体操作是：byte&255 or byte&0xff

2. 对于 write 方法，可以一次写入一个字节，但接收的是一个 int 类型数值。只写入该 int 类型的数值的最低一个字节（8 位）。

简单说：**read 方法对读到的数据进行提升，write 对操作的数据进行转换。**
