package com.rialight.intl.ftl.internals.bundle
{
    /**
     * https://codesandbox.io/s/0ixby?file=/src/index.js
     *
     * @private
     */
    internal final class StickyRegExp
    {
        public var regExp:RegExp;
        public var sticky:Boolean;

        public function StickyRegExp(regExp:RegExp, sticky:Boolean = false)
        {
            this.regExp = regExp;
            this.sticky = sticky;
        }

        public function get lastIndex():Number
        {
            return this.regExp.lastIndex;
        }

        public function set lastIndex(value:Number):void
        {
            this.regExp.lastIndex = value;
        }

        public function test(str:String):Boolean
        {
            if (!sticky)
            {
                return regExp.test(str);
            }
            return !!this.exec(str);
        }

        public function exec(str:String):*
        {
            if (!sticky)
            {
                return regExp.exec(str);
            }
            const lastIndex:Number = regExp.lastIndex;
            const result:* = regExp.exec(str);
            if (!result || result.index !== lastIndex)
            {
                regExp.lastIndex = 0;
                return null;
            }
            return result;
        }

        public function toString():String
        {
            return this.regExp.toString();
        }
    }
}