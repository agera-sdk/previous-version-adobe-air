package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class BaseCommentNode extends SyntaxNode
    {
        public var content:String;

        public function BaseCommentNode(content:String)
        {
            this.content = content;
        }
    }
}