package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class MessageNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var value:PatternNode;
        public var attributes:Array;
        public var comment:CommentNode;

        public function MessageNode
        (
            id:IdentifierNode,
            value:PatternNode = null,
            attributes:Array = null,
            comment:CommentNode = null
        )
        {
            this.id = id;
            this.value = value;
            this.attributes = attributes || [];
            this.comment = comment;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'id', 'value', 'attributes', 'comment']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new MessageNode(
                IdentifierNode(this.id.clone()),
                this.value ? PatternNode(this.value.clone()) : null,
                this.attributes.map(function(a:AttributeNode, ..._):* { return a.clone(); }),
                this.comment ? CommentNode(this.comment.clone()) : null
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}