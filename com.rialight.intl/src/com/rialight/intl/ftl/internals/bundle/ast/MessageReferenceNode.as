package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class MessageReferenceNode extends ExpressionNode
    {
        public var name:String;
        public var attr:String;

        public function MessageReferenceNode
        (
            name:String,
            attr:String
        )
        {
            super();
            this.name = name;
            this.attr = attr;
        }

        override public function get type():String
        {
            return 'mesg';
        }
    }
}