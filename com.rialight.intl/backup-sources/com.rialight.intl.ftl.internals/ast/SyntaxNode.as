package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class SyntaxNode extends BaseNode
    {
        public var span:SpanNode;

        public function addSpan(start:Number, end:Number):void
        {
            this.span = new SpanNode(start, end);
        }
    }
}