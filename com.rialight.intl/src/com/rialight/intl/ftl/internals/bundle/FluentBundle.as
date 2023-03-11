package com.rialight.intl.ftl.internals.bundle
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.intl.ftl.internals.bundle.resolver.resolveComplexPattern;
    import com.rialight.util.*;

    /**
     * @private
     */
    public final class FluentBundle
    {
        public var locales:Array;

        public var _terms:Map = new Map;
        public var _messages:Map = new Map;
        public var _functions:*;
        public var _useIsolating:Boolean;
        public var _transform:Function;
        public var _intls:Map;

        public function FluentBundle(locales:*, options:* = undefined)
        {
            options ||= {};
            this.locales = locales is Array ? locales as Array : [locales];
            var functions:* = options.functions;
            var useIsolating:Boolean = options.useIsolating === undefined ? true : options.useIsolating;
            var transform:Function = options.transform !== undefined ? options.transform : function(v:String):String { return v; };

            var k:String;
            this._functions =
            {
                NUMBER: NUMBER,
                DATETIME: DATETIME
            };
            for (k in functions)
            {
                this._functions[k] = functions[k];
            }
            this._useIsolating = useIsolating;
            this._transform = transform;
            this._intls = getMemoizerForLocale(locales);;
        }

        public function hasMessage(id:String):Boolean
        {
            return this._messages.has(id);
        }

        public function getMessage(id:String):*
        {
            return this._messages.get(id);
        }

        public function addResource
        (
            res:FluentResource,
            options:* = undefined
        ):Vector.<Error>
        {
            options ||= {};
            var allowOverrides:Boolean = !!options.allowOverrides;

            const errors:Vector.<Error> = new Vector.<Error>;

            for (var i:Number = 0; i < res.body.length; ++i)
            {
                var entry:* = res.body[i];
                if (entry.id.startsWith('-'))
                {
                    // identifiers starting with a dash (-) define terms. terms are private
                    // and cannot be retrieved from FluentBundle.
                    if (allowOverrides === false && this._terms.has(entry.id))
                    {
                        errors.push
                        (
                            new Error(format('Attempt to override an existing term: "$1"', [entry.id]))
                        );
                        continue;
                    }
                    this._terms.set(entry.id, entry as TermNode);
                }
                else
                {
                    if (allowOverrides === false && this._messages.has(entry.id))
                    {
                        errors.push
                        (
                            new Error(format('Attempt to override an existing message: "$1"', [entry.id]))
                        );
                        continue;
                    }
                    this._messages.set(entry.id, entry);
                }
            }

            return errors;
        }

        public function formatPattern
        (
            pattern:*,
            args:* = null,
            errors:Array = null
        ):String
        {
            // resolve a simple pattern without creating a scope. no error handling is
            // required; by definition simple patterns don't have placeables.
            if (typeof pattern === 'string')
            {
                return this._transform(pattern);
            }

            // resolve a complex pattern.
            var scope:FluentScope = new FluentScope(this, errors, args);
            try
            {
                var value:FluentType = resolveComplexPattern(scope, pattern);
                return value.toString(scope);
            }
            catch (err:*)
            {
                if (!!scope.errors && (err is Error))
                {
                    scope.errors.push(err);
                    return (new FluentNone).toString(scope);
                }
                throw err;
            }
        }
    }
}