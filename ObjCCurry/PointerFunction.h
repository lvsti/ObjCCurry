//
//  PointerFunction.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.28..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "Function.h"
#import "metamacros.h"


#define __FPTR_ENC(idx, arg)    , @encode(arg)
#define __FPTR_S(idx, arg)      "%s"

#define FPTR_SIG(...)   [[NSString stringWithFormat:@metamacro_foreach(__FPTR_S, , __VA_ARGS__) metamacro_foreach(__FPTR_ENC, , __VA_ARGS__)] UTF8String]


@interface PointerFunction : Function

+ (instancetype)fromPointer:(void*)ptr objCTypes:(const char*)types;

@end
