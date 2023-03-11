package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class StringLiteralNode extends LiteralNode
    {
        public var value:String;

        public function StringLiteralNode(value:String)
        {
            super();
            this.value = value;
        }

        override public function get type():String
        {
            return 'str';
        }
    }
}