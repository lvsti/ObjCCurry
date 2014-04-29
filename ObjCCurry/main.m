//
//  main.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Function.h"
#import "PointerFunction.h"


@interface Probe : NSObject

@end

@implementation Probe

- (void)dealloc {
    NSLog(@"dealloc probe %p", self);
}

@end


@interface MyClass : NSObject

- (CGPoint)doThisWith:(id)obj andWith:(CGRect)stuff error:(NSError**)error block:(id(^)(id))func delta:(int)delta;
- (NSString*)logTimes:(int)n usingBlock:(id(^)(id))block this:(id)obj;

@end


@implementation MyClass

- (CGPoint)doThisWith:(id)obj andWith:(CGRect)stuff error:(NSError**)error block:(id(^)(id))func delta:(int)delta {
    if (error) return CGPointZero;
    return CGPointMake([func(obj) intValue], stuff.origin.x + delta);
}

- (NSString*)logTimes:(int)n usingBlock:(id(^)(id))block this:(id)obj {
    for (int i = 0; i < n; ++i) {
        NSLog(@"mapped obj: %@", block(obj));
    }
    
    return block(obj);
}

- (NSString*)binary:(id)x with:(id)y {
    return [NSString stringWithFormat:@"--%@-- / --%@--", x, y];
}

- (id)unary:(id)x {
    return [Probe new];
}

@end


@implementation NSArray (HOF)

- (NSArray*)fmap:(Function*)func {
    NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [result addObject:[func :obj]];
    }];
    return result;
}

- (NSArray*)ap:(id)value {
    __block NSMutableArray* result = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id func, NSUInteger idx, BOOL *stop) {
        [result addObject:[func :value]];
    }];
    return result;
}

@end

int stuff(id blah, CGRect r) {
    NSLog(@"woohoo %@ %@", blah, NSStringFromRect(r));
    return 42;
}


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        MyClass* m = [MyClass new];
        id h = [Function fromPointer:stuff objCTypes:FPTR_SIG(int, id, CGRect)];
        h = [h :[NSNull null]];
        id ret = [h :[NSValue valueWithRect:CGRectMake(1, 2, 3, 4)]];
        NSLog(@"%@", ret);
        
        NSArray* values = @[@42, @11, @-96, @1024];
        id f = [Function fromTarget:m selector:@selector(doThisWith:andWith:error:block:delta:)];
        f = [[[f :@111] :[NSValue valueWithRect:CGRectMake(666, 1, 2, 3)]] :nil];
        f = [f :^id(id x) { return @([x intValue]*2); }];
        
        NSArray* v1 = [values fmap:f];
        NSLog(@"%@", v1);
        
        id (^block)(id, id) = ^id(id x, id y) { return [NSString stringWithFormat:@"--%@-- / --%@--", x, y]; };
        NSArray* v2 = [values fmap:[Function fromBlock:block]];
        NSArray* v3 = [v2 ap:@"foo"];
        NSLog(@"%@", v3);
        
        id g = [Function fromTarget:m selector:@selector(logTimes:usingBlock:this:)];
        g = [[g :@3] :^id(id x) { return [NSString stringWithFormat:@">>%@<<", x]; }];
        NSLog(@"g: %@", g);
        [values fmap:g];
    }
    return 0;
}

