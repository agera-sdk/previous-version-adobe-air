package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class TextElementNode extends SyntaxNode
    {
        public var value:String;

        public function TextElementNode(value:String)
        {
            this.value = value;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'value']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new TextElementNode(this.value);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}