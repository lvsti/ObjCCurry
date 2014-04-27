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
    f.invocation = [NSInvocation invocationWithMethodSignature:[target methodSignatureForSelector:selector]];
    [f.invocation setTarget:target];
    [f.invocation setSelector:selector];
    
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
    NSMethodSignature* ms = [_invocation methodSignature];
    
    [self.args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        const char* argType = [ms getArgumentTypeAtIndex:idx + 2];
        
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
            
            NSUInteger size = 0;
            NSGetSizeAndAlignment(argType, &size, NULL);
            void* buf = malloc(size);
            [(NSValue*)obj getValue:buf];
            [_invocation setArgument:buf atIndex:idx + 2];
            free(buf);
        }
    }];

    [_invocation invoke];

    id retval = nil;
    const char* retType = [ms methodReturnType];

    if (retType[0] != 'v') {
        if (retType[0] == '@') {
            CFTypeRef ref;
            [_invocation getReturnValue:&ref];
            if (ref) {
                CFRetain(ref);
            }
            retval = (__bridge_transfer id)ref;
        } else {
            void* buf = malloc([ms methodReturnLength]);
            [_invocation getReturnValue:buf];
            retval = [NSValue valueWithBytes:buf objCType:retType];
            free(buf);
        }
    }
    
    return retval;
}



@end
