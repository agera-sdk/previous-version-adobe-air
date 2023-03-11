package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class TermReferenceNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var attribute:IdentifierNode;
        public var arguments:CallArgumentsNode;

        public function TermReferenceNode
        (
            id:IdentifierNode,
            attribute:IdentifierNode = null,
            args:CallArgumentsNode = null
        )
        {
            this.id = id;
            this.attribute = attribute;
            this.arguments = args;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id', 'attribute', 'arguments']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new TermReferenceNode(
                IdentifierNode(this.id.clone()),
                this.attribute ? IdentifierNode(this.attribute.clone()) : null,
                this.arguments ? CallArgumentsNode(this.arguments.clone()) : null
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}