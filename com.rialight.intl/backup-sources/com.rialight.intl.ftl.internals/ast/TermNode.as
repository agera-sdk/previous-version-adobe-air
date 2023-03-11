package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class TermNode extends SyntaxNode
    {
        public var id:IdentifierNode;
        public var value:PatternNode;
        public var attributes:Array;
        public var comment:CommentNode;

        public function TermNode
        (
            id:IdentifierNode,
            value:PatternNode,
            attributes:Array,
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
            var r:BaseNode = new TermNode(
                IdentifierNode(this.id.clone()),
                PatternNode(this.value.clone()),
                this.attributes.map(function(a:AttributeNode):* { return a.clone(); }),
                this.comment ? CommentNode(this.comment.clone()) : null
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}