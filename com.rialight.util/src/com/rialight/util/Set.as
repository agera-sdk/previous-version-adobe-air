package com.rialight.util
{
    import flash.utils.Dictionary;
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    /**
     * Set of values with insertion order.
     * <p><b>Constructor</b></p>
     * <p>A Set object can be constructed in different ways:</p>
     * <listing version="3.0">
     * new Set;
     * new Set([ v1, v2 ]);
     * new Set(anotherSet);
     * new Set(map);
     * new Set(flashDictionary);
     * new Set(plainObject);
     * </listing>
     */
    public final class Set extends Proxy
    {
        private var m_values:Vector.<*> = new Vector.<*>;

        public function Set(argumentValue:* = undefined)
        {
            var v:*;

            if (argumentValue is Array)
            {
                for each (v in argumentValue)
                {
                    if (m_values.indexOf(v) == -1)
                    {
                        m_values.push(v);
                    }
                }
            }
            else if (argumentValue is Set)
            {
                m_values = Set(argumentValue).m_values.slice(0);
            }
            else if (argumentValue is Map)
            {
                for each (v in Map(argumentValue).values())
                {
                    if (m_values.indexOf(v) == -1)
                    {
                        m_values.push(v);
                    }
                }
            }
            else if (argumentValue is Dictionary)
            {
                var dict:Dictionary = Dictionary(argumentValue);
                for (v in dict)
                {
                    if (m_values.indexOf(v) == -1 && !!dict[v])
                    {
                        m_values.push(v);
                    }
                }
            }
            else if (!!argumentValue && argumentValue.constructor == Object)
            {
                for (v in argumentValue)
                {
                    if (m_values.indexOf(v) == -1 && !!argumentValue[v])
                    {
                        m_values.push(v);
                    }
                }
            }
            else if (argumentValue !== undefined)
            {
                throw new ArgumentError('Invalid argument given to Map constructor.');
            }
        }

        public function get size():Number
        {
            return m_values.length;
        }

        public function clear():void
        {
            m_values.length = 0;
        }

        public function add(value:*):Set
        {
            if (m_values.indexOf(value) == -1)
            {
                m_values.push(value);
            }
            return this;
        }

        public function deleteValue(value:*):Boolean
        {
            var i:Number = this.m_values.indexOf(value);
            if (i == -1)
            {
                return false;
            }
            this.m_values.removeAt(i);
            return true;
        }

        public function has(value:*):Boolean
        {
            return this.m_values.indexOf(value) != -1;
        }

        override flash_proxy function nextNameIndex(index:int):int
        {
            if (index < m_values.length)
            {
                return index + 1;
            }
            else
            {
                return 0;
            }
        }

        override flash_proxy function nextValue(index:int):*
        {
            return m_values[index - 1];
        }

        public function toArray():Array
        {
            var r:Array = [];
            for each (var v:* in this.m_values)
            {
                if (r.indexOf(v) == -1)
                {
                    r.push(v);
                }
            }
            return r;
        }

        public function toPlainObject():*
        {
            var r:* = {};
            for each (var v:* in this.m_values)
            {
                r[v] = true;
            }
            return r;
        }

        public function toFlashDictionary():Dictionary
        {
            var r:Dictionary = new Dictionary;
            for each (var v:* in this.m_values)
            {
                r[v] = true;
            }
            return r;
        }
    }
}