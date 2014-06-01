//
//  MethodFunction.m
//  ObjCHOF
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "MethodFunction.h"
#import "NSInvocation+Extensions.h"
#import "NSInvocation+Function.h"
#import <objc/message.h>

@interface MethodFunction ()

@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, strong) NSMethodSignature* ms;

@end


@implementation MethodFunction

+ (instancetype)fromTarget:(id)target selector:(SEL)selector {
    return [[self alloc] initWithTarget:target selector:selector];
}

- (instancetype)initWithTarget:(id)target selector:(SEL)selector {
    assert(target);
    assert(selector);
    NSMethodSignature* ms = [target methodSignatureForSelector:selector];
    assert(ms);

    NSInteger argCount = [ms numberOfArguments] - 2;
    assert(argCount > 0);
    
    self = [super initWithArgCount:argCount args:nil];
    if (self) {
        self.target = target;
        self.selector = selector;
        self.ms = ms;
    }
    
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
    MethodFunction* f = [super copyWithZone:zone];
    f.target = _target;
    f.selector = _selector;
    f.ms = _ms;
    return f;
}

- (id)invoke {
    assert([self.args count] == self.argCount);
    
    BOOL useFastLane = NO;
    if (self.argCount <= 8 && [_ms methodReturnType][0] == '@') {
        BOOL onlyIdArgs = YES;
        for (int i = 0; i < self.argCount; ++i) {
            const char* argType = [_ms getArgumentTypeAtIndex:i+2];
            if (argType[0] != '@') {
                onlyIdArgs = NO;
                break;
            }
        }
        useFastLane = onlyIdArgs;
    }
    
    if (useFastLane) {
        switch (self.argCount) {
            case 1: return objc_msgSend(_target, _selector, self.args[0]);
            case 2: return objc_msgSend(_target, _selector, self.args[0], self.args[1]);
            case 3: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2]);
            case 4: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2], self.args[3]);
            case 5: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2], self.args[3], self.args[4]);
            case 6: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2], self.args[3], self.args[4], self.args[5]);
            case 7: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2], self.args[3], self.args[4], self.args[5], self.args[6]);
            case 8: return objc_msgSend(_target, _selector, self.args[0], self.args[1], self.args[2], self.args[3], self.args[4], self.args[5], self.args[6], self.args[7]);
                
            default:
                assert(NO);
                break;
        }
    } else {
        NSInvocation* inv = [NSInvocation invocationWithMethodSignature:_ms];
        [inv setTarget:_target];
        [inv setSelector:_selector];
        [inv setArgumentsWithArray:self.args
                   startingAtIndex:2];
        
        [inv invoke];
        
        return [inv returnedObject];
    }

    assert(NO);
    return nil;
}


@end
