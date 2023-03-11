package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class VariableReferenceNode extends ExpressionNode
    {
        public var name:String;

        public function VariableReferenceNode
        (
            name:String
        )
        {
            super();
            this.name = name;
        }

        override public function get type():String
        {
            return 'var';
        }
    }
}