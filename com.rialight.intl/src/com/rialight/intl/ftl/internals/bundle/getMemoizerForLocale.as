package com.rialight.intl.ftl.internals.bundle
{
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.util.*;

    /**
     * @private
     */
    public function getMemoizerForLocale(locales:*):Map
    {
        const stringLocale:String = locales is Array ? locales.join(' ') : String(locales);
        var memoizer:* = cache.get(stringLocale);
        if (memoizer === undefined)
        {
            memoizer = new Map;
            cache.set(stringLocale, memoizer);
        }
        return memoizer;
    }
}