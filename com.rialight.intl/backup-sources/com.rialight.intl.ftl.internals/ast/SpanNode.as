package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class SpanNode extends SyntaxNode
    {
        public var start:Number;
        public var end:Number;

        public function SpanNode(start:Number, end:Number)
        {
            this.start = start;
            this.end = end;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'start', 'end']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new SpanNode(this.start, this.end);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}