package com.rialight.intl.ftl.internals.bundle.ast
{
    /**
     * @private
     */
    public final class TermNode
    {
        public var id:String;
        public var value:*;
        public var attributes:*;

        public function TermNode(id:String, value:*, attributes:*)
        {
            this.id = id;
            this.value = value;
            this.attributes = attributes;
        }
    }
}