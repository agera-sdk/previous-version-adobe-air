package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class NamedArgumentNode extends SyntaxNode
    {
        public var name:IdentifierNode;
        public var value:BaseLiteralNode;

        public function NamedArgumentNode(name:IdentifierNode, value:BaseLiteralNode)
        {
            this.name = name;
            this.value = value;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'name', 'value']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new NamedArgumentNode(
                IdentifierNode(this.name.clone()),
                BaseLiteralNode(this.value.clone())
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}