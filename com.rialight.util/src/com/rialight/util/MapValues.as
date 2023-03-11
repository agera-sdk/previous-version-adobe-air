package com.rialight.util
{
    import flash.utils.Proxy;
    import flash.utils.flash_proxy;

    /**
     * @private
     */
    internal final class MapValues extends Proxy
    {
        private var m_map:Map = null;

        public function MapValues(map:Map)
        {
            m_map = map;
        }

        override flash_proxy function nextNameIndex(index:int):int
        {
            if (index < m_map.m_values.length)
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
            return m_map.m_values[index - 1];
        }
    }
}