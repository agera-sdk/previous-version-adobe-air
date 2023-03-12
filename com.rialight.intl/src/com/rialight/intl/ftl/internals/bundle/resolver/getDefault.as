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
     * helper: resolve the default variant from a list of variants.
     *
     * @private
     */
    internal function getDefault
    (
        scope:FTLScope,
        variants:Vector.<VariantNode>,
        star:Number
    ):*
    {
        if (variants[star])
        {
            return resolvePattern(scope, variants[star].value);
        }

        scope.reportError(new RangeError('No default'));
        return new FTLNone;
    }
}