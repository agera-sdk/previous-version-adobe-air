package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class MessageReferenceNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var attribute:IdentifierNode;

        public function MessageReferenceNode
        (
            id:IdentifierNode,
            attribute:IdentifierNode = null
        )
        {
            this.id = id;
            this.attribute = attribute;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id', 'attribute']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new MessageReferenceNode(
                IdentifierNode(this.id.clone()),
                this.attribute ? IdentifierNode(this.attribute.clone()) : null
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}