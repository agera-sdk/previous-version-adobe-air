package com.rialight.intl
{
    public final class IntlDateTimeFormat
    {
        public function IntlDateTimeFormat(locales:*, options:* = undefined)
        {
            options ||= {};
        }

        public function format(date:*):String
        {
            throw new Error('IntlDateTimeFormat is unimplemented');
        }
    }
}