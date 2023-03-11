package com.rialight.intl.ftl.internals.parser
{
    import com.rialight.util.format;
    import com.rialight.intl.ftl.internals.ast.*;

    /**
     * @private
     */
    public function lineOffset(source:String, pos:Number):Number
    {
        // subtract 1 to get the offset.
        return source.substring(0, pos).split('\n').length - 1;
    }
}