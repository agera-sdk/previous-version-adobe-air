package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class BaseLiteralNode extends SyntaxNode
    {
        public var value:String;

        public function BaseLiteralNode(value:String)
        {
            this.value = value;
        }

        public function parse():*
        {
            return {};
        }
    }
}