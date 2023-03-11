package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class TermReferenceNode extends ExpressionNode
    {
        public var name:String;
        public var attr:String;
        public var args:Array;

        public function TermReferenceNode
        (
            name:String,
            attr:String,
            args:Array
        )
        {
            super();
            this.name = name;
            this.attr = attr;
            this.args = args;
        }

        override public function get type():String
        {
            return 'term';
        }
    }
}