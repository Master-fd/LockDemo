#多线程互斥与同步  
##前言
*因为，在iOS中，使用atomic的方式，只是针对setter和getter方法分别做了加锁的操作而已，所以无法做到真正的多线程安全，而且还消耗了不少的性能*  
##多线程同步锁  
####synchronizad：block的方式进行加锁  
####NSLook：一般都在多线程之间进行加锁  
####NSCondition：条件锁，需要达到加锁条件才加锁
####NSRecursiveLock：递归锁，在递归操作的时候，不会导致死锁崩溃