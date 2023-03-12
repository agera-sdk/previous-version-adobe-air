package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class CallArgumentsNode extends SyntaxNode
    {
        public var positional:Array;
        public var named:Array;

        public function CallArgumentsNode
        (
            positional:Array = null,
            named:Array = null
        )
        {
            this.positional = positional || [];
            this.named = named || [];
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'positional', 'named']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new CallArgumentsNode(
                this.positional.map(function(a:BaseNode, ..._):* { return a.clone(); }),
                this.named.map(function(a:BaseNode, ..._):* { return a.clone(); })
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}