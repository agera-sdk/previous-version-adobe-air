package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class NumberLiteralNode extends BaseLiteralNode
    {
        public function NumberLiteralNode(value:String)
        {
            super(value);
        }

        override public function parse():*
        {
            var value:Number = parseFloat(this.value);
            var decimalPos:Number = this.value.indexOf('.');
            var precision:Number = decimalPos > 0 ? this.value.length - decimalPos - 1 : 0;
            return {value: value, precision: precision};
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'value']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new NumberLiteralNode(this.value);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}