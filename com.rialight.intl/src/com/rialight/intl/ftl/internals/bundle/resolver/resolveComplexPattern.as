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
     * resolves a pattern (a complex string with placeables).
     *
     * @private
     */
    public function resolveComplexPattern
    (
        scope:FTLScope,
        ptn:Array
    ):*
    {
        if (scope.dirty[ptn])
        {
            scope.reportError(new RangeError('Cyclic reference'));
            return new FTLNone;
        }

        // tag the pattern as dirty for the purpose of the current resolution.
        scope.dirty[ptn] = true;
        const result:Array = [];

        // wrap interpolations with Directional Isolate Formatting characters
        // only when the pattern has more than one element.
        const useIsolating:Boolean = scope.bundle._useIsolating && ptn.length > 1;

        for each (var elem:* in ptn)
        {
            if (typeof elem === 'string')
            {
                result.push(scope.bundle._transform(elem));
                continue;
            }

            scope.placeables++;
            if (scope.placeables > MAX_PLACEABLES)
            {
                delete scope.dirty[ptn];
                // this is a fatal error which causes the resolver to instantly bail out
                // on this pattern. the length check protects against excessive memory
                // usage, and throwing protects against eating up the CPU when long
                // placeables are deeply nested.
                throw new RangeError(
                    'Too many placeables expanded: ' + String(scope.placeables) + ', ' +
                    'max allowed is ' + String(MAX_PLACEABLES)
                );
            }

            if (useIsolating)
            {
                result.push(FSI);
            }

            result.push(resolveExpression(scope, elem).toString(scope));

            if (useIsolating)
            {
                result.push(PDI);
            }
        }

        delete scope.dirty[ptn];
        return result.join('');
    }
}