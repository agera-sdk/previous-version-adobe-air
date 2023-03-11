package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class CommentNode extends BaseCommentNode
    {
        public function CommentNode(content:String)
        {
            super(content);
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'content']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new CommentNode(this.content);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}