package com.rialight.intl.ftl.internals.bundle.builtins
{
    import com.rialight.intl.ftl.types.*;
    import com.rialight.util.*;

    /**
     * @private
     */
    public function NUMBER
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
            return new FluentNone(format('NUMBER($1)', [FluentNone(arg).valueOf()]));
        }

        if (arg is FluentNumber)
        {
            var arg_asFluentNumber:FluentNumber = FluentNumber(arg);
            opts2 = {};
            for (k in arg_asFluentNumber.opts)
            {
                opts2[k] = arg_asFluentNumber.opts[k];
            }
            valuesResult = values(opts, NUMBER_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FluentNumber(arg_asFluentNumber.valueOf(), opts2);
        }

        if (arg is FluentDateTime)
        {
            var arg_asFluentDateTime:FluentDateTime = FluentDateTime(arg);
            opts2 = {};
            valuesResult = values(opts, NUMBER_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FluentNumber(arg_asFluentDateTime.valueOf(), opts2);
        }

        throw new TypeError('Invalid argument to NUMBER');
    }
}