package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class JunkNode extends SyntaxNode
    {
        public var annotations:Array = [];
        public var content:String;

        public function JunkNode(content:String)
        {
            this.content = content;
        }

        public function addAnnotation(annotation:AnnotationNode):void
        {
            this.annotations.push(annotation);
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'annotations', 'content']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new JunkNode(
                this.content
            );
            JunkNode(r).annotations = this.annotations.map(function(a:AnnotationNode):* { return a.clone(); });
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}