package com.rialight.intl.ftl.types
{
    import com.rialight.intl.ftl.FTLScope;

    public class FTLNone extends FTLType
    {
        public function FTLNone(value:* = '???')
        {
            super(value);
        }

        override public function toString(scope:FTLScope):String
        {
            return '{' + String(value) + '}';
        }
    }
}