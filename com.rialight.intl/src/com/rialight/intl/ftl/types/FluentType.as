package com.rialight.intl.ftl.types
{
    import com.rialight.intl.ftl.FluentScope;

    public class FluentType
    {
        public var value:*;

        public function FluentType(value:*)
        {
            this.value = value;
        }

        public function valueOf():*
        {
            return this.value;
        }

        public function toString(scope:FluentScope):String
        {
            return '';
        }
    }
}