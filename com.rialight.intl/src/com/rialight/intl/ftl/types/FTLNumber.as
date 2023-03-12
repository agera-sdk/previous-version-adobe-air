package com.rialight.intl.ftl.types
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.FTLScope;

    public class FTLNumber extends FTLType
    {
        /**
         * Options passed to <code>IntlNumberFormat</code>.
         */
        public var opts:*;

        public function FTLNumber(value:Number, opts:* = undefined)
        {
            super(value);
            this.opts = opts || {};
        }

        override public function toString(scope:FTLScope):String
        {
            try
            {
                const nf:IntlNumberFormat = scope.memoizeIntlObject(IntlNumberFormat, this.opts);
                return nf.format(this.value);
            }
            catch (err:*)
            {
                scope.reportError(err);
                return this.value.toString(10);
            }
        }
    }
}