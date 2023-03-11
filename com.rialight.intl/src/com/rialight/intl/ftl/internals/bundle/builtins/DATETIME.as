package com.rialight.intl.ftl.internals.bundle.builtins
{
    import com.rialight.intl.ftl.types.*;
    import com.rialight.util.*;

    /**
     * @private
     */
    public function DATETIME
    (
        args:Array,
        opts:*
    ):*
    {
        var arg:* = args[0];
        var opts2:*;
        var k:String;
        var valuesResult:*;

        if (arg is FluentNone)
        {
            return new FluentNone(format('DATETIME($1)', [FluentNone(arg).valueOf()]));
        }

        if (arg is FluentDateTime)
        {
            var arg_asFluentDateTime:FluentDateTime = FluentDateTime(arg);
            opts2 = {};
            for (k in arg_asFluentDateTime.opts)
            {
                opts2[k] = arg_asFluentDateTime.opts[k];
            }
            valuesResult = values(opts, DATETIME_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FluentDateTime(arg_asFluentDateTime.valueOf(), opts2);
        }

        if (arg is FluentNumber)
        {
            var arg_asFluentNumber:FluentNumber = FluentNumber(arg);
            opts2 = {};
            valuesResult = values(opts, DATETIME_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FluentDateTime(arg_asFluentNumber.valueOf(), opts2);
        }

        throw new TypeError('Invalid argument to DATETIME');
    }
}