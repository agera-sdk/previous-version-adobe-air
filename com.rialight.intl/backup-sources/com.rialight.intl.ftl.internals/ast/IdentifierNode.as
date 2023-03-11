package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class IdentifierNode extends SyntaxNode
    {
        public var name:String;

        public function IdentifierNode(name:String)
        {
            this.name = name;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'name']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new IdentifierNode(
                this.name
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}