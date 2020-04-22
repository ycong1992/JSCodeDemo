//
//  ViewController.m
//  JSCodeDemo
//
//  Created by Ycong on 2020/4/22.
//  Copyright © 2020 ycong. All rights reserved.
//

#import "ViewController.h"
#import "JSProtocol.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // https://www.jianshu.com/p/bd7dfd8c9917
    [self getJSVar];
    [self ocCallJSFunc];
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
@end
