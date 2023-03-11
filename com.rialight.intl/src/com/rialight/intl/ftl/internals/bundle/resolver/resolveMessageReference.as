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
    internal function resolveMessageReference
    (
        scope:FluentScope,
        expr:MessageReferenceNode
    ):*
    {
        var name:String = expr.name;
        var attr:String = expr.attr;

        const message:MessageNode = scope.bundle._messages.get(name);
        if (!message)
        {
            scope.reportError(new ReferenceError('Unknown message: ' + name));
            return new FluentNone(name);
        }

        if (attr)
        {
            const attribute:* = message.attributes[attr];
            if (attribute)
            {
                return resolvePattern(scope, attribute);
            }
            scope.reportError(new ReferenceError('Unknown attribute: ' + attr));
            return new FluentNone(name + '.' + attr);
        }

        if (message.value)
        {
            return resolvePattern(scope, message.value);
        }

        scope.reportError(new ReferenceError('No value: ' + name));
        return new FluentNone(name);
    }
}