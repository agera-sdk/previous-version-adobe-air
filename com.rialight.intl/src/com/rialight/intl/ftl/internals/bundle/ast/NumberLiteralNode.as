package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class NumberLiteralNode extends LiteralNode
    {
        public var value:Number;
        public var precision:Number;

        public function NumberLiteralNode(value:Number, precision:Number)
        {
            super();
            this.value = value;
            this.precision = precision;
        }

        override public function get type():String
        {
            return 'num';
        }
    }
}