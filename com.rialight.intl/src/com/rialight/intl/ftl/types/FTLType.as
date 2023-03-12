package com.rialight.intl.ftl.types
{
    import com.rialight.intl.ftl.FTLScope;

    public class FTLType
    {
        public var value:*;

        public function FTLType(value:*)
        {
            this.value = value;
        }

        public function valueOf():*
        {
            return this.value;
        }

        public function toString(scope:FTLScope):String
        {
            return '';
        }
    }
}