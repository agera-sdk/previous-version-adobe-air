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
    internal function resolveSelectExpression
    (
        scope:FTLScope,
        expr:SelectExpressionNode
    ):*
    {
        var selector:ExpressionNode = expr.selector;
        var variants:Vector.<VariantNode> = expr.variants;
        var star:Number = expr.star;

        var sel:* = resolveExpression(scope, selector);
        if (sel is FTLNone)
        {
            return getDefault(scope, variants, star);
        }

        // match the selector against keys of each variant, in order.
        for each (var variant:VariantNode in variants)
        {
            const key:* = resolveExpression(scope, variant.key);
            if (match(scope, sel, key))
            {
                return resolvePattern(scope, variant.value);
            }
        }

        return getDefault(scope, variants, star);
    }
}