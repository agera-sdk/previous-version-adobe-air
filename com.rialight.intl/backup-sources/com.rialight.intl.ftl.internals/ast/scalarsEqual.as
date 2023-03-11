package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    internal function scalarsEqual(thisVal:*, otherVal:*, ignoredFields:Vector.<String>):Boolean
    {
        if (thisVal is BaseNode && otherVal is BaseNode)
        {
            return BaseNode(thisVal).equals(BaseNode(otherVal), ignoredFields);
        }
        return thisVal === otherVal;
    }
}