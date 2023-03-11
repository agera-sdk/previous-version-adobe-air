package com.rialight.util
{
    import flash.utils.Dictionary;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    /**
     * Map of key-value pairs with insertion order.
     * <p><b>Constructor</b></p>
     * <p>A Map object can be constructed in different ways:</p>
     * <listing version="3.0">
     * new Map;
     * new Map([ [k1, v1], [k2, v2], ]);
     * new Map(plainObject);
     * new Map(anotherMap);
     * new Map(flashDictionary);
     * </listing>
     * <p><b>Iterator</b></p>
     * <p>The map iterator yields pairs consisting of
     * the key followed by the value.</p>
     * <listing version="3.0">
     * var mapObject:Map = new Map({x: 10, y: 16});
     * for each (var entry:Array in mapObject)
     * {
     *     trace('key:', entry[0]);
     *     trace('value:', entry[1]);
     * }
     * // key: 'x'
     * // value: 10
     * // key: 'y'
     * // value: 16
     * </listing>
     * <p><b>Manipulating keys</b></p>
     * <p>The keys of the Map object must be accessed with one of the following methods:
     * <ul>
     * <li><code>get(key)</code></li>
     * <li><code>set(key, value)</code></li>
     * <li><code>deleteKey(key)</code></li>
     * <li><code>has(key)</code></li>
     * </ul>
     * </p>
     * <p>You cannot use the ActionScript operators to access the Map keys.
     * This detail prevents conflict between ActionScript definitions and the
     * user keys of the Map.</p>
     * <p><b>Conversion methods</b></p>
     * <p>You can directly convert a Map object to other types:</p>
     * <listing version="3.0">
     * // returns an Object
     * mapObject.toPlainObject();
     * // returns a flash.utils.Dictionary
     * mapObject.toFlashDictionary();
     * </listing>
     */
    public final class Map extends Proxy
    {
        /**
         * @private
         */
        internal var m_keys:Vector.<*> = new Vector.<*>;
        /**
         * @private
         */
        internal var m_values:Vector.<*> = new Vector.<*>;

        public function Map(argumentValue:* = undefined)
        {
            var v:*;
            var a:Array = null;

            if (argumentValue is Array)
            {
                for each (v in argumentValue as Array)
                {
                    if (v is Array)
                    {
                        a = v as Array;
                        this.m_keys.push(a[0]);
                        this.m_values.push(a[1]);
                    }
                    else
                    {
                        throw new ArgumentError('Invalid argument given to Map constructor.');
                    }
                }
            }
            else if (argumentValue is Map)
            {
                m_keys = Map(argumentValue).m_keys.slice(0);
                m_values = Map(argumentValue).m_values.slice(0);
            }
            else if (argumentValue is Dictionary)
            {
                var dict:Dictionary = Dictionary(argumentValue);
                for (v in dict)
                {
                    this.m_keys.push(v);
                    this.m_values.push(dict[v]);
                }
            }
            else if (!!argumentValue && argumentValue.constructor == Object)
            {
                for (v in argumentValue)
                {
                    this.m_keys.push(v);
                    this.m_values.push(argumentValue[v]);
                }
            }
            else if (argumentValue !== undefined)
            {
                throw new ArgumentError('Invalid argument given to Map constructor.');
            }
        }

        public function get size():Number
        {
            return m_keys.length;
        }

        public function clear():void
        {
            m_keys.length = 0;
            m_values.length = 0;
        }

        public function get(key:*):*
        {
            var i:Number = this.m_keys.indexOf(key);
            return i == -1 ? undefined : this.m_values[i];
        }

        public function set(key:*, value:*):Map
        {
            var i:Number = this.m_keys.indexOf(key);
            if (i == -1)
            {
                this.m_keys.push(key);
                this.m_values.push(value);
            }
            else
            {
                this.m_values[i] = value;
            }
            return this;
        }

        public function deleteKey(key:*):Boolean
        {
            var i:Number = this.m_keys.indexOf(key);
            if (i == -1)
            {
                return false;
            }
            this.m_keys.removeAt(i);
            this.m_values.removeAt(i);
            return true;
        }

        public function has(key:*):Boolean
        {
            return this.m_keys.indexOf(key) != -1;
        }

        public function entries():MapEntries
        {
            return new MapEntries(this);
        }

        public function keys():MapKeys
        {
            return new MapKeys(this);
        }

        public function values():MapValues
        {
            return new MapValues(this);
        }

        override flash_proxy function nextNameIndex(index:int):int
        {
            if (index < m_keys.length)
            {
                return index + 1;
            }
            else
            {
                return 0;
            }
        }

        override flash_proxy function nextName(index:int):String
        {
            return String(m_keys[index - 1]);
        }

        override flash_proxy function nextValue(index:int):*
        {
            index -= 1;
            return [m_keys[index], m_values[index]];
        }

        public function toPlainObject():*
        {
            var r:* = {};
            for each (var entry:Array in this.entries())
            {
                r[entry[0]] = entry[1];
            }
            return r;
        }

        public function toFlashDictionary():Dictionary
        {
            var r:Dictionary = new Dictionary;
            for each (var entry:Array in this.entries())
            {
                r[entry[0]] = entry[1];
            }
            return r;
        }
    }
}