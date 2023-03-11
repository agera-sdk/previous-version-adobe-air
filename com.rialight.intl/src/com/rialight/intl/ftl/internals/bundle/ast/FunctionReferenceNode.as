package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class FunctionReferenceNode extends ExpressionNode
    {
        public var name:String;
        public var args:Array;

        public function FunctionReferenceNode
        (
            name:String,
            args:Array
        )
        {
            super();
            this.name = name;
            this.args = args;
        }

        override public function get type():String
        {
            return 'func';
        }
    }
}