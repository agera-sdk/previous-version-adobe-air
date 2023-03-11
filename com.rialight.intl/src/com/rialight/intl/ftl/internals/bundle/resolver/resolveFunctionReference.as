package com.rialight.intl.ftl.internals.bundle.resolver
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.util.*;

    /**
     * @private
     */
    internal function resolveFunctionReference
    (
        scope:FluentScope,
        expr:FunctionReferenceNode
    ):*
    {
        var name:String = expr.name;
        var args:Array = expr.args;

        // some functions are built-in. others may be provided by the runtime via
        // the `FluentBundle` constructor.
        var func:* = scope.bundle._functions[name];
        if (!func)
        {
            scope.reportError(new ReferenceError('Unknown function: ' + name + '()'));
            return new FluentNone(name + '()');
        }

        if (typeof func !== 'function')
        {
            scope.reportError(new TypeError('Function ' + name + '() is not callable'));
            return new FluentNone(name + '()');
        }

        try
        {
            var resolved:* = getArguments(scope, args);
            return func(resolved.positional, resolved.named);
        }
        catch (err:*)
        {
            scope.reportError(err);
            return new FluentNone(name + '()');
        }
    }
}