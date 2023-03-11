package com.rialight.intl.ftl
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.util.*;
    import com.rialight.intl.ftl.internals.bundle.FluentBundle;
    import com.rialight.intl.ftl.internals.bundle.FluentResource;

    /**
     * Interface for working with Fluent Translation Lists.
     */
    public final class FTL
    {
        private var m_currentLocale:Locale;

        // Map.<String, String>
        // Maps a locale identifier String to its equivalent path component.
        // The string mapped depends in how the
        // FTL object was constructed. If the `supportedLocales` option
        // contains "en-us", then `m_localeToPathComponents.get(new Locale("en-US").toString())` returns "en-us".
        // When FTLs are loaded, this component is appended to the URL or file path;
        // for example, `"res/lang/en-us"`.
        private var m_localeToPathComponents:Map;

        // Set.<String>
        private var m_supportedLocales:Set;

        private var m_defaultLocale:Locale;

        // Map.<String, Vector.<Locale>>
        private var m_fallbacks:Map;

        // Map.<String, FluentBundle>
        private var m_assets:Map;

        private var m_assets_source:String;
        private var m_assets_files:Vector.<String>;
        private var m_assets_cleanUnused:Boolean;
        private var m_assets_loadMethod:String;

        private static function parseLocaleOrThrow(s:String):Locale
        {
            try
            {
                return new Locale(s);
            }
            catch (e:*)
            {
                throw new Error(s + ' is a malformed locale');
            }
        }

        private static function addFTLBundleResource(fileName:String, source:String, bundle:FluentBundle):Boolean
        {
            try
            {
                var res:FluentResource = new FluentResource(source);
                var resErrors:Vector.<Error> = bundle.addResource(res);
                if (resErrors.length > 0)
                {
                    for each (var error:Error in resErrors)
                    {
                        trace(format('Error at $1.ftl: $2', [fileName, error.message]));
                    }
                    return false;
                }
            }
            catch (error:SyntaxError)
            {
                trace(format('Error at $1.ftl: $2', [fileName, error.message]));
                return false;
            }
            return true;
        }

        public function FTL(options:*)
        {
            //
        }
    }
}