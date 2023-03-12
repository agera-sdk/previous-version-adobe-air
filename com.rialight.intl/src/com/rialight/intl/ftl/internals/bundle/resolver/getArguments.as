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
     * helper: resolve arguments to a call expression.
     * 
     * @private
     */
    internal function getArguments
    (
        scope:FTLScope,
        args:Array
    ):*
    {
        const positional:Array = [];
        const named:* = {};

        for each (var arg:* in args)
        {
            if (arg is NamedArgumentNode)
            {
                named[NamedArgumentNode(arg).name] = resolveExpression(scope, NamedArgumentNode(arg).value);
            }
            else
            {
                positional.push(resolveExpression(scope, arg));
            }
        }

        return {positional: positional, named: named};
    }
}