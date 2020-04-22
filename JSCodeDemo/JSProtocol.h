//
//  JSProtocol.h
//  JSCodeDemo
//
//  Created by SZOeasy on 2020/4/22.
//  Copyright © 2020 ycong. All rights reserved.
//

#import <JavaScriptCore/JavaScriptCore.h>

#ifndef JSProtocol_h
#define JSProtocol_h

@protocol UILabelJSExport <JSExport>

@property (nonatomic, strong) NSString *text;

@end

#endif /* JSProtocol_h */
