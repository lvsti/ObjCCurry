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
    assert(name);
    assert(func);
    assert(!infixOperators[name]);
    [infixOperators setObject:func forKey:name];
}

Function* InfixForName(NSString* name) {
    assert(name);
    Function* func = infixOperators[name];
    assert(func);
    return func;
}


@implementation NSObject (InfixOperators)

+ (void)load {
    infixOperators = [NSMutableDictionary new];
}

- (id)_:(const char*)infixOp :(id)arg2 {
    assert(infixOp && *infixOp != 0);
    Function* func = InfixForName(@(infixOp));
    return [func :self :arg2];
}
@end
