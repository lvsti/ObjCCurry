//
//  MethodFunction.m
//  ObjCHOF
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "MethodFunction.h"

@interface MethodFunction ()

@property (nonatomic, strong) NSInvocation* invocation;

@end


@implementation MethodFunction

+ (instancetype)fromTarget:(id)target selector:(SEL)selector {
    assert(target);
    assert(selector);
    NSString* selName = NSStringFromSelector(selector);
    NSInteger argCount = [[selName componentsSeparatedByString:@":"] count] - 1;
    assert(argCount > 0);
    
    MethodFunction* f = [[MethodFunction alloc] initWithArgCount:argCount args:nil];
    if (f) {
        f.invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
        [f.invocation setTarget:target];
        [f.invocation setSelector:selector];
    }
    
    return f;
}

- (id)copyWithZone:(NSZone*)zone {
    MethodFunction* f = [super copyWithZone:zone];
    f.invocation = [NSInvocation invocationWithMethodSignature:[_invocation methodSignature]];
    [f.invocation setTarget:_invocation.target];
    [f.invocation setSelector:_invocation.selector];
    return f;
}

- (id)invoke {
    assert([self.args count] == self.argCount);
    
    [self.args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        const char* argType = [[_invocation methodSignature] getArgumentTypeAtIndex:idx + 2];
        
        if (argType[0] == '@' || argType[0] == '^') {
            // object or pointer type
            if (obj == [Function nullArg]) {
                obj = nil;
            }
            [_invocation setArgument:&obj atIndex:idx + 2];
        } else {
            // it's not NSObject, assuming a wrapped NSValue of the same kind
            assert([obj isKindOfClass:[NSValue class]]);
            assert(!strcmp([obj objCType], argType));
            
            unsigned char buf[16];
            [(NSValue*)obj getValue:buf];
            [_invocation setArgument:buf atIndex:idx + 2];
        }
    }];

    [_invocation invoke];

    id retval = nil;
    void* buf = malloc([[_invocation methodSignature] methodReturnLength]);
    [_invocation getReturnValue:buf];

    if (!strcmp([[_invocation methodSignature] methodReturnType], @encode(id))) {
        memcpy((void*)&retval, buf, sizeof(id));
    } else {
        retval = [NSValue valueWithBytes:buf objCType:[[_invocation methodSignature] methodReturnType]];
    }
    
    free(buf);

    return retval;
}



@end
