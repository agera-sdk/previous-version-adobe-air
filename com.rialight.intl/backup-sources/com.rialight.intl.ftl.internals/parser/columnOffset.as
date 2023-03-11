package com.rialight.intl.ftl.internals.parser
{
    import com.rialight.util.format;
    import com.rialight.intl.ftl.internals.ast.*;

    /**
     * @private
     */
    public function columnOffset(source:String, pos:Number):Number
    {
        // find the last line break starting backwards from the index just before
        // pos. this allows us to correctly handle ths case where the character at
        // pos is a line break as well.
        const fromIndex:Number = pos - 1;
        const prevLineBreak:Number = source.lastIndexOf('\n', fromIndex);

        // pos is a position in the first line of source.
        if (prevLineBreak === -1)
        {
            return pos;
        }

        // subtracting two offsets gives length; subtract 1 to get the offset.
        return pos - prevLineBreak - 1;
    }
}