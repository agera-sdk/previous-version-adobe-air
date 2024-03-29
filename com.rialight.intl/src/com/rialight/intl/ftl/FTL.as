package com.rialight.intl.ftl
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.util.*;
    import com.rialight.intl.ftl.internals.bundle.FTLResource;

    import flash.net.URLRequest;
    import flash.net.URLLoader;
    import flash.filesystem.File;
    import flash.filesystem.FileStream;
    import flash.utils.ByteArray;

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

        // Map.<String, [String]>
        private var m_fallbacks:Map = new Map;

        // Map.<String, FTLBundle>
        private var m_assets:Map = new Map;

        private var m_assetSource:String;
        private var m_assetFiles:Vector.<String>;
        private var m_bundleInitializers:Vector.<Function> = new Vector.<Function>;
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

        private static function addFTLBundleResource(fileName:String, source:String, bundle:FTLBundle):Boolean
        {
            try
            {
                var res:FTLResource = new FTLResource(source);
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
                var fallbackArray:* = fallbacks[fallbackUnparsedLocale];
                if (!fallbackArray)
                {
                    throw new ArgumentError('options.fallbacks must map Locales to Arrays');
                }
                m_fallbacks.set(fallbackParsedLocale.toString(), fallbackArray.map(function(a:*, ..._):String
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
            m_assetFiles = new Vector.<String>;
            // cannot construct like new Vector.<String>(untypedArray)
            for each (var fileName:String in options.assetFiles)
            {
                m_assetFiles.push(fileName);
            }
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
         * Adds a bundle initializer. This allows defining custom functions and more.
         * @param fn Function of the signature <code>function(locale:Locale, bundle:FTLBundle):void</code>.
         */
        public function addBundleInitializer(fn:Function):void
        {
            m_bundleInitializers.push(fn);
        }

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
                var r:Vector.<Locale> = Vector.<Locale>([m_currentLocale]);
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
         * Adds a callback function to initialize the <code>FTLBundle</code> object of a locale.
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
                self._enumerateFallbacksToSet(newLocale.toString(), toLoad);

                var newAssets:Map = new Map;
                Promise
                    .all
                    (
                        toLoad.toArray().map(function(a:Locale, ..._):Promise { return self.loadSingleLocale(a); })
                    )
                    .then(function(res:Array):void
                    {
                        // res:[[String, FTLBundle]]
                        if (self.m_cleanUnusedAssets)
                        {
                            self.m_assets.clear();
                        }

                        for each (var pair:Array in res)
                        {
                            self.m_assets.set(pair[0], pair[1]);
                        }
                        self.m_currentLocale = newLocale;

                        for each (var bundleInit:Function in self.m_bundleInitializers)
                        {
                            bundleInit(newLocale, m_assets.get(newLocale.toString()));
                        }

                        resolve(true);
                    })
                    .otherwise(function(_:*):void
                    {
                        resolve(false);
                    });
            });
        } // load

        private function get _assetFilesAsUntyped():Array
        {
            var r:Array = [];
            for each (var v:String in m_assetFiles)
            {
                r.push(v);
            }
            return r;
        }

        // should resolve to [String, FTLBundle] (the first String is locale.toString())
        private function loadSingleLocale(locale:Locale):Promise
        {
            var self:FTL = this;
            var localeAsStr:String = locale.toString();
            var bundle:FTLBundle = new FTLBundle(locale);

            if (self.m_loadMethod == 'fileSystem')
            {
                for each (var fileName:String in self.m_assetFiles)
                {
                    var localePathComp:* = self.m_localeToPathComponents.get(localeAsStr);
                    if (localePathComp === undefined)
                    {
                        throw new Error('Fallback is not a supported locale: ' + localeAsStr);
                    }
                    var resPath:String = format('$1/$2/$3.ftl', [self.m_assetSource, localePathComp, fileName]);
                    try
                    {
                        var fileStream:FileStream = new FileStream;
                        fileStream.open(/^file:|app:|app-storage:/i.test(resPath) ? new File(resPath) : File.workingDirectory.resolvePath(resPath), 'read');
                        var source:String = fileStream.readUTFBytes(fileStream.bytesAvailable);
                        fileStream.close();
                        FTL.addFTLBundleResource(fileName, source, bundle);
                    }
                    catch (err:*)
                    {
                        trace('Failed to load resource at ' + resPath);
                        return Promise.reject(undefined);
                    }
                }
                return Promise.resolve([localeAsStr, bundle]);
            }
            else
            {
                return Promise.all
                (
                    self.m_assetFilesAsUntyped.map
                    (
                        function(fileName:String, ..._):Promise
                        {
                            var localePathComp:* = self.m_localeToPathComponents.get(localeAsStr);
                            if (localePathComp === undefined)
                            {
                                throw new Error('Fallback is not a supported locale: ' + localeAsStr);
                            }
                            var resPath:String = format('$1/$2/$3.ftl', [self.m_assetSource, localePathComp, fileName]);
                            return new Promise(function(resolve:Function, reject:Function):void
                            {
                                // perform HTTP request
                                var urlReq:URLRequest = new URLRequest(resPath);
                                urlReq.method = 'get';
                                urlReq.contentType = 'application/text';
                                var urlLoader:URLLoader = new URLLoader;
                                urlLoader.dataFormat = 'text';
                                urlLoader.addEventListener('complete', function(e:*):void
                                {
                                    FTL.addFTLBundleResource(fileName, urlLoader.data, bundle);
                                    resolve(undefined);
                                });
                                urlLoader.addEventListener('ioError', function(e:*):void
                                {
                                    trace('Failed to load resource at ' + resPath);
                                    reject(undefined);
                                });
                                try
                                {
                                    urlLoader.load(urlReq);
                                }
                                catch (err:*)
                                {
                                    trace('Failed to load resource at ' + resPath);
                                    reject(undefined);
                                }
                            });
                        }
                    )
                )
                    .then(function(_:*):Array
                    {
                        return [localeAsStr, bundle];
                    });
            }
        } // loadSingleLocale

        private function _enumerateFallbacks(locale:String, output:Vector.<Locale>):void
        {
            var list:Array = this.m_fallbacks.get(locale);
            if (!list)
            {
                return;
            }
            for each (var item:String in list)
            {
                output.push(new Locale(item));
                _enumerateFallbacks(item, output);
            }
        }

        private function _enumerateFallbacksToSet(locale:String, output:Set):void
        {
            var list:Array = this.m_fallbacks.get(locale);
            if (!list)
            {
                return;
            }
            for each (var item:String in list)
            {
                output.add(new Locale(item));
                _enumerateFallbacksToSet(item, output);
            }
        }

        /**
         * Retrieves message and format it. Returns <code>null</code> if undefined.
         */
        public function getMessage(id:String, args:* = undefined, errors:Array = null):String
        {
            if (!m_currentLocale)
            {
                return null;
            }
            return _getMessageByLocale(id, m_currentLocale.toString(), args, errors);
        }

        private function _getMessageByLocale(id:String, locale:String, args:*, errors:Array):String
        {
            var assets:FTLBundle = m_assets.get(locale);
            if (assets)
            {
                var msg:* = assets.getMessage(id);
                if (msg !== undefined)
                {
                    return assets.formatPattern(msg.value, args, errors);
                }
            }
            var fallbacks:Array = m_fallbacks.get(locale);
            if (fallbacks)
            {
                for each (var fl:String in fallbacks)
                {
                    var r:String = _getMessageByLocale(id, fl, args, errors);
                    if (r !== null)
                    {
                        return r;
                    }
                }
            }
            return null;
        }

        /**
         * Determines if message is defined.
         */
        public function hasMessage(id:String):Boolean
        {
            return m_currentLocale ? _hasMessageByLocale(id, m_currentLocale.toString()) : false;
        }

        private function _hasMessageByLocale(id:String, locale:String):Boolean
        {
            var assets:FTLBundle = m_assets.get(locale);
            if (assets)
            {
                var msg:* = assets.getMessage(id);
                if (msg !== undefined)
                {
                    return true;
                }
            }
            var fallbacks:Array = m_fallbacks.get(locale);
            if (fallbacks)
            {
                for each (var fl:String in fallbacks)
                {
                    if (_hasMessageByLocale(id, fl))
                    {
                        return true;
                    }
                }
            }
            return false;
        }

        /**
         * Clones the FTL object, but returning an object that is
         * in sync with the original FTL object.
         */
        public function clone():FTL
        {
            var r:FTL = new FTL(PRIVATE_CONSTRUCTOR);
            r.m_currentLocale = this.m_currentLocale;
            r.m_localeToPathComponents = this.m_localeToPathComponents;
            r.m_supportedLocales = this.m_supportedLocales;
            r.m_defaultLocale = this.m_defaultLocale;
            r.m_fallbacks = this.m_fallbacks;
            r.m_bundleInitializers = this.m_bundleInitializers;
            r.m_assets = this.m_assets;
            r.m_assetSource = this.m_assetSource;
            r.m_assetFiles = this.m_assetFiles;
            r.m_cleanUnusedAssets = this.m_cleanUnusedAssets;
            r.m_loadMethod = this.m_loadMethod;
            return r;
        }
    }
}