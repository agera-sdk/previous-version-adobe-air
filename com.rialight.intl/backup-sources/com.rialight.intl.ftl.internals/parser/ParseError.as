package com.rialight.intl.ftl.internals.parser
{
    import com.rialight.util.format;

    /**
     * @private
     */
    public class ParseError extends Error
    {
        public var code:String;
        public var args:Array;

        public function ParseError(code:String, ...args)
        {
            this.code = code;
            this.args = args;
            this.message = getErrorMessage(code, args);
        }

        private static function getErrorMessage(code:String, args:Array):String
        {
            switch (code)
            {
                case 'E0001':
                    return format('Generic error', {});
                case 'E0002':
                    return format('Expected an entry start', {});
                case 'E0003':
                    return format('Expected token "$token"', {token: args[0]});
                case 'E0004':
                    return format('Expected a character from range: "$range"', {range: args[0]});
                case 'E0005':
                    return format('Expected message "$id" to have a value or attributes', {id: args[0]});
                case 'E0006':
                    return format('Expected term "-$id" to have a value', {id: args[0]});
                case 'E0007':
                    return format('Keyword cannot end with a whitespace', {});
                case 'E0008':
                    return format('The callee has to be an upper-case identifier or a term', {});
                case 'E0009':
                    return format('The argument name has to be a simple identifier', {});
                case 'E0010':
                    return format('Expected one of the variants to be marked as default (*)', {});
                case 'E0011':
                    return format('Expected at least one variant after "->"', {});
                case 'E0012':
                    return format('Expected value', {});
                case 'E0013':
                    return format('Expected variant key', {});
                case 'E0014':
                    return format('Expected literal', {});
                case 'E0015':
                    return format('Only one variant can be marked as default (*)', {});
                case 'E0016':
                    return format('Message references cannot be used as selectors', {});
                case 'E0017':
                    return format('Terms cannot be used as selectors', {});
                case 'E0018':
                    return format('Attributes of messages cannot be used as selectors', {});
                case 'E0019':
                    return format('Attributes of terms cannot be used as placeables', {});
                case 'E0020':
                    return format('Unterminated string expression', {});
                case 'E0021':
                    return format('Positional arguments must not follow named arguments', {});
                case 'E0022':
                    return format('Named arguments must be unique', {});
                case 'E0024':
                    return format('Cannot access variants of a message.', {});
                case 'E0025':
                    return format('Unknown escape sequence: \\$char.', {char: args[0]});
                case 'E0026':
                    return format('Invalid Unicode escape sequence: $sequence.', {sequence: args[0]});
                case 'E0027':
                    return format('Unbalanced closing brace in TextElement.', {});
                case 'E0028':
                    return format('Expected an inline expression', {});
                case 'E0029':
                    return format('Expected simple expression as selector', {});
                default:
                    return code;
            }
        }
    }
}