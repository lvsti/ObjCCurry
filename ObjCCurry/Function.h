//
//  Function.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Function : NSObject <NSCopying>

@property (nonatomic, assign, readonly) NSInteger argCount;
@property (nonatomic, copy, readonly) NSArray* args;

+ (instancetype)fromTarget:(id)target selector:(SEL)selector;
+ (instancetype)fromBlock:(id)block;
+ (instancetype)fromPointer:(void*)ptr objCTypes:(const char*)types;

- (instancetype)initWithArgCount:(NSInteger)argCount
                            args:(NSArray*)args;

+ (id)nullArg;

- (id):(id)arg;
- (id):(id)arg1 :(id)arg2;
- (id):(id)arg1 :(id)arg2 :(id)arg3;
- (id):(id)arg1 :(id)arg2 :(id)arg3 :(id)arg4;

- (id)invoke;

@end
