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
     * helper: match a variant key to the given selector.
     *
     * @private
     */
    internal function match(scope:FluentScope, selector:*, key:*):Boolean
    {
        if (key === selector)
        {
            // both are strings.
            return true;
        }

        // XXX consider comparing options too, e.g. minimumFractionDigits.
        if
        (
            key is FluentNumber &&
            selector is FluentNumber &&
            FluentNumber(key).value === FluentNumber(selector).value
        )
        {
            return true;
        }

        if ((selector is FluentNumber) && typeof key === 'string')
        {
            var category:* = scope
                .memoizeIntlObject(
                    IntlPluralRules,
                    selector.opts
                )
                .select(FluentNumber(selector).value);

            if (key === category)
            {
                return true;
            }
        }

        return false;
    }
}