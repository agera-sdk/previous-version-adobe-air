package com.rialight.intl.ftl
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.util.*;
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
        private var m_localeToPathComponents:Map = new Map;

        // Set.<String>
        private var m_supportedLocales:Set = new Set;

        private var m_defaultLocale:Locale;

        // Map.<String, Vector.<String>>
        private var m_fallbacks:Map = new Map;

        // Map.<String, FluentBundle>
        private var m_assets:Map = new Map;

        private var m_assetSource:String;
        private var m_assetFiles:Vector.<String>;
        private var m_cleanUnusedAssets:Boolean;
        private var m_loadMethod:String;

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

        private static const PRIVATE_CONSTRUCTOR:* = {};

        /**
         * Constructs a FTL object.
         */
        public function FTL(options:*)
        {
            if (options === PRIVATE_CONSTRUCTOR)
            {
                return;
            }
            if (typeof options !== 'object')
            {
                throw new ArgumentError('Invalid options argument');
            }
            if (!(options.supportedLocales is Array))
            {
                throw new ArgumentError('options.supportedLocales must be an Array');
            }
            for each (var unparsedLocale:String in options.supportedLocales)
            {
                var parsedLocale:Locale = parseLocaleOrThrow(unparsedLocale);
                m_localeToPathComponents.set(parsedLocale.toString(), unparsedLocale);
                m_supportedLocales.add(parsedLocale.toString());
            }
            var fallbacks:Object = options.fallbacks || {};
            for (var fallbackUnparsedLocale:String in fallbacks)
            {
                var fallbackParsedLocale:Locale = parseLocaleOrThrow(fallbackUnparsedLocale);
                var fallbackArray:Array = fallbacks[fallbackUnparsedLocale] as Array;
                if (!fallbackArray)
                {
                    throw new ArgumentError('options.fallbacks must map Locales to Arrays');
                }
                m_fallbacks.set(fallbackParsedLocale.toString(), fallbackArray.map(function(a:*):String
                {
                    if (typeof a !== 'string')
                    {
                        throw new ArgumentError('options.fallbacks object is malformed');
                    }
                    return parseLocaleOrThrow(a).toString();
                }));
            }
            if (typeof options.defaultLocale !== 'string')
            {
                throw new ArgumentError('options.defaultLocale must be a String');
            }
            m_defaultLocale = parseLocaleOrThrow(options.defaultLocale);
            if (typeof options.assetSource !== 'string')
            {
                throw new ArgumentError('options.assetSource must be a String');
            }
            m_assetSource = String(options.assetSource);
            if (!(options.assetFiles is Array))
            {
                throw new ArgumentError('options.assetFiles must be an Array');
            }
            m_assetFiles = new Vector.<String>(options.assetFiles as Array);
            if (typeof options.cleanUnusedAssets !== 'boolean')
            {
                throw new ArgumentError('options.cleanUnusedAssets must be a Boolean');
            }
            m_cleanUnusedAssets = !!options.cleanUnusedAssets;
            if (['http', 'fileSystem'].indexOf(options.loadMethod) === -1)
            {
                throw new ArgumentError('options.loadMethod must be one of ["http", "fileSystem"]');
            }
            m_loadMethod = options.loadMethod;
        } // FTL constructor

        /**
         * Returns a set of supported locales, reflecting
         * the ones that were specified when constructing the <code>FTL</code> object.
         */
        public function get supportedLocales():Set
        {
            var r:Set = new Set;
            for each (var v:String in m_supportedLocales)
            {
                r.add(new Locale(v));
            }
            return r;
        }

        /**
         * Returns <code>true</code> if the locale is one of the supported locales
         * that were specified when constructing the <code>FTL</code> object,
         * otherwise <code>false</code>.
         */
        public function supportsLocale(argument:Locale):Boolean
        {
            return m_supportedLocales.has(argument.toString());
        }

        /**
         * Returns the currently loaded locale or null if none.
         */
        public function get currentLocale():Locale
        {
            return m_currentLocale;
        }

        /**
         * Returns the currently loaded locale followed by its fallbacks or empty if no locale is loaded.
         */
        public function get localeAndFallbacks():Vector.<Locale>
        {
            if (m_currentLocale)
            {
                var r:Vector.<Locale> = new Vector.<Locale>([m_currentLocale]);
                _enumerateFallbacks(m_currentLocale.toString(), r);
                return r;
            }
            return new Vector.<Locale>;
        }

        /**
         * Returns the currently loaded fallbacks.
         */
        public function get fallbacks():Vector.<Locale>
        {
            if (m_currentLocale)
            {
                var r:Vector.<Locale> = new Vector.<Locale>;
                _enumerateFallbacks(m_currentLocale.toString(), r);
                return r;
            }
            return new Vector.<Locale>;
        }

        /**
         * Adds a callback function to initialize the <code>FluentBundle</code> object of a locale.
         * The callback is called when the locale is loaded.
         */
        /*
         * function initializeLocale(callback:Function):void;
         */

        /**
         * Attempts to load a locale and its fallbacks.
         * If the locale argument is specified, it is loaded.
         * Otherwise, if there is a default locale, it is loaded, and if not,
         * the method throws an error.
         * 
         * <p>If any resource fails to load, the returned Promise
         * resolves to <code>false</code>, otherwise <code>true</code>.</p>
         */
        public function load(newLocale:Locale = null):Promise
        {
            newLocale ||= m_defaultLocale;
            if (!this.supportsLocale(newLocale))
            {
                throw new ArgumentError('Unsupported locale: ' + newLocale.toString());
            }
            var self:FTL = this;
            return new Promise(function(resolve:Function, reject:Function):void
            {
                var toLoad:Set = new Set([newLocale]);
                self._enumerateFallbacks(newLocale.toString(), toLoad);

                var newAssets:Map = new Map;
                Promise.all(toLoad.toArray()
                    .map(function(a:Locale):Promise { return self.loadSingleLocale(a) }))
                    .then(function(res:Array):void
                    {
                        // res:[[String, FluentBundle]]
                        if (self.m_cleanUnusedAssets)
                        {
                            self.m_assets.clear();
                        }

                        for each (var pair:Array in res)
                        {
                            self.m_assets.set(pair[0], pair[1]);
                        }
                        self.m_currentLocale = newLocale;

                        // @todo run locale initializers
                        // ...

                        resolve(true);
                    })
                    .otherwise(function(_:*):void
                    {
                        resolve(false);
                    });
            });
        } // load

        // should resolve to [String, FluentBundle] (the first String is locale.toString())
        private function loadSingleLocale(locale:Locale):Promise
        {
        }
    }
}