package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class FunctionReferenceNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var arguments:CallArgumentsNode;

        public function FunctionReferenceNode
        (
            id:IdentifierNode,
            args:CallArgumentsNode
        )
        {
            this.id = id;
            this.arguments = args;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id', 'arguments']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new FunctionReferenceNode(
                IdentifierNode(id.clone()),
                CallArgumentsNode(this.arguments.clone())
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}