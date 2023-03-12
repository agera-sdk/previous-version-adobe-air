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
     * resolve a simple or a complex Pattern to a FluentString
     * (which is really the string primitive).
     *
     * @private
     */
    internal function resolvePattern(scope:FTLScope, value:*):*
    {
        // resolve a simple pattern.
        if (typeof value === 'string')
        {
            return scope.bundle._transform(value);
        }

        return resolveComplexPattern(scope, value);
    }
}