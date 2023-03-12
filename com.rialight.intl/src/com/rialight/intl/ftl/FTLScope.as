package com.rialight.intl.ftl
{
    import com.rialight.intl.*;
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.util.*;

    import flash.utils.Dictionary;

    /**
     * Represents a Fluent scope.
     */
    public final class FTLScope
    {
        public var bundle:FTLBundle;
        public var errors:Array;
        public var args:*;
        public var dirty:Dictionary = new Dictionary(true);
        public var params:* = null;
        public var placeables:Number = 0;

        public function FTLScope
        (
            bundle:FTLBundle,
            errors:Array,
            args:*
        )
        {
            this.bundle = bundle;
            this.errors = errors;
            this.args = args;
        }

        public function reportError(error:*):void
        {
            if (!this.errors || !(error is Error))
            {
                throw error;
            }
            this.errors.push(error);
        }

        public function memoizeIntlObject(ctor:*, opts:*):*
        {
            var cache:* = this.bundle._intls.get(ctor);
            if (!cache)
            {
                cache = {};
                this.bundle._intls.set(ctor, cache);
            }
            var id:String = JSON.stringify(opts);
            if (!cache[id])
            {
                cache[id] = new ctor(this.bundle.locales, opts);
            }
            return cache[id];
        }
    }
}