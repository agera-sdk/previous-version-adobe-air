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
     * resolves an expression to a Fluent type.
     * 
     * @private
     */
    internal function resolveExpression
    (
        scope:FluentScope,
        expr:ExpressionNode
    ):*
    {
        switch (expr.type)
        {
            case 'str':
                return StringLiteralNode(expr).value;
            case 'num':
                var numLiteral:NumberLiteralNode = NumberLiteralNode(expr);
                return new FluentNumber(numLiteral.value, {
                    minimumFractionDigits: numLiteral.precision
                });
            case 'var':
                return resolveVariableReference(scope, VariableReferenceNode(expr))
            case 'mesg':
                return resolveMessageReference(scope, MessageReferenceNode(expr));
            case 'term':
                return resolveTermReference(scope, TermReferenceNode(expr));
            case 'func':
                return resolveFunctionReference(scope, FunctionReferenceNode(expr));
            case 'select':
                return resolveSelectExpression(scope, SelectExpressionNode(expr));
            default:
                return new FluentNone;
        }
    }
}