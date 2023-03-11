package com.rialight.intl.ftl.internals.bundle
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.util.*;

    /**
     * @private
     */
    public final class FluentResource
    {
        // This regex is used to iterate through the beginnings of messages and terms.
        // With the /m flag, the ^ matches at the beginning of every line.
        private static const RE_MESSAGE_START:StickyRegExp = new StickyRegExp(/^(-?[a-zA-Z][\w-]*) *= */gm);

        // Both Attributes and Variants are parsed in while loops. these regexes are
        // used to break out of them.
        private static const RE_ATTRIBUTE_START:StickyRegExp = new StickyRegExp(/\.([a-zA-Z][\w-]*) *= */, /*sticky*/ true);
        private static const RE_VARIANT_START:StickyRegExp = new StickyRegExp(/\*?\[/, /*sticky*/ true);

        private static const RE_NUMBER_LITERAL:StickyRegExp = new StickyRegExp(/(-?[0-9]+(?:\.([0-9]+))?)/, /*sticky*/ true);
        private static const RE_IDENTIFIER:StickyRegExp = new StickyRegExp(/([a-zA-Z][\w-]*)/, /*sticky*/ true);
        private static const RE_REFERENCE:StickyRegExp = new StickyRegExp(/([$-])?([a-zA-Z][\w-]*)(?:\.([a-zA-Z][\w-]*))?/, /*sticky*/ true);
        private static const RE_FUNCTION_NAME:StickyRegExp = new StickyRegExp(/^[A-Z][A-Z0-9_-]*$/);

        // A "run" is a sequence of text or string literal characters which don't
        // require any special handling. For TextElements such special characters are: {
        // (starts a placeable), and line breaks which require additional logic to check
        // if the next line is indented. For StringLiterals they are: \ (starts an
        // escape sequence), " (ends the literal), and line breaks which are not allowed
        // in StringLiterals. Note that string runs may be empty; text runs may not.
        private static const RE_TEXT_RUN:StickyRegExp = new StickyRegExp(/([^{}\n\r]+)/, /*sticky*/ true);
        private static const RE_STRING_RUN:StickyRegExp = new StickyRegExp(/([^\\"\n\r]*)/, /*sticky*/ true);

        // Escape sequences.
        private static const RE_STRING_ESCAPE:StickyRegExp = new StickyRegExp(/\\([\\"])/, /*sticky*/ true);
        private static const RE_UNICODE_ESCAPE:StickyRegExp = new StickyRegExp(/\\u([a-fA-F0-9]{4})|\\U([a-fA-F0-9]{6})/, /*sticky*/ true);

        // Used for trimming TextElements and indents.
        private static const RE_LEADING_NEWLINES:StickyRegExp = new StickyRegExp(/^\n+/);
        private static const RE_TRAILING_SPACES:StickyRegExp = new StickyRegExp(/ +$/);
        // Used in makeIndent to strip spaces from blank lines and normalize CRLF to LF.
        private static const RE_BLANK_LINES:StickyRegExp = new StickyRegExp(/ *\r?\n/g);
        // Used in makeIndent to measure the indentation.
        private static const RE_INDENT:StickyRegExp = new StickyRegExp(/( *)$/);

        // Common tokens.
        private static const TOKEN_BRACE_OPEN:StickyRegExp = new StickyRegExp(/{\s*/, /*sticky*/ true);
        private static const TOKEN_BRACE_CLOSE:StickyRegExp = new StickyRegExp(/\s*}/, /*sticky*/ true);
        private static const TOKEN_BRACKET_OPEN:StickyRegExp = new StickyRegExp(/\[\s*/, /*sticky*/ true);
        private static const TOKEN_BRACKET_CLOSE:StickyRegExp = new StickyRegExp(/\s*] */, /*sticky*/ true);
        private static const TOKEN_PAREN_OPEN:StickyRegExp = new StickyRegExp(/\s*\(\s*/, /*sticky*/ true);
        private static const TOKEN_ARROW:StickyRegExp = new StickyRegExp(/\s*->\s*/, /*sticky*/ true);
        private static const TOKEN_COLON:StickyRegExp = new StickyRegExp(/\s*:\s*/, /*sticky*/ true);
        // Note the optional comma. As a deviation from the Fluent EBNF, the parser
        // doesn't enforce commas between call arguments.
        private static const TOKEN_COMMA:StickyRegExp = new StickyRegExp(/\s*,?\s*/, /*sticky*/ true);
        private static const TOKEN_BLANK:StickyRegExp = new StickyRegExp(/\s+/, /*sticky*/ true);

        public var body:Array;

        public function FluentResource(source:String)
        {
            this.body = [];

            RE_MESSAGE_START.lastIndex = 0;
            var cursor:Number = 0;

            // Iterate over the beginnings of messages and terms to efficiently skip
            // comments and recover from errors.
            while (true)
            {
                var next:* = RE_MESSAGE_START.exec(source);
                if (next === null)
                {
                    break;
                }

                cursor = RE_MESSAGE_START.lastIndex;
                try
                {
                    this.body.push(parseMessage(next[1]));
                }
                catch (err:*)
                {
                    if (err is SyntaxError)
                    {
                        // Don't report any Fluent syntax errors. Skip directly to the
                        // beginning of the next message or term.
                        continue;
                    }
                    throw err;
                }
            }

            // The parser implementation is inlined below for performance reasons,
            // as well as for convenience of accessing `source` and `cursor`.

            // The parser focuses on minimizing the number of false negatives at the
            // expense of increasing the risk of false positives. In other words, it
            // aims at parsing valid Fluent messages with a success rate of 100%, but it
            // may also parse a few invalid messages which the reference parser would
            // reject. The parser doesn't perform any validation and may produce entries
            // which wouldn't make sense in the real world. For best results users are
            // advised to validate translations with the fluent-syntax parser
            // pre-runtime.

            // The parser makes an extensive use of sticky regexes which can be anchored
            // to any offset of the source string without slicing it. Errors are thrown
            // to bail out of parsing of ill-formed messages.

            function test(re:StickyRegExp):Boolean
            {
                re.lastIndex = cursor;
                return re.test(source);
            }

            // Advance the cursor by the char if it matches. May be used as a predicate
            // (was the match found?) or, if errorClass is passed, as an assertion.
            function consumeChar(char:String, errorClass:* = undefined):Boolean
            {
                if (source.charAt(cursor) === char)
                {
                    ++cursor;
                    return true;
                }
                if (errorClass)
                {
                    throw new errorClass('Expected ' + char);
                }
                return false;
            }

            // Advance the cursor by the token if it matches. May be used as a predicate
            // (was the match found?) or, if errorClass is passed, as an assertion.
            function consumeToken(re:StickyRegExp, errorClass:* = undefined):Boolean
            {
                if (test(re))
                {
                    cursor = re.lastIndex;
                    return true;
                }
                if (errorClass)
                {
                    throw new errorClass('Expected ' + re.toString());
                }
                return false;
            }

            // Execute a regex, advance the cursor, and return all capture groups.
            function match(re:StickyRegExp):*
            {
                re.lastIndex = cursor;
                var result:* = re.exec(source);
                if (result === null)
                {
                    throw new SyntaxError('Expected ' + re.toString());
                }
                cursor = re.lastIndex;
                return result;
            }

            // Execute a regex, advance the cursor, and return the capture group.
            function match1(re:StickyRegExp):String
            {
                return match(re)[1];
            }

            function parseMessage(id:String):MessageNode
            {
                var value:* = parsePattern();
                var attributes:* = parseAttributes();

                if (value === null && getObjectKeys(attributes).length === 0)
                {
                    throw new SyntaxError('Expected message value or attributes');
                }

                return new MessageNode(id, value, attributes);
            }

            function parseAttributes():*
            {
                var attrs:* = {};

                while (test(RE_ATTRIBUTE_START))
                {
                    var name:String = match1(RE_ATTRIBUTE_START);
                    var value:* = parsePattern();
                    if (value === null)
                    {
                        throw new SyntaxError('Expected attribute value');
                    }
                    attrs[name] = value;
                }

                return attrs;
            } // parseAttributes

            function parsePattern():*
            {
                var first:*;
                // First try to parse any simple text on the same line as the id.
                if (test(RE_TEXT_RUN))
                {
                    first = match1(RE_TEXT_RUN);
                }

                // If there's a placeable on the first line, parse a complex pattern.
                if (source.charAt(cursor) === "{" || source.charAt(cursor) === "}")
                {
                    // Re-use the text parsed above, if possible.
                    return parsePatternElements(first ? [first] : [], Infinity);
                }

                // RE_TEXT_VALUE stops at newlines. Only continue parsing the pattern if
                // what comes after the newline is indented.
                var indent:* = parseIndent();
                if (indent)
                {
                    if (first)
                    {
                        // If there's text on the first line, the blank block is part of the
                        // translation content in its entirety.
                        return parsePatternElements([first, indent], indent.length);
                    }
                    // Otherwise, we're dealing with a block pattern, i.e. a pattern which
                    // starts on a new line. Discrad the leading newlines but keep the
                    // inline indent; it will be used by the dedentation logic.
                    indent.value = trim(indent.value, RE_LEADING_NEWLINES);
                    return parsePatternElements([indent], indent.length);
                }

                if (first)
                {
                    // It was just a simple inline text after all.
                    return trim(first, RE_TRAILING_SPACES);
                }

                return null;
            } // parsePattern

            // Parse a complex pattern as an array of elements.
            function parsePatternElements(elements:Array, commonIndent:Number):Array
            {
                while (true)
                {
                    if (test(RE_TEXT_RUN))
                    {
                        elements.push(match1(RE_TEXT_RUN));
                        continue;
                    }

                    if (source.charAt(cursor) === '{')
                    {
                        elements.push(parsePlaceable());
                        continue;
                    }

                    if (source.charAt(cursor) === '}')
                    {
                        throw new SyntaxError('Unbalanced closing brace');
                    }

                    var indent:* = parseIndent();
                    if (indent)
                    {
                        elements.push(indent);
                        commonIndent = Math.min(commonIndent, indent.length);
                        continue;
                    }

                    break;
                }

                var lastIndex:Number = elements.length - 1;
                var lastElement:* = elements[lastIndex];
                // Trim the trailing spaces in the last element if it's a TextElement.
                if (typeof lastElement == 'string')
                {
                    elements[lastIndex] = trim(lastElement, RE_TRAILING_SPACES);
                }

                var baked:Array = [];
                for each (var element:* in elements)
                {
                    if (element is Indent)
                    {
                        // Dedent indented lines by the maximum common indent.
                        element = Indent(element).value.slice(0, Indent(element).value.length - commonIndent);
                    }
                    if (element)
                    {
                        baked.push(element);
                    }
                }
                return baked;
            } // parsePatternElements

            function parsePlaceable():ExpressionNode
            {
                consumeToken(TOKEN_BRACE_OPEN, SyntaxError);

                var selector:ExpressionNode = parseInlineExpression();
                if (consumeToken(TOKEN_BRACE_CLOSE))
                {
                    return selector;
                }

                if (consumeToken(TOKEN_ARROW))
                {
                    var variants:* = parseVariants();
                    consumeToken(TOKEN_BRACE_CLOSE, SyntaxError);
                    return new SelectExpressionNode(selector, variants.variants, variants.star);
                }

                throw new SyntaxError('Unclosed placeable');
            } // parsePlaceable

            function parseInlineExpression():ExpressionNode
            {
                if (source.charAt(cursor) === '{')
                {
                    // it's a nested placeable.
                    return parsePlaceable();
                }

                if (test(RE_REFERENCE))
                {
                    var reRefMatch:* = match(RE_REFERENCE);
                    var sigil:String = reRefMatch[0];
                    var name:String = reRefMatch[1];
                    var attr:String = reRefMatch[2] === undefined ? null : reRefMatch[2];

                    if (sigil === '$')
                    {
                        return new VariableReferenceNode(name);
                    }

                    if (consumeToken(TOKEN_PAREN_OPEN))
                    {
                        var args:Array = parseArguments();

                        if (sigil === '-')
                        {
                            // A parameterized term: -term(...).
                            return new TermReferenceNode(name, attr, args);
                        }

                        if (RE_FUNCTION_NAME.test(name))
                        {
                            return new FunctionReferenceNode(name, args);
                        }

                        throw new SyntaxError('Function names must be all upper-case');
                    }

                    if (sigil === '-')
                    {
                        // A non-parameterized term: -term.
                        return new TermReferenceNode(name, attr, []);
                    }

                    return new MessageReferenceNode(name, attr);
                }

                return parseLiteral();
            } // parseInlineExpression

            function parseArguments():Array
            {
                var args:Array = [];
                while (true)
                {
                    switch (source.charAt(cursor))
                    {
                        case ')': // End of the argument list.
                        {
                            cursor++;
                            return args;
                        }
                        case undefined: // EOF
                        {
                            throw new SyntaxError('Unclosed argumnt list');
                        }
                    }

                    args.push(parseArgument());
                    // Commas between arguments are treated as whitespace.
                    consumeToken(TOKEN_COMMA);
                }
            } // parseArguments

            function parseArgument():*
            {
                var expr:ExpressionNode = parseInlineExpression();
                if (!(expr is MessageReferenceNode))
                {
                    return expr;
                }

                if (consumeToken(TOKEN_COLON))
                {
                    // The reference is the beginning of a named argument.
                    return new NamedArgumentNode((expr as *).name, parseLiteral());
                }

                // It's a regular message reference.
                return expr;
            } // parseArgument

            function parseVariants():*
            {
                var variants:Vector.<VariantNode> = new Vector.<VariantNode>;
                var count:Number = 0;
                var star:* = undefined;

                while (test(RE_VARIANT_START))
                {
                    if (consumeChar('*'))
                    {
                        star = count;
                    }

                    var key:LiteralNode = parseVariantKey();
                    var value:* = parsePattern();
                    if (value === null)
                    {
                        throw new SyntaxError('Expected variant value');
                    }
                    variants[count++] = {key: key, value: value};
                }

                if (count === 0)
                {
                    return null;
                }

                if (star === undefined)
                {
                    throw new SyntaxError('Expected default variant');
                }

                return {variants: variants, star: star};
            } // parseVariants

            function parseVariantKey():LiteralNode
            {
                consumeToken(TOKEN_BRACKET_OPEN, SyntaxError);
                var key:*;
                if (test(RE_NUMBER_LITERAL))
                {
                    key = parseNumberLiteral();
                }
                else
                {
                    key = new StringLiteralNode(match1(RE_IDENTIFIER));
                }
                consumeToken(TOKEN_BRACKET_CLOSE, SyntaxError);
                return key;
            } // parseVariantKey

            function parseLiteral():LiteralNode
            {
                if (test(RE_NUMBER_LITERAL))
                {
                    return parseNumberLiteral();
                }

                if (source.charAt(cursor) == '"')
                {
                    return parseStringLiteral();
                }

                throw new SyntaxError('Invalid expression');
            } // parseLiteral

            function parseNumberLiteral():NumberLiteralNode
            {
                var reNumLtr:* = match(RE_NUMBER_LITERAL);
                var value:String = reNumLtr[1];
                var fraction:String = reNumLtr[2] || '';
                var precision:Number = fraction.length;
                return new NumberLiteralNode(parseFloat(value), precision);
            } // parseNumberLiteral

            function parseStringLiteral():StringLiteralNode
            {
                consumeChar('"', SyntaxError);
                var value:String = '';
                while (true)
                {
                    value += match1(RE_STRING_RUN);

                    if (source.charAt(cursor) === '\\')
                    {
                        value += parseEscapeSequence();
                        continue;
                    }

                    if (consumeChar('"'))
                    {
                        return new StringLiteralNode(value);
                    }

                    // We've reached an EOL of EOF.
                    throw new SyntaxError("Unclosed string literal");
                }
            } // parseStringLiteral

            // Unescape known escape sequences.
            function parseEscapeSequence():String
            {
                if (test(RE_STRING_ESCAPE))
                {
                    return match1(RE_STRING_ESCAPE);
                }

                if (test(RE_UNICODE_ESCAPE))
                {
                    var ue:* = match(RE_UNICODE_ESCAPE);
                    var codepoint4:String = ue[1];
                    var codepoint6:String = ue[2];
                    var codepoint:Number = parseInt(codepoint4 || codepoint6, 16);
                    return codepoint <= 0xd7ff || 0xe000 <= codepoint
                        ? // It's a Unicode scalar value.
                            UTF16.stringFromCodePoint(codepoint)
                        :
                        // Lonely surrogates can cause trouble when the parsing result is
                        // saved using UTF-8. Use U+FFFD REPLACEMENT CHARACTER instead.
                            "\uFFFD";
                }

                throw new SyntaxError("Unknown escape sequence");
            } // parseEscapeSequence

            // Parse blank space. Return it if it looks like indent before a pattern
            // line. Skip it othwerwise.
            function parseIndent():*
            {
                var start:Number = cursor;
                consumeToken(TOKEN_BLANK);

                // Check the first non-blank character after the indent.
                switch (source.charAt(cursor))
                {
                    case '.':
                    case '[':
                    case '*':
                    case '}':
                    case undefined: // EOF
                        // A special character. End the Pattern.
                        return false;
                    case '{':
                        // Placeables don't require indentation (in EBNF: block-placeable).
                        // Continue the Pattern.
                        return makeIndent(source.slice(start, cursor));
                }

                // If the first character on the line is not one of the special characters
                // listed above, it's a regular text character. Check if there's at least
                // one space of indent before it.
                if (source.charAt(cursor - 1) === ' ')
                {
                    // It's an indented text character (in EBNF: indented-char). Continue
                    // the Pattern.
                    return makeIndent(source.slice(start, cursor));
                }

                // A not-indented text character is likely the identifier of the next
                // message. End the Pattern.
                return false;
            } // parseIndent

            // Trim blanks in text according to the given regex.
            function trim(text:String, re:StickyRegExp):String
            {
                return text.replace(re.regExp, '');
            }

            // Normalize a blank block and extract the indent details.
            function makeIndent(blank:String):Indent
            {
                var value:String = blank.replace(RE_BLANK_LINES.regExp, '\n');
                var length:Number = RE_INDENT.regExp.exec(blank)[1].length;
                return new Indent(value, length);
            }
        }
    }
}