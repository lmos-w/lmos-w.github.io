---
title: 缓存头 Cache-Control 的含义和使用
date: 2019-11-18 23:07:13
tags: Cache
categories: HTTP
---
### 特性：
> 以下这些头只是限制性的，声明性的作用，没有强制约束力。只是为代理服务器设置了这些头，要求按照规范去做，但是完全可以不按照这个规范做。
<!--more-->

- ##### 可缓存性

 *  public  
    在 http 请求返回的过程当中，在 Cache-Control 设置了 public 值，代表这个 http 请求返回的内容所经过的任何路径当中，包括一些中间的 http 代理服务器以及我们发出请求的客户端浏览器，都可以进行对返回内容的缓存操作：就是把这份数据存在本地，下次直接读这个缓存，不需要到返回这个内容的服务器上面重新进行操作返回内容。可缓存性是指哪些地方可以执行这些缓存。
 *  private  
    只要发起请求的浏览器才可以缓存
 *  no-cache  
    任何节点都不可以缓存。可以在本地服务器缓存，每次发起请求都需要去服务器验证，如果服务器说可以使用缓存，才能使用缓存。也就是说需要经过服务器验证的。

- ##### 到期

 *  max-age=<seconds>  
    缓存有效期
 *  s-maxage=<seconds>  
    代替上面的 max-age，但是只有在代理服务器里面才会生效
 *  max-stale=<seconds>  
    max-stale：浏览器用不到，浏览器并不会主动去设置这个头，只有在发起端设置是有用的，服务端返回的内容中设置没有用。发起请求方，主动带的头，在 max-age 过期之后，如果我们返回的资源中有这个 max-stale 设置，还可以使用过期的缓存，而不需要去服务器请求新的内容。

- ##### 重新验证

 *  must-revalidate  
    设置了 max-age，如果缓存已经过期了，必须去原服务端发送这个请求，重新获取数据，来验证内容是否真的过期了，而不能直接使用本地缓存。
 *  proxy-revalidate  
    用在指定缓存服务器，在过期的时候必须去原服务器重新请求一遍，而不能直接使用本地缓存。

- ##### 其他

 *  no-store  
    本地和代理服务器不可以存储这个缓存，永远要去服务器拿新的 body 的内容。
 *  no-transform  
    不允许代理服务器不要改动返回的内容。  

### 浏览器中用到的:

- ##### 可缓存性

 *  public
 *  private
 *  no-cahe

- ##### 到期

 *  max-age=<seconds>
 *  s-maxage=<seconds>
 *  max-stale=<seconds>

- ##### 重新验证

 *  must-revalidate

 *  设置请求文件缓存时间  
    `'Cache-Control': 'max-age=20'`

```
http.createServer(function (request, response) {
  console.log('request come', request.url)

  if (request.url === '/') {
    const html = fs.readFileSync('test.html', 'utf8')
    response.writeHead(200, {
      'Content-Type': 'text/html'
    })
    response.end(html)
  }

  if (request.url === '/script.js') {
    response.writeHead(200, {
      'Content-Type': 'text/javascript',
      // 设置到期时间
      'Cache-Control': 'max-age=20'
    })
    response.end('console.log("script loaded")')
  }
}).listen(8888)
```

问题 ： 这时如果改变了服务器返回的结果，刷新，发现返回的还是之前的结果，并不是最新的。这是因为服务器端更新了之后，客户端还是请求的缓存的资源，这样想要更新一个应用的时候，客户端根本触及不到了，一般 max-ag 可能会设置一年。  
解决：在构建流程的时候，把打包完成的 JS 文件名根据内容的 hash 结果，加上一串 hash 码，这串 hash 码是因为根据打包完成的 js 以及其他静态资源的文件内容进行性的 hash 计算，所以如果这些静态文件内容没有变，hash 码就不变，反应到 web 页面上就是 url 没有变，那么就可以使用静态缓存；而如果你的内容有变，hash 码就会变化，嵌入在 html 的 url 路径就有变化，有了变化之后发起的请求就是一个新的静态资源请求而不是之前缓存的请求。这样就可以达到缓存的目的。
