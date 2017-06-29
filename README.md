# GCDTestDemo
how to use GCD function
GCD 是 Apple 开发的一个多核编程的解决方法，简单易用，效率高，速度快，基于C语言，更底层更高效，并且不是Cocoa框架的一部分，自动管理线程生命周期（创建线程、调度任务、销毁线程）。

#####基础概念

由于GCD已经实现了自动管理线程生命周期，所以与其说GCD是一个管理线程的框架不如说它是一个管理队列的框架，因为GCD中有两个非常重要的核心概念：任务和队列。

######任务
简要来说就是block中执行的代码

执行任务的两个函数：
```
//同步执行任务
dispatch_sync(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
//异步执行任务
dispatch_async(<#dispatch_queue_t  _Nonnull queue#>, <#^(void)block#>)
```

同步和异步的区别：
- 同步：只在当前线程中执行任务，不具备开启新线程能力
- 异步：可以在新的线程中执行任务，具备开启新线程的能力
（异步执行任务并非一定会开启新线程，下面会举例说明）

######队列
可以理解为存放任务的容器

队列根据任务执行方式分为两种：串行队列和并发队列。

- 串行队列：任务一个接一个的执行
- 并发队列：队列中的任务执行没有先后顺序

关于并行与并发的概念区分：

并行：所有任务在同一时刻开始执行
并发：所有任务在同一时间间隔内开始执行

所以GCD中DISPATCH_QUEUE_CONCURRENT类型的自定义队列以及全局队列严格来说应该算并发队列，因为队列中的任务开始时间是有先后的，并非准确的同时开始，只不过这个先后顺序不受限制且间隔的时间很短。

######GCD中的队列

GCD提供了三种队列：

- 主队列：跟主线程相关的队列，是一个串行队列，队列中所有任务都会在主线程中执行（ps：所有对UI进行的操作必须放在主线程中执行）
- 全局队列：GCD默认提供的一个并发队列，可以设置4种优先级：
```
#define DISPATCH_QUEUE_PRIORITY_HIGH 2
#define DISPATCH_QUEUE_PRIORITY_DEFAULT 0
#define DISPATCH_QUEUE_PRIORITY_LOW (-2)
#define DISPATCH_QUEUE_PRIORITY_BACKGROUND INT16_MIN
```
每当GCD有空闲线程可以执行任务时，GCD总是从优先级高的队列中选取任务来执行。应用程序中任务的优先级完全取决于应用程序本身自己的逻辑，通常情况下，都使用默认优先级，如果有一个任务需要尽快执行，那就将其添加到高优先级队列；如果有一个任务做了最好，不做也没什么关系的话，可以将其添加到低优先级队列甚至是后台优先级队列。

- 自定义队列：自己创建新的队列，可根据需求自行决定是串行还是并发
（自定义并发队列有名称，可以跟踪错误，全局队列则没有这个特性）

######创建队列的方式

创建或获取一个队列主要有以下几种方式：
```
//获取主队列
dispatch_queue_t mainQueue = dispatch_get_main_queue();
    
//获取全局队列 第一个参数为优先级 第二个参数为flag作为保留字段（一般为0）
dispatch_queue_t globalQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
//创建自定义队列 第一个参数为名称 第二个参数为队列类型（串行 DISPATCH_QUEUE_SERIAL／并发 DISPATCH_QUEUE_CONCURRENT）
dispatch_queue_t customQueue = dispatch_queue_create("customQueue", DISPATCH_QUEUE_SERIAL);
```

有了队列，我们就可以使用同步／异步函数向队列中添加任务了。

#####使用方式归纳

GCD根据队列种类及同步异步的调用方式共可以组合出以下几种基础用法：

串行 + 同步
串行 + 异步
并发 + 同步
并发 + 异步
主队列 + 异步
主队列 + 同步

以上几种方式的使用效果，我们用例子来加以说明：

- 串行 + 同步

```
// 串行队列 + 同步
-(void)syncSerialQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```

![串行+同步](http://upload-images.jianshu.io/upload_images/6363544-f31e3fdae1b1c425.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有开启新线程，队列中的任务顺序执行。

- 串行 + 异步

```
// 串行队列 + 异步
-(void)asyncSerialQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.serialQueue", DISPATCH_QUEUE_SERIAL);
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```

![串行+异步](http://upload-images.jianshu.io/upload_images/6363544-af3bc432029f0814.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

开启了一条新的线程，队列中的任务顺序执行，主线程没有被阻塞。

- 并发 + 同步

```
// 并发队列 + 同步
-(void)syncConcurrentQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```


![并发+同步](http://upload-images.jianshu.io/upload_images/6363544-b20e6c1d1a666718.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有开启新的线程，队列中任务顺序执行。

- 并发 + 异步

```
// 并发队列 + 异步
-(void)asyncConcruuentQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_queue_create("com.jyw.concurrentQueue", DISPATCH_QUEUE_CONCURRENT);
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```

![并发+异步](http://upload-images.jianshu.io/upload_images/6363544-a063047299cdf72f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

出现了很有意思的现象，GCD开辟了多个新的线程，并且这些线程会重用，队列中的任务执行没有先后顺序，每次调用输出结果都会不一样，主线程没有被阻塞，这也证实了GCD可以自动管理线程生命周期，不需要开发者手动去管理线程。

- 主队列 + 异步

```
// 主队列 + 异步
-(void)asyncMainQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (int i=1; i<=10; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```
![主队列+异步](http://upload-images.jianshu.io/upload_images/6363544-e691802f4c62b41f.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有开启新的线程，队列中的任务顺序执行，但主线程没有被阻塞。这里就是异步调用不开新线程的一个特例。

- 主队列 + 同步

```
// 主队列 + 同步
-(void)syncMainQueue
{
    NSLog(@"begin");
    
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    for (int i=1; i<=10; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%@ task %d",[NSThread currentThread], i);
        });
    }
    
    NSLog(@"end");
}
```

![主队列+同步](http://upload-images.jianshu.io/upload_images/6363544-9d7a156afe0121a2.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

有趣的现象又出现了，程序卡在了同步执行任务处，出现了线程死锁。

######小结

根据前面的测试结果，我们得出以下结论：

串行+同步：不开辟新线程，队列中任务顺序执行
串行+异步：开辟一条新线程，队列中任务顺序执行
并发+同步：不开辟新线程，队列中任务顺序执行
并发+异步：开辟多条新线程，且线程可重用，队列中任务无序执行
主线程+异步：不开辟新线程，队列中任务顺序执行
主线程+同步：线程死锁

#####关于线程死锁（DeadLock）
我们在主线程中同步向主队列添加任务，这些任务被添加到了队列末尾，因为主队列是串行，只有前面的任务执行完才能执行添加的任务，也就是需要等待NSLog(@"end")执行完；而由于同步的特性，主线程需要等待添加队列中的任务执行完才会执行NSLog(@"end")，这样两边相互等待就一直卡在这里，这种情况称为线程死锁（Deadlock）

由于主队列是串行队列，我们在串行队列中同步向当前队列添加新任务会造成线程死锁，那么在并发队列中会不会出现这种问题呢？我们来试试看：

```
//向并发队列中同步添加任务
- (void)deadLockTest
{
    dispatch_queue_t customQueue = dispatch_queue_create("customQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(customQueue, ^{
        NSLog(@"begin");
        
        for (int i=1; i<=10; i++) {
            dispatch_sync(customQueue, ^{
                NSLog(@"%@ task %d",[NSThread currentThread], i);
            });
        }
        
        NSLog(@"end");
    });
    
}
```

![测试结果](http://upload-images.jianshu.io/upload_images/6363544-a83c09bb846514f6.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有出现死锁，队列中的任务顺序执行了。看上去在并发队列中同步添加任务好像不会造成死锁。

为了确定这个观点，我们再多做一些测试。

由于我们在主线程中异步向并发队列中添加了任务，队列中任务的执行没有先后顺序，根据前面的测试结果，当我们把异步改成同步时，并发队列中的任务也是顺序执行的，我们再试一次，将dispatch_async改成dispatch_sync：

```
//向并发队列中同步添加任务
- (void)deadLockTest
{
    dispatch_queue_t customQueue = dispatch_queue_create("customQueue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_sync(customQueue, ^{
        NSLog(@"begin");
        
        for (int i=1; i<=10; i++) {
            dispatch_sync(customQueue, ^{
                NSLog(@"%@ task %d",[NSThread currentThread], i);
            });
        }
        
        NSLog(@"end");
    });
    
}
```


![测试结果](http://upload-images.jianshu.io/upload_images/6363544-480a594dd29e7618.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

没有出现死锁，区别仅仅是没有开新线程，这也验证了同步执行不具备开启新线程的能力。

当然后面对自定义串行队列也做了同样的测试，结果是不管是同步还是异步都出现了线程死锁，由于篇幅关系这里就不给出示例代码了，大家可以自己进行验证。

由此我们可以确定，只有在串行队列中同步向当前队列添加任务时（主线程中同步执行主队列、自定义串行队列中同步执行当前队列），会出现线程死锁，与该队列本身是被同步还是异步执行无关。

（对以上测试如存有异议，可以亲自验证一遍，如果出现了不同的结果，欢迎在下方留言讨论）

#####线程间通讯

GCD常用的线程间通讯方式就是嵌套使用异步函数，具体来说就像这样：
```
dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 处理耗时的操作

    dispatch_async(dispatch_get_main_queue(), ^{
        // 回到主线程刷新UI
    });
});
```

#####GCD的一些其他用途

######队列组

队列组可以用来解决多个线程同步的问题（如多图下载，将10张图片下载完成后回到主线程拼成一张图片显示）

```
//创建队列组
dispatch_group_t group =  dispatch_group_create();

dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});

dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    // 执行1个耗时的异步操作
});

dispatch_group_notify(group, dispatch_get_main_queue(), ^{
    // 等前面的异步操作都执行完毕后，回到主线程...
});
```

######快速迭代

这个用途和for循环类似，不同的地方是：for循环是按顺序来遍历，而GCD的快速迭代可以做到异步无序遍历，这在遍历一个元素数量很多的数组时可以加快遍历速度

```
- (void)gcdApplyTest
{
    dispatch_apply(10, dispatch_get_global_queue(0, 0), ^(size_t i) {
        NSLog(@"output %ld",i);
    });
}
```


![快速迭代](http://upload-images.jianshu.io/upload_images/6363544-166f8a9a40f188b8.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

######一次性执行方法

GCD提供了一个函数可以保证某段代码在程序运行中之执行一次，通常在创建单例时会用到。

```
static dispatch_once_t onceToken;
dispatch_once(&onceToken, ^{
    // 只执行1次的代码
});
```

######延时执行

GCD提供了一个函数可以延时执行一段代码

```
dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    // 1秒后执行这里的代码
    NSLog(@"do something");
});
```

######栅栏方法

我们有时需要异步执行两组操作，而且第一组操作执行完之后，才能开始执行第二组操作。这样我们就需要一个相当于栅栏一样的一个方法将两组异步执行的操作组给分割起来，当然这里的操作组里可以包含一个或多个任务。这就需要用到dispatch_barrier_async方法在两个操作组间形成栅栏。

```
-(void)barrierTest
{
    dispatch_queue_t queue = dispatch_queue_create("barrierTest", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 1");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 2");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 3");
    });
    
    dispatch_barrier_async(queue, ^{
        sleep(2);
        NSLog(@"hold on");
    });
    
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 4");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 5");
    });
    
    dispatch_async(queue, ^{
        NSLog(@"test -> 6");
    });
    
}
```

![栅栏方法](http://upload-images.jianshu.io/upload_images/6363544-c6234a750fcd991b.png?imageMogr2/auto-orient/strip%7CimageView2/2/w/1240)

######注意点

使用这个函数的前提是必须使用异步执行的自定义并发队列，全局队列无法使用，串行或同步执行时使用这个函数没有意义。

dispatch_barrier_async与dispatch_barrier_sync的区别：

dispatch_barrier_sync会阻塞当前线程，队列中的任务需要等待barrier中的任务执行完才能继续执行

dispatch_barrier_async不会阻塞当前线程，队列中的任务可继续执行，不需要等待barrier中的任务执行完

#####总结

- 同步不能开启新线程，会阻塞当前线程，且同步执行的队列都是串行，不管队列的类型是什么
- 异步可以开启新线程，不会阻塞当前线程，异步执行的队列会根据队列的类型决定是串行还是并发
- 同步执行当前队列，如果队列类型为串行，会造成线程死锁，如果是并发则不会
- 异步执行主队列，是一种特殊的情况，不会开启新线程，队列中的任务串行，且不会阻塞主线程

关于GCD的相关知识点先记录到这里，以后出现的新的问题会不定期更新。
