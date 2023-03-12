package com.rialight.intl
{
    import flash.globalization.LocaleID;
    import flash.globalization.LastOperationStatus;

    /**
     * <code>Locale</code> represents a Unicode locale identifier.
     */
    public final class Locale
    {
        // based on Unicode Language and Locale Identifiers
        // https://unicode.org/reports/tr35/tr35.html#Unicode_Language_and_Locale_Identifiers

        private var m_fgLocale:flash.globalization.LocaleID;

        private static const PARSE_ERROR_STATUS:Vector.<String> = new <String>
        [
            LastOperationStatus.INVALID_CHAR_FOUND,
            LastOperationStatus.UNEXPECTED_TOKEN,
            LastOperationStatus.ILLEGAL_ARGUMENT_ERROR,
            LastOperationStatus.PARSE_ERROR,
        ];

        public function Locale(tag:*)
        {
            if (tag is Locale)
            {
                tag = Locale(tag).m_fgLocale;
            }
            else if (typeof tag === 'string')
            {
                tag = new flash.globalization.LocaleID(tag);
            }
            if (!(tag is flash.globalization.LocaleID))
            {
                throw new ArgumentError('Invalid argument to Locale constructor');
            }
            m_fgLocale = tag;
            if (PARSE_ERROR_STATUS.indexOf(m_fgLocale.lastOperationStatus) !== -1)
            {
                throw new ArgumentError('Incorrect locale information provided');
            }
        }

        public function get language():String
        {
            return this.m_fgLocale.getLanguage();
        }

        public function get region():String
        {
            return this.m_fgLocale.getRegion();
        }

        public function get script():String
        {
            return this.m_fgLocale.getScript();
        }

        public function get variant():String
        {
            return this.m_fgLocale.getVariant();
        }

        public function get isRightToLeft():Boolean
        {
            return this.m_fgLocale.isRightToLeft();
        }

        public function get wraps():flash.globalization.LocaleID
        {
            return this.m_fgLocale;
        }

        public function toString():String
        {
            return this.m_fgLocale.name;
        }
    }
}