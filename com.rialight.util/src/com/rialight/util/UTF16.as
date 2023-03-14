package com.rialight.util
{
    /**
     * UTF-16 utility functions.
     */
    public final class UTF16
    {
        public static function codePointAt(str:String, pos:Number):uint
        {
            if (pos >= str.length)
            {
                return 0;
            }
            var first:uint = str.charCodeAt(pos);
            if (first >= 0xD800 && first <= 0xDBFF && str.length > pos + 1)
            {
                var second:uint = str.charCodeAt(pos + 1);
                if (second >= 0xDC00 && second <= 0xDFFF)
                {
                    return (first - 0xD800) * 0x400 + second - 0xDC00 + 0x10000;
                }
            }
            return first;
        }

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