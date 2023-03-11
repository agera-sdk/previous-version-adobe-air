package com.rialight.intl
{
    public final class IntlPluralRules
    {
        public function IntlPluralRules(locales:*, options:* = undefined)
        {
            options ||= {};
        }

        public function select(num:Number):String
        {
            throw new Error('IntlPluralRules is unimplemented');
        }
    }
}