package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class PatternNode extends SyntaxNode
    {
        public var elements:Array;

        public function PatternNode(elements:Array)
        {
            this.elements = elements;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'elements']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new PatternNode(
                this.elements.map(function(a:BaseNode):* { return a.clone(); })
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}