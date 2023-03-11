package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class GroupCommentNode extends BaseCommentNode
    {
        public function GroupCommentNode(content:String)
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
            var r:BaseNode = new GroupCommentNode(this.content);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}