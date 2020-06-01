---
title: lock锁
date: 2019-07-11 23:05:05
tags: java
categories: java
---
###lock锁基础
```java
package cn.wang.d07_thread.t02_safe;

import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

class pay implements Runnable{
    private int piao = 100;
	//创建锁对象
    Lock l = new ReentrantLock();
    @Override
    public void run() {
        while (true) {
			//调用锁方法
            l.lock();
            if (piao > 0) {
                try {
                    Thread.sleep(100);
                    System.out.println(Thread.currentThread().getName() + "-->" + piao--);
                } catch (InterruptedException e) {
                    e.printStackTrace();
                } finally {
					//在finally解锁，可以使无论是否异常都解锁
                    l.unlock();
                }
            }
        }
    }
}

public class lock_test {
    public static void main(String[] args) {
        pay piao = new pay();
        Thread t1 = new Thread(piao);
        Thread t2 = new Thread(piao);
        Thread t3 = new Thread(piao);
        t1.start();
        t2.start();
        t3.start();
    }
}

```