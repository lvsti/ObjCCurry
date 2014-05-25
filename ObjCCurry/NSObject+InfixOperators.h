//
//  NSObject+InfixOperators.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.25..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Function;

extern void RegisterInfix(NSString* name, Function* func);

@interface NSObject (InfixOperators)
- (id)_:(const char*)infixOp :(id)arg2;
@end
