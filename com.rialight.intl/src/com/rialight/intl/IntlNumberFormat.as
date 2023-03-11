package com.rialight.intl
{
    public final class IntlNumberFormat
    {
        public function IntlNumberFormat(locales:*, options:* = undefined)
        {
            options ||= {};
        }

        public function format(num:Number):String
        {
            throw new Error('IntlNumberFormat is unimplemented');
        }
    }
}