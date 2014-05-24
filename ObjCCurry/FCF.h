//
//  FCF.h
//  ObjCCurry
//
//  Created by Tamas Lustyik on 2014.05.23..
//  Copyright (c) 2014 LKXF. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "metamacros.h"
#import "MethodFunction.h"

/**
 * First-class functions (FCFs)
 *
 * This header defines the \@function() and \@functionImpl() macros which simplify
 * the declaration and definition of function objects.
 *
 * TO DECLARE:
 *      \@function(function_name, function_signature)
 *
 *      where
 *          function_name       - the name of the function
 *          function_signature  - a comma separated list of arguments, terminated by the return value
 *
 * Example:
 *      declaring Haskell's flip :: (a -> b -> c) -> b -> a -> c:
\code
@function(Flip, Function*, id, id, id);
\endcode
 *
 * TO DEFINE:
 *      \@functionImpl(function_name)
 *      - (retval):(arg1type)arg1 :(arg2type)arg2 ... :(argNtype)argN {
 *          // implementation
 *      }
 *      \@end
 *
 * Example:
 *      defining Haskell's flip:
\code
@functionImpl(Flip)
- (id):(Function*)func :(id)a :(id)b {
    return [func :b :a];
}
@end
\endcode
 *
 * NOTES:
 * - don't put definitions into headers unless you are in for some linker errors
 * - it is obligatory to declare FN_IMPLEMENTATION in the function library
 *   implementation (.m) *before* importing the library header:
\code
// MyFuns.m
#define FN_IMPLEMENTATION
#import "MyFuns.h"
// ...
\endcode
 * - it is recommended to define a module name for each function library (.h + .m)
 *   the following way:
\code
// MyFuns.h
#undef FN_MODULE
#define FN_MODULE MyFuns
#import "FCF.h"

\@function(DoSomething, id, id);
// ... more function declarations ...
\endcode
 * - there is an experimental support for qualified function library importing.
 *   This is useful if you happen to have two functions with the same name in different
 *   libraries. If this is the case, apply the following idiom:
\code
// main.m
#define FN_NAMESPACE Foo
#import "MyFuns.h"
// all function declarations in MyFuns are now accessible with the "Foo_" prefix,
// e.g. Foo_DoSomething
\endcode
 */


// Implementation details

#undef __FN_ARGCOUNT
#define __FN_ARGCOUNT(...)          metamacro_dec(metamacro_argcount(__VA_ARGS__))

#undef __FN_LOCAL_NAME
#ifdef FN_MODULE
#define __FN_LOCAL_NAME(fname)      metamacro_concat(FN_MODULE, metamacro_concat(_, fname))
#else
#define __FN_LOCAL_NAME(fname)      fname
#endif

#undef __FN_LOCAL_CLSNAME
#define __FN_LOCAL_CLSNAME(fname)   metamacro_concat(__FN_, __FN_LOCAL_NAME(fname))
#undef __FN_LOCAL_OBJNAME
#define __FN_LOCAL_OBJNAME(fname)   metamacro_concat(__, __FN_LOCAL_NAME(fname))

#undef __FN_QUALIFIED_NAME
#ifdef FN_NAMESPACE
#define __FN_QUALIFIED_NAME(fname)  metamacro_concat(FN_NAMESPACE, metamacro_concat(_, fname))
#else
#define __FN_QUALIFIED_NAME(fname)  fname
#endif

#undef __FN_LOCAL_ARGCOUNT
#undef __FN_LOCAL_OBJECT
#undef __FN_BOOTSTRAP
#undef __FN_INSTANCE

#ifdef FN_IMPLEMENTATION
#define __FN_LOCAL_ARGCOUNT(fname, ...) static const int metamacro_concat(__FN_LOCAL_CLSNAME(fname), _ARGCOUNT) = __FN_ARGCOUNT(__VA_ARGS__);
#define __FN_LOCAL_OBJECT(fname)
#define __FN_BOOTSTRAP(fname)
#define __FN_INSTANCE(fname)
#else
#define __FN_LOCAL_ARGCOUNT(fname, ...)
#define __FN_LOCAL_OBJECT(fname)        extern Function* __FN_LOCAL_OBJNAME(fname);
#define __FN_BOOTSTRAP(fname) \
    __attribute__((constructor)) static void metamacro_concat(__FN_QUALIFIED_NAME(fname), _Init) () \
    { __FN_QUALIFIED_NAME(fname) = __FN_LOCAL_OBJNAME(fname); }
#define __FN_INSTANCE(fname)            static Function* __FN_QUALIFIED_NAME(fname) = nil;

#endif


// Public macros

#undef function
#define function(fname, ...) class Function; \
    __FN_LOCAL_ARGCOUNT(fname, __VA_ARGS__) \
    __FN_LOCAL_OBJECT(fname) \
    __FN_INSTANCE(fname) \
    __FN_BOOTSTRAP(fname)


#undef functionImpl
#define functionImpl(fname) interface __FN_LOCAL_CLSNAME(fname) : MethodFunction @end \
    @implementation __FN_LOCAL_CLSNAME(fname) \
    Function* __FN_LOCAL_OBJNAME(fname) = nil; \
    + (void)load { __FN_LOCAL_OBJNAME(fname) = [self new]; } \
    - (instancetype)init { \
        assert(metamacro_concat(__FN_LOCAL_CLSNAME(fname), _ARGCOUNT) <= 8); \
        self = [super initWithTarget:self selector:NSSelectorFromString([@"::::::::" substringToIndex:metamacro_concat(__FN_LOCAL_CLSNAME(fname), _ARGCOUNT)])]; \
        return self; \
    }
