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
    internal function resolveTermReference
    (
        scope:FluentScope,
        expr:TermReferenceNode
    ):*
    {
        var name:String = expr.name;
        var attr:String = expr.attr;
        var args:Array = expr.args;

        const id:String = '-' + name;
        const term:TermNode = scope.bundle._terms.get(id);
        if (!term)
        {
            scope.reportError(new ReferenceError('Unknown term: ' + id));
            return new FluentNone(id);
        }

        if (attr)
        {
            const attribute:* = term.attributes[attr];
            if (attribute)
            {
                // every TermReference has its own variables.
                scope.params = getArguments(scope, args).named;
                const resolved:* = resolvePattern(scope, attribute);
                scope.params = null;
                return resolved;
            }
            scope.reportError(new ReferenceError('Unknown attribute: ' + attr));
            return new FluentNone(id + '.' + attr);
        }

        scope.params = getArguments(scope, args).named;
        const resolved2:* = resolvePattern(scope, term.value);
        scope.params = null;
        return resolved2;
    }
}