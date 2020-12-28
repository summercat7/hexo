---
title: IO与NIO的区别
date: 2020-12-23 16:49:13
categories: java
tags: java
---

 **JAVA NIO vs IO** 

 Java NIO和IO的主要区别

| IO         | NIO        |
| ---------- | ---------- |
| 面向Stream | 面向Buffer |
| 阻塞IO     | 非阻塞IO   |
|            | Selectors  |

BIO网络模型：

![img](BIO模型.png)

![img](NIO模型.png)

**1、面向流与面向缓冲**

   Java IO和NIO之间第一个最大的区别是，IO是面向流的，NIO是面向缓冲区的。 Java IO面向流意味着每次从流中读一个或多个字节，直至读取所有字节，它们没有被缓存在任何地方。此外，它不能前后移动流中的数据。如果需要前后移动从流中读取的数据，需要先将它缓存到一个缓冲区。 Java NIO的缓冲导向方法略有不同。数据读取到一个它稍后处理的缓冲区，需要时可在缓冲区中前后移动。这就增加了处理过程中的灵活性。但是，还需要检查是否该缓冲区中包含所有您需要处理的数据。而且，需确保当更多的数据读入缓冲区时，不要覆盖缓冲区里尚未处理的数据。

**2、阻塞与非阻塞IO**

   Java IO的各种流是阻塞的。这意味着，当一个线程调用read() 或 write()时，该线程被阻塞，直到有一些数据被读取，或数据完全写入。该线程在此期间不能再干任何事情了。Java NIO的非阻塞模式，使一个线程从某通道发送请求读取数据，但是它仅能得到目前可用的数据，如果目前没有数据可用时，就什么都不会获取，而不是保持线程阻塞，所以直至数据变的可以读取之前，该线程可以继续做其他的事情。 非阻塞写也是如此。一个线程请求写入一些数据到某通道，但不需要等待它完全写入，这个线程同时可以去做别的事情。 线程通常将非阻塞IO的空闲时间用于在其它通道上执行IO操作，所以一个单独的线程现在可以管理多个输入和输出通道（channel）。

**3、选择器（Selectors）**

   Java NIO的选择器允许一个单独的线程来监视多个输入通道，你可以注册多个通道使用一个选择器，然后使用一个单独的线程来“选择”通道：这些通道里已经有可以处理的输入，或者选择已准备写入的通道。这种选择机制，使得一个单独的线程很容易来管理多个通道。

 **网络编程样例**

***1、BIO***

服务端线程池

```java
import java.util.concurrent.ArrayBlockingQueue;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class HandlerSocketServerPool {
    // 用于存储socket线程的线程池
    private ExecutorService executor;

    /**
     *     public ThreadPoolExecutor(int corePoolSize,
     *                               int maximumPoolSize,
     *                               long keepAliveTime,
     *                               TimeUnit unit,
     *                               BlockingQueue<Runnable> workQueue)
     */
    public HandlerSocketServerPool(int maxThreadNum, int queueSize) {
        executor = new ThreadPoolExecutor(3, maxThreadNum, 120,
                TimeUnit.SECONDS, new ArrayBlockingQueue<Runnable>(queueSize));
    }

    // 提交任务到线程池队列里
    public void execute(Runnable target) {
        executor.execute(target);
    }
}
```

服务端消息处理

```java
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.Socket;

public class ServerRunnableTarget implements Runnable {
    private Socket socket;

    public ServerRunnableTarget(Socket socket) {
        this.socket = socket;
    }

    @Override
    public void run() {
        // 处理接收到客服端socket通信请求
        try {
            // 1、从socket管道中获取一个字节输入流
            InputStream is = socket.getInputStream();
            // 2、把字节输入流包装成一个缓冲字符输入流
            BufferedReader br = new BufferedReader(new InputStreamReader(is));
            String msg;
            while ((msg = br.readLine()) != null) {
                System.out.println("服务端收到：" + msg);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

服务端

```java
import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;

public class Server {
    public static void main(String[] args) {
        try {
            // 1、注册接口
            ServerSocket ss = new ServerSocket(9999);
            // 2、初始化线程池
            HandlerSocketServerPool pool = new HandlerSocketServerPool(3,10);
            // 定义一个循环接收客服端Socket链接请求
            while (true) {
                Socket socket = ss.accept();
                // 3、把socket对象提交给线程池
                Runnable target = new ServerRunnableTarget(socket);
                pool.execute(target);
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```

客户端

```java
import java.io.IOException;
import java.io.PrintStream;
import java.net.Socket;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) {
        try {
            // 1、请求与服务端的Socket对象链接
            Socket socket = new Socket("127.0.0.1", 9999);
            // 2、得到一个打印流
            PrintStream ps = new PrintStream(socket.getOutputStream());
            // 3、使用循环不断的发送信息给服务端接收
            Scanner sc = new Scanner(System.in);
            while (true) {
                System.out.println("请输入发送内容：");
                String msg = sc.nextLine();
                ps.println(msg);
                ps.flush();
            }
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
```



***2、NIO***

服务端

```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.*;
import java.util.Iterator;

public class Server {
    public static void main(String[] args) throws IOException {
        //    1、获取通道
        ServerSocketChannel ssChannel = ServerSocketChannel.open();
        //    2、切换为非阻塞模式
        ssChannel.configureBlocking(false);
        //    3、绑定连接的端口
        ssChannel.bind(new InetSocketAddress(9999));
        //    4、获取选择器Selector
        Selector selector = Selector.open();
        //    5、将通道都注册到选择器上，并制定监听接收事件
        ssChannel.register(selector, SelectionKey.OP_ACCEPT);
        //    6、使用Selector选择器轮询已经就绪好的事件
        while (selector.select() > 0 ) {
            //    7、获取选择器中的所有注册的通道中就绪好的事件
            Iterator<SelectionKey> it = selector.selectedKeys().iterator();
            //    8、开始遍历这些就绪好的事件
            while (it.hasNext()) {
                SelectionKey sk = it.next();
                //    9、判断这个事件具体是什么
                if (sk.isAcceptable()) {
                    //    10、直接获取当前接入的客户端通道
                    SocketChannel sChannel = ssChannel.accept();
                    //    11、切换为非阻塞模式
                    sChannel.configureBlocking(false);
                    //    12、将本客服端通道注册到选择器中
                    sChannel.register(selector, SelectionKey.OP_READ);
                } else if (sk.isReadable()) {
                    //    13、获取当前选择器上的读就绪事件
                    SocketChannel sChannel = (SocketChannel) sk.channel();
                    //    14、数据读取
                    ByteBuffer buffer = ByteBuffer.allocate(1024);
                    int len;
                    while ((len = sChannel.read(buffer)) > 0) {
                        buffer.flip();
                        String string = new String(buffer.array(), 0, len);
                        System.out.println(string);
                        //    15、清除之前缓存区的数据
                        buffer.clear();
                    }
                }
                //    处理完毕之后需要移除当前事件
                it.remove();
            }
        }
    }
}
```

客户端

```java
import java.io.IOException;
import java.net.InetSocketAddress;
import java.nio.ByteBuffer;
import java.nio.channels.SocketChannel;
import java.util.Scanner;

public class Client {
    public static void main(String[] args) throws IOException {
        //    1、获取通道
        SocketChannel sChannel = SocketChannel.open(new InetSocketAddress("127.0.0.1",9999));
        //    2、设置为非阻塞模式
        sChannel.configureBlocking(false);
        //    3、分配指定缓冲区大小
        ByteBuffer buffer = ByteBuffer.allocate(1024);
        //    4、发送数据给服务器
        Scanner sc = new Scanner(System.in);
        while (true) {
            System.out.println("请输入发送内容：");
            String s = sc.nextLine();
            buffer.clear();
            buffer.put(s.getBytes());
            buffer.flip();
            sChannel.write(buffer);
        }
    }
}
```

