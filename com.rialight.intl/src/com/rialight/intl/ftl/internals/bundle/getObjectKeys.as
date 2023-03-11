package com.rialight.intl.ftl.internals.bundle
{
    /**
     * @private
     */
    internal function getObjectKeys(o:*):Array
    {
        var r:Array = [];
        for (var k:String in o)
        {
            r.push(k);
        }
        return r;
    }
}