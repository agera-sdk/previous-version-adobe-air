package com.rialight.util
{
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    /**
     * @private
     */
    internal final class MapEntries extends Proxy
    {
        private var m_map:Map = null;

        public function MapEntries(map:Map)
        {
            m_map = map;
        }

        override flash_proxy function nextNameIndex(index:int):int
        {
            if (index < m_map.m_keys.length)
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
            index -= 1;
            return [m_map.m_keys[index], m_map.m_values[index]];
        }
    }
}