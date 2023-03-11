package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class VariantNode extends SyntaxNode
    {
        public var key:SyntaxNode;
        public var value:PatternNode;
        public var isDefault:Boolean;

        public function VariantNode
        (
            key:SyntaxNode,
            value:PatternNode,
            isDefault:Boolean
        )
        {
            this.key = key;
            this.value = value;
            this.isDefault = isDefault;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'key', 'value', 'isDefault']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new VariantNode(
                SyntaxNode(this.key.clone()),
                PatternNode(this.value.clone()),
                this.isDefault
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}