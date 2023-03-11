package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class VariantNode
    {
        public var key:LiteralNode;
        public var value:*;

        public function VariantNode(key:LiteralNode, value:*)
        {
            this.key = key;
            this.value = value;
        }
    }
}