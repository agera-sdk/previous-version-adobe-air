package com.rialight.intl.ftl.internals.parser
{
    import com.rialight.util.format;
    import com.rialight.intl.ftl.internals.ast.*;

    /**
     * @private
     */
    public function parse(source:String, opts:FluentParserOptions):ResourceNode
    {
        const parser:FluentParser = new FluentParser(opts);
        return parser.parse(source);
    }
}