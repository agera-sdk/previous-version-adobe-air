package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class VariableReferenceNode extends SyntaxNode
    {
        public var id:IdentifierNode;

        public function VariableReferenceNode(id:IdentifierNode)
        {
            this.id = id;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new VariableReferenceNode(
                IdentifierNode(this.id.clone())
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}