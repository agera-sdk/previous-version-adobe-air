package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class AttributeNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var value:PatternNode;

        public function AttributeNode(id:IdentifierNode, value:PatternNode)
        {
            this.id = id;
            this.value = value;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id', 'value']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new AttributeNode(
                IdentifierNode(this.id.clone()),
                PatternNode(this.value.clone())
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}