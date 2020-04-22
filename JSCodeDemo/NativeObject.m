//
//  NativeObject.m
//  JSCodeDemo
//
//  Created by SZOeasy on 2020/4/22.
//  Copyright © 2020 ycong. All rights reserved.
//

#import "NativeObject.h"

@implementation NativeObject

- (void)play {
    NSLog(@"%@玩",_name);
}

- (void)playWithGame:(NSString *)game time:(NSString *)time {
    NSLog(@"%@在%@玩%@",_name,time,game);
}

@end
