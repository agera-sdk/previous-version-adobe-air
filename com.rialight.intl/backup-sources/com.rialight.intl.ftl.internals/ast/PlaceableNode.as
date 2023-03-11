package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class PlaceableNode extends SyntaxNode
    {
        public var expression:SyntaxNode;

        public function PlaceableNode(expression:SyntaxNode)
        {
            this.expression = expression;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'expression']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new PlaceableNode(
                SyntaxNode(this.expression.clone())
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}