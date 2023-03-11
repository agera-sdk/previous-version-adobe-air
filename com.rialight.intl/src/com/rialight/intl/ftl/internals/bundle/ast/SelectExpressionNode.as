package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class SelectExpressionNode extends ExpressionNode
    {
        public var selector:ExpressionNode;
        public var variants:Vector.<VariantNode>;
        public var star:Number;

        public function SelectExpressionNode
        (
            selector:ExpressionNode,
            variants:Vector.<VariantNode>,
            star:Number
        )
        {
            super();
            this.selector = selector;
            this.variants = variants;
            this.star = star;
        }

        override public function get type():String
        {
            return 'select';
        }
    }
}