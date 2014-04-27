//
//  BlockFunction.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "BlockFunction.h"
#import "MABlockForwarding.h"


@interface BlockFunction ()

@property (nonatomic, copy) id (^block)(id, ...);

@end


@implementation BlockFunction

+ (instancetype)fromBlock:(id)block {
    NSMethodSignature* ms = SignatureForBlock(block);
    NSInteger argCount = [ms numberOfArguments] - 1;
    assert(argCount > 0);
    
    BlockFunction* f = [[BlockFunction alloc] initWithArgCount:argCount
                                                          args:nil];
    f.block = block;
    
    return f;
}

- (id)copyWithZone:(NSZone*)zone {
    BlockFunction* f = [super copyWithZone:zone];
    f.block = _block;
    return f;
}

- (id)invoke {
    assert([self.args count] == self.argCount);
    assert(_block);

    NSMethodSignature* ms = SignatureForBlock(_block);
    __block id retval = nil;
    
    BlockInterposer invWrapper = ^(NSInvocation *inv, void (^call)()) {
        [self.args enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            const char* argType = [ms getArgumentTypeAtIndex:idx + 1];
            
            if (!strcmp(argType, @encode(id))) {
                [inv setArgument:&obj atIndex:idx + 1];
            } else {
                // it's not NSObject, assuming an NSValue of the same kind
                assert([obj isKindOfClass:[NSValue class]]);
                assert(!strcmp([obj objCType], argType));
                
                NSUInteger size = 0;
                NSGetSizeAndAlignment(argType, &size, NULL);
                void* buf = malloc(size);
                [(NSValue*)obj getValue:buf];
                [inv setArgument:buf atIndex:idx + 1];
                free(buf);
            }
        }];
        
        call();
        
        void* buf = malloc([ms methodReturnLength]);
        [inv getReturnValue:buf];
        
        if (!strcmp([ms methodReturnType], @encode(id))) {
            memcpy((void*)&retval, buf, sizeof(id));
        } else {
            retval = [NSValue valueWithBytes:buf objCType:[ms methodReturnType]];
        }
        
        free(buf);
    };
    
    id (^wrapper)() = MAForwardingBlock(invWrapper, _block);
    wrapper();
    
    return retval;
}

@end
