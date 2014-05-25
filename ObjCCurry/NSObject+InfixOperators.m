//
//  NSObject+InfixOperators.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.25..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "NSObject+InfixOperators.h"
#import "Function.h"


static NSMutableDictionary* infixOperators = nil;

void RegisterInfix(NSString* name, Function* func) {
    assert(!infixOperators[name]);
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        infixOperators = [NSMutableDictionary new];
    });

    [infixOperators setObject:func forKey:name];
}


@implementation NSObject (InfixOperators)
- (id)_:(const char*)infixOp :(id)arg2 {
    Function* func = infixOperators[@(infixOp)];
    return [func :self :arg2];
}
@end
