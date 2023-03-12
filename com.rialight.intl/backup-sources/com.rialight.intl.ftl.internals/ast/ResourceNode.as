package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class ResourceNode extends SyntaxNode
    {
        public var body:Array;

        public function ResourceNode(body:Array)
        {
            this.body = body || [];
        }
        
        override public function getKeys():Set
        {
            return new Set(['span', 'body']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new ResourceNode(body.map(function(a:SyntaxNode, ..._):BaseNode { return a.clone() }));
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}