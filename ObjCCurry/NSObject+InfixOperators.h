//
//  NSObject+InfixOperators.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.25..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Function;

#define _(op)    _:(#op) :
#define OP(op)   InfixForName(@(#op))

extern void RegisterInfix(NSString* name, Function* func);
extern Function* InfixForName(NSString* name);

@interface NSObject (InfixOperators)
- (id)_:(const char*)infixOp :(id)arg2;
@end
