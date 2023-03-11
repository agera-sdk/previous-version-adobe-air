package com.rialight.intl.ftl.internals.bundle
{
    /**
     * @private
     */
    public final class UTF16
    {
        public static function stringFromCodePoint(codePoint:Number):String
        {
            if (codePoint <= 0xFFFF)
            {
                return String.fromCharCode(codePoint);
            }
            else
            {
                codePoint -= 0x10000;
                var highSurrogate:Number = (codePoint >> 10) + 0xD800;
                var lowSurrogate:Number = (codePoint % 0x400) + 0xDC00;
                return String.fromCharCode(highSurrogate, lowSurrogate);
            }
        }
    }
}