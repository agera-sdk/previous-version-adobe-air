package com.rialight.intl.ftl.internals.bundle.resolver
{
    import com.rialight.intl.ftl.types.*;
    import com.rialight.intl.ftl.internals.bundle.*;
    import com.rialight.intl.ftl.internals.bundle.ast.*;
    import com.rialight.intl.ftl.internals.bundle.builtins.*;
    import com.rialight.util.*;

    /**
     * the maximum number of placeables which can be expanded in a single call to
     * `formatPattern`. the limit protects against the Billion Laughs and Quadratic
     * Blowup attacks. see https://msdn.microsoft.com/en-us/magazine/ee335713.aspx.
     * 
     * @private
     */
    internal const MAX_PLACEABLES:Number = 100;
}