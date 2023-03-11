package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class SelectExpressionNode extends SyntaxNode
    {
        public var selector:SyntaxNode;
        public var variants:Array;

        public function SelectExpressionNode
        (
            selector:SyntaxNode,
            variants:Array
        )
        {
            this.selector = selector;
            this.variants = variants;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'selector', 'variants']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new SelectExpressionNode(
                SyntaxNode(this.selector.clone()),
                this.variants.map(function(a:BaseNode):* { return a.clone(); })
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}