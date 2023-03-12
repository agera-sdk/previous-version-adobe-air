package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class AnnotationNode extends SyntaxNode
    {
        public var code:String;
        public var arguments:Array;
        public var message:String;

        public function AnnotationNode
        (
            code:String,
            args:Array,
            message:String
        )
        {
            this.code = code;
            this.arguments = args || [];
            this.message = message;
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'code', 'args', 'message']);
        }

        override public function clone():BaseNode
        {
            function cloneDeep(a:*, ..._):*
            {
                if (a is BaseNode)
                {
                    return BaseNode(a).clone();
                }
                if (a is Array)
                {
                    return a.map(cloneDeep);
                }
                return a;
            }
            var r:BaseNode = new AnnotationNode(
                this.code,
                this.arguments.map(cloneDeep),
                this.message
            );
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}