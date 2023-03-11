package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;
    import com.rialight.intl.ftl.internals.UTF16;

    /**
     * @private
     */
    public class StringLiteralNode extends BaseLiteralNode
    {
        public function StringLiteralNode(value:String)
        {
            super(value);
        }

        override public function parse():*
        {
            // backslash backslash, backslash double quote, uHHHH, UHHHHHH.
            const KNOWN_ESCAPES:RegExp =
                /(?:\\\\|\\"|\\u([0-9a-fA-F]{4})|\\U([0-9a-fA-F]{6}))/g;

            function fromEscapeSequence
            (
                match:String,
                codepoint4:String,
                codepoint6:String
            ):String
            {
                switch (match)
                {
                    case '\\\\':
                        return '\\';
                    case '\\"':
                        return '"';
                    default:
                    {
                        var codepoint:Number = parseInt(codepoint4 || codepoint6, 16);
                        if (codepoint <= 0xd7ff || 0xe000 <= codepoint)
                        {
                            // it's a Unicode scalar value.
                            return UTF16.stringFromCodePoint(codepoint);
                        }
                        // escape sequences representing surrogate code points are
                        // well-formed but invalid in Fluent. replace them with U+FFFD
                        // REPLACEMENT CHARACTER.
                        return "\uFFFD";
                    }
                }
            }
            var value:String = this.value.replace(KNOWN_ESCAPES, fromEscapeSequence);
            return {value: value};
        }

        /**
         * @private
         */
        override public function getKeys():Set
        {
            return new Set(['span', 'value']);
        }

        override public function clone():BaseNode
        {
            var r:BaseNode = new StringLiteralNode(this.value);
            SyntaxNode(r).span = SpanNode(this.span.clone());
            return r;
        }
    }
}