package com.rialight.intl.ftl.types
{
    import com.rialight.intl.ftl.FluentScope;

    public class FluentNone extends FluentType
    {
        public function FluentNone(value:* = '???')
        {
            super(value);
        }

        override public function toString(scope:FluentScope):String
        {
            return '{' + String(value) + '}';
        }
    }
}