package com.rialight.intl.ftl.types
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.FluentScope;

    public class FluentDateTime extends FluentType
    {
        /**
         * Options passed to <code>IntlDateTimeFormat</code>.
         */
        public var opts:*;

        public function FluentDateTime(value:Number, opts:* = undefined)
        {
            super(value);
            this.opts = opts || {};
        }

        override public function toString(scope:FluentScope):String
        {
            try
            {
                const dtf:IntlDateTimeFormat = scope.memoizeIntlObject(IntlDateTimeFormat, this.opts);
                return dtf.format(this.value);
            }
            catch (err:*)
            {
                scope.reportError(err);
                return new Date(this.value).toISOString();
            }
        }
    }
}