//
//  Function.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import "Function.h"
#import "MethodFunction.h"


@interface Function ()

@property (nonatomic, copy, readwrite) NSArray* args;

@end


@implementation Function

+ (instancetype)fromTarget:(id)target selector:(SEL)selector {
    return [MethodFunction fromTarget:target selector:selector];
}


- (instancetype)initWithArgCount:(NSInteger)argCount args:(NSArray*)args {
    assert(argCount > 0);
    assert([args count] <= argCount);
    
    self = [super init];
    if (self) {
        _argCount = argCount;
        _args = [args copy];
    }
    return self;
}

- (id)copyWithZone:(NSZone*)zone {
    return [[[self class] alloc] initWithArgCount:_argCount args:_args];
}

- (id):(id)obj {
    assert([_args count] < _argCount);
    assert(obj);

    Function* f = [self copy];
    f.args = _args? [_args arrayByAddingObject:obj]: @[obj];

    if ([f.args count] == _argCount) {
        return [f invoke];
    }
    
    return f;
}

- (id)invoke {
    // to be overridden by subclasses
    assert(NO);
    return nil;
}

- (NSString*)debugDescription {
    NSMutableString* desc = [NSMutableString stringWithFormat:@"<Function:%p> (", self];
    for (int i = 0; i < _argCount; ++i) {
        if (i < [_args count]) {
            [desc appendFormat:@"%@", [_args[i] debugDescription]];
        } else {
            [desc appendString:@"?"];
        }
        
        if (i < _argCount - 1) {
            [desc appendString:@", "];
        }
    }
    [desc appendString:@")"];
    return [desc copy];
}

- (NSString*)description {
    return [self debugDescription];
}

@end
