//
//  ViewController.m
//  JSCodeDemo
//
//  Created by Ycong on 2020/4/22.
//  Copyright © 2020 ycong. All rights reserved.
//

#import "ViewController.h"
#import "NativeObject.h"
#import "JSProtocol.h"

#import <objc/message.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // https://www.jianshu.com/p/bd7dfd8c9917
//    [self getJSVar];
//    [self ocCallJSFunc];
//    [self jsCallOCBlock1WithNoneArguments];
//    [self jsCallOCBlockWithArguments];
    [self jsCallOCCustomClass];
    [self jsCallOCSystemClass];
}

#pragma mark - OC调用JS
// 获取定义在JS中的变量，直接通过OC修改JS中变量的值
- (void)getJSVar {
    // JS代码
    NSString *jsCode = @"var arr = [1,2,3]";
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // 执行JS代码
    [ctx evaluateScript:jsCode];
    // 因为变量直接定义在JS中，所以可以直接通过JSContext获取，根据变量名称获取，相当于字典的Key
    // 只有先执行JS代码，才能获取变量
    JSValue *jsArr = ctx[@"arr"];
    NSLog(@"%@", jsArr);
    //修改变量
    jsArr[0] = @5;
    // 打印结果：5,2,3
    NSLog(@"%@", jsArr);
}
// 获取定义在JS中的方法，并且调用
- (void)ocCallJSFunc {
    NSString *jsCode = @"function hello(say){return say;}";
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // 因为方法直接定义在JS中，所以可以直接通过JSContext获取，根据方法名称获取，相当于字典的Key
    // 执行JS代码
    [ctx evaluateScript:jsCode];
    // 获取JS方法，只有先执行JS代码，才能获取
    JSValue *hello = ctx[@"hello"];
    // OC调用JS方法，获取方法返回值
    JSValue *result = [hello callWithArguments:@[@"你好"]];
    // 打印结果：你好
    NSLog(@"%@",result);
}
#pragma mark - JS调用OC中的block
/**
 本质:一开始JS中并没有OC的block，所以没法直接调用OC的block，需要把OC的block，在JS中生成方法，然后在通过JS调用。
 步骤：
 1.创建JS运行环境
 2.在JS中生成对应的OC代码
 3.使用JS调用，在JS环境中生成的block方法，就能调用到OC的block中.
 */
// JS调用OC中不带参数的block
- (void)jsCallOCBlock1WithNoneArguments {
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // JS调用Block方式
    // 由于JS本身没有OC这个代码，需要给JS中赋值，就会自动生成右边的代码.
    // 相当于在JS中定义一个叫eat的方法，eat的实现就是block中的实现，只要调用eat,就会调用block
    ctx[@"eat"] = ^(){
        NSLog(@"吃东西");
    };
    // JS执行代码，就会直接调用到block中
    NSString *jsCode = @"eat()";
    [ctx evaluateScript:jsCode];
}
// JS调用OC中带参数的block
- (void)jsCallOCBlockWithArguments {
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // 2.调用带有参数的block
    // 还是一样的写法，会在JS中生成eat方法，只不过通过[JSContext currentArguments]获取JS执行方法时的参数
    ctx[@"eat"] = ^(){
        // 获取JS调用参数
        NSArray *arguments = [JSContext currentArguments];
        NSLog(@"吃什么？%@",arguments[0]);
    };
    // JS执行代码,调用eat方法，并传入参数面包
    NSString *jsCode = @"eat('面包')";
    [ctx evaluateScript:jsCode];
}
#pragma mark - JS调用OC自定义类
/**
 本质:一开始JS中并没有OC的类，需要先在JS中生成OC的类，然后在通过JS调用。
 步骤:
 1.OC类必须遵守JSExport协议，只要遵守JSExport协议，JS才会生成这个类
 2.但是还不够，类里面有属性和方法，也要在JS中生成
 3.JSExport本身不自带属性和方法，需要自定义一个协议，继承JSExport，在自己的协议中暴露需要在JS中用到的属性和方法
 4.这样自己的类只要继承自己的协议就好，JS就会自动生成类，包括自己协议中声明的属性和方法
 */
// JS调用OC自定义类
- (void)jsCallOCCustomClass {
    // 创建NativeObject对象
    NativeObject *obj = [[NativeObject alloc] init];
    obj.name = @"test";
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // 会在JS中生成NativeObject对象，并且拥有所有值
    // 前提：NativeObject对象必须遵守JSExport协议，
    ctx[@"obj"] = obj;
    // 执行JS代码
    // 注意：这里的obj一定要跟上面声明的一样，因为生成的对象是用obj引用
    NSString *jsCode1 = @"obj.play()";
    NSString *jsCode2 = @"obj.playGame('德州扑克','晚上')";
    [ctx evaluateScript:jsCode1];
    [ctx evaluateScript:jsCode2];
}
/**
 JS调用OC系统类:
 1.和调用自定义类一样，也要弄个自定义协议继承JSExport，描述需要暴露哪些属性（想要把系统类的哪些属性暴露，就在自己的协议声明）
 2.通过runtime,给类添加协议
 */
- (void)jsCallOCSystemClass {
    // 给系统类添加协议
    class_addProtocol([UILabel class], @protocol(UILabelJSExport));
    // 创建UILabel
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 100, 100)];
    [self.view addSubview:label];
    // 创建JS运行环境
    JSContext *ctx = [[JSContext alloc] init];
    // 就会在JS中生成label对象，并且用laebl引用
    ctx[@"label"] = label;
    // 利用JS给label设置文本内容
    NSString *jsCode = @"label.text = 'Oh Year'";
    [ctx evaluateScript:jsCode];
}
@end
