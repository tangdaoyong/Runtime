#Runtime

###OC

###Swift

> [测试代码](https://github.com/tangdaoyong/Runtime)
> [参考文章](https://mp.weixin.qq.com/s?__biz=MzA4MjA0MTc4NQ==&mid=403068491&idx=1&sn=c95f07e3d38c92ba56933502cc3e1800#rd)

* 纯Swift类的函数调用已经不再是Objective-c的运行时发消息，而是类似C++的vtable，在编译时就确定了调用哪个函数，所以没法通过runtime获取方法、属性。
* 继承自基类NSObject，而Swift为了兼容Objective-C，凡是继承自NSObject的类都会保留其动态性，所以我们能通过runtime拿到他的方法。
* 从Objective-c的runtime 特性可以知道，所有运行时方法都依赖TypeEncoding，也就是`method_getTypeEncoding`返回的结果，他指定了方法的参数类型以及在函数调用时参数入栈所要的内存空间，没有这个标识就无法动态的压入参数（比如testReturnVoidWithaId: Optional("v24@0:8@16") Optional("v")，表示此方法参数共需24个字节，返回值为void，第一个参数为id，第二个为selector，第三个为id），而Character和Tuple是Swift特有的，无法映射到OC的类型，更无法用OC的typeEncoding表示，也就没法通过runtime获取了。

#### @objc

+ @objc是用来将Swift的API导出给Objective-C和Objective-C runtime使用的，如果你的类继承自Objective-c的类（如NSObject）将会自动被编译器插入@objc标识。(纯Swift在属性和方法前面添加@objc可以被runtime获取到，如果含有Swift特定的参数，如：tuple则添加@objc时会报错)

#### dynamic

- 加了@objc标识的方法、属性无法保证都会被运行时调用，因为Swift会做静态优化。要想完全被动态调用，必须使用dynamic修饰。使用dynamic修饰将会隐式的加上@objc标识。(纯Swift方法添加dynamic可以成功的进行runtime方法替换)

#### Objective-C获取Swift tuntime信息

* Swift中的TestSwiftVC类在OC中的类名已经变成TestSwift.TestSwiftVC，即规则为SWIFT_MODULE_NAME.类名称，在普通源码项目里SWIFT_MODULE_NAME即为ProductName，在打好的Cocoa Touch Framework里为则为导出的包名。