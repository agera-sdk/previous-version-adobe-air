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

        if (arg is FTLNone)
        {
            return new FTLNone(format('NUMBER($1)', [FTLNone(arg).valueOf()]));
        }

        if (arg is FTLNumber)
        {
            var arg_asFTLNumber:FTLNumber = FTLNumber(arg);
            opts2 = {};
            for (k in arg_asFTLNumber.opts)
            {
                opts2[k] = arg_asFTLNumber.opts[k];
            }
            valuesResult = values(opts, NUMBER_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FTLNumber(arg_asFTLNumber.valueOf(), opts2);
        }

        if (arg is FTLDateTime)
        {
            var arg_asFTLDateTime:FTLDateTime = FTLDateTime(arg);
            opts2 = {};
            valuesResult = values(opts, NUMBER_ALLOWED);
            for (k in valuesResult)
            {
                opts2[k] = valuesResult[k];
            }
            return new FTLNumber(arg_asFTLDateTime.valueOf(), opts2);
        }

        throw new TypeError('Invalid argument to NUMBER');
    }
}