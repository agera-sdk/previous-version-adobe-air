package com.rialight.intl.ftl.internals.bundle.builtins
{
    import com.rialight.intl.ftl.types.*;

    /**
     * @private
     */
    internal function values
    (
        opts:*,
        allowed:Vector.<String>
    ):*
    {
        const unwrapped:* = {};
        for (var name:String in opts)
        {
            var opt:* = opts[name];
            if (allowed.indexOf(name) != -1 && opt !== undefined && opt !== null)
            {
                unwrapped[name] = opt.valueOf();
            }
        }
        return unwrapped;
    }
}