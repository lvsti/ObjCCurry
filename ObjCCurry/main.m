//
//  main.m
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.04.27..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Function.h"
#import "FCFTest.h"

#undef FN_NAMESPACE
#define FN_NAMESPACE Foo
#import "Scoped2.h"


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


@protocol Functor <NSObject>
- (id<Functor>)fmap:(Function*)func;

+ (Function*)fmap;
@end


@protocol Applicative <NSObject>
- (id<Applicative>)ap:(id)value;

@end

@interface NSArray (Functor) <Functor>
@end

@implementation NSArray (Functor)

+ (Function*)fmap {
    return [Function fromBlock:^id<Functor>(Function* func, NSArray* ftor) {
        return [ftor fmap:func];
    }];
}

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


void CallableEntitiesDemo() {
    
    // C-style function
    Function* rangeFactory = [Function fromPointer:NSMakeRange objCTypes:FPTR_SIG(NSRange, NSUInteger, NSUInteger)];
    Function* rangeFrom42 = [rangeFactory :@42];
    // ...
    NSRange r = [[rangeFrom42 :@8] rangeValue];
    NSLog(@"%@", NSStringFromRange(r));
    
    
    // ObjC method
    Function* dateFactory = [Function fromTarget:[NSDate class] selector:@selector(dateWithTimeInterval:sinceDate:)];
    Function* adjustDateForSpain = [dateFactory :@(-60*30)];
    // ...
    NSDate* meetupTime = [NSDate dateWithString:@"2014-11-11 12:00:00 +0000"];
    NSDate* advertisedTimeForSpaniards = [adjustDateForSpain :meetupTime];
    NSLog(@"meet at: %@ (in Spain, advertise as %@)", meetupTime, advertisedTimeForSpaniards);
    

    // block
    int (^sum3)(int, int, int) = ^int(int x, int y, int z) { return x+y+z; };
    Function* sum3func = [Function fromBlock:sum3];
    Function* sum1ToXY = [sum3func :@1];
    NSLog(@"sum of 1, 2, and 3: %@", [sum1ToXY :@2 :@3]);
    
}


void Benchmark() {
    NSDate* start = nil;
    NSDate* end = nil;
    
    // C-style function
    Function* rangeFactory = [Function fromPointer:NSMakeRange objCTypes:FPTR_SIG(NSRange, NSUInteger, NSUInteger)];
    Function* rangeFrom42 = [rangeFactory :@42];
    NSRange r;
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            r = [[rangeFrom42 :@8] rangeValue];
        }
    }
    end = [NSDate date];
    
    NSLog(@"fptr - function object: %f", [end timeIntervalSinceDate:start]);
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        r = NSMakeRange(42, 8);
    }
    end = [NSDate date];
    
    NSLog(@"fptr - plain: %f", [end timeIntervalSinceDate:start]);
    
    
    // ObjC method
    Function* dateFactory = [Function fromTarget:[NSDate class] selector:@selector(dateWithTimeInterval:sinceDate:)];
    Function* adjustDateForSpain = [dateFactory :@(-60*30)];
    NSDate* meetupTime = [NSDate dateWithString:@"2014-11-11 12:00:00 +0000"];
    NSDate* d = nil;

    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            d = [adjustDateForSpain :meetupTime];
        }
    }
    end = [NSDate date];
    
    NSLog(@"selector - function object: %f", [end timeIntervalSinceDate:start]);
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            d = [NSDate dateWithTimeInterval:-60*30 sinceDate:meetupTime];
        }
    }
    end = [NSDate date];
    
    NSLog(@"selector - plain: %f", [end timeIntervalSinceDate:start]);
    
    
    // block
    int (^sum3)(int, int, int) = ^int(int x, int y, int z) { return x+y+z; };
    Function* sum3func = [Function fromBlock:sum3];
    Function* sum1ToXY = [sum3func :@1];
    int sum = 0;

    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            sum = [[sum1ToXY :@2 :@3] intValue];
        }
    }
    end = [NSDate date];
    
    NSLog(@"block - function object: %f", [end timeIntervalSinceDate:start]);
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        sum = sum3(1, 2, 3);
    }
    end = [NSDate date];
    
    NSLog(@"block - plain: %f", [end timeIntervalSinceDate:start]);
    
}


void FastLaneBenchmark() {
    NSDate* start = nil;
    NSDate* end = nil;

    // C-style function
    Function* strFromMT = [Function fromPointer:NSStringFromMapTable objCTypes:FPTR_SIG(NSString*, NSMapTable*)];
    NSMapTable* mt = [NSMapTable weakToWeakObjectsMapTable];
    id result = nil;

    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            result = [strFromMT :mt];
        }
    }
    end = [NSDate date];
    
    NSLog(@"fptr - function object: %f", [end timeIntervalSinceDate:start]);
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        result = NSStringFromMapTable(mt);
    }
    end = [NSDate date];
    
    NSLog(@"fptr - plain: %f", [end timeIntervalSinceDate:start]);

    
    // ObjC method
    Function* tzFactory = [Function fromTarget:[NSTimeZone class] selector:@selector(timeZoneWithName:data:)];
    Function* namedTz = [tzFactory :@"custom timezone"];
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            result = [NSTimeZone timeZoneWithName:@"custom timezone" data:nil];
        }
    }
    end = [NSDate date];
    NSLog(@"selector - plain: %f", [end timeIntervalSinceDate:start]);

    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            result = [namedTz :nil];
        }
    }
    end = [NSDate date];

    NSLog(@"selector - function object: %f", [end timeIntervalSinceDate:start]);
 
    
    // block
    id (^sum3)(id, id, id) = ^id(id x, id y, id z) { return @([x intValue]+[y intValue]+[z intValue]); };
    Function* sum3func = [Function fromBlock:sum3];
    Function* sum1ToXY = [sum3func :@1];
    int sum = 0;
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        @autoreleasepool {
            sum = [[sum1ToXY :@2 :@3] intValue];
        }
    }
    end = [NSDate date];
    
    NSLog(@"block - function object: %f", [end timeIntervalSinceDate:start]);
    
    start = [NSDate date];
    for (NSUInteger i = 0; i < 1000000; ++i) {
        sum = [sum3(@1, @2, @3) intValue];
    }
    end = [NSDate date];
    
    NSLog(@"block - plain: %f", [end timeIntervalSinceDate:start]);
    

}


int main(int argc, const char * argv[])
{
    @autoreleasepool {
        
        id result = [[NSArray fmap] :[[Flip :Foo_Cons] :@[@42]] :@[@1,@2,@3,@4]];
        

        
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

