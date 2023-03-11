package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class NamedArgumentNode
    {
        public var name:String;
        public var value:LiteralNode;

        public function NamedArgumentNode(name:String, value:LiteralNode)
        {
            this.name = name;
            this.value = value;
        }

        public function get type():String
        {
            return 'narg';
        }
    }
}