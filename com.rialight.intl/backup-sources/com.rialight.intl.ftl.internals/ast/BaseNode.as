package com.rialight.intl.ftl.internals.ast
{
    import com.rialight.util.*;

    /**
     * @private
     */
    public class BaseNode
    {
        public function equals(other:BaseNode, ignoredFields:Vector.<String> = null):Boolean
        {
            ignoredFields ||= new Vector.<String>(['span']);
            var fieldName:String = '';
            const thisKeys:Set = this.getKeys();
            const otherKeys:Set = other.getKeys();
            if (ignoredFields)
            {
                for each (fieldName in ignoredFields)
                {
                    thisKeys.deleteValue(fieldName);
                    otherKeys.deleteValue(fieldName);
                }
            }
            if (thisKeys.size !== otherKeys.size)
            {
                return false;
            }
            for each (fieldName in thisKeys)
            {
                if (!otherKeys.has(fieldName))
                {
                    return false;
                }
                const thisVal:* = this[fieldName];
                const otherVal:* = other[fieldName];
                if (typeof thisVal !== typeof otherVal)
                {
                    return false;
                }
                if (thisVal is Array && otherVal is Array)
                {
                    var thisVal_asArray:Array = thisVal as Array;
                    var otherVal_asArray:Array = otherVal as Array;
                    if (thisVal_asArray.length !== otherVal_asArray.length)
                    {
                        return false;
                    }
                    for (var i:Number = 0; i < thisVal_asArray.length; ++i)
                    {
                        if (!scalarsEqual(thisVal_asArray[i], otherVal_asArray[i], ignoredFields))
                        {
                            return false;
                        }
                    }
                }
                else if (!scalarsEqual(thisVal, otherVal, ignoredFields))
                {
                    return false;
                }
            }
            return true;
        }

        /**
         * @private
         */
        public function getKeys():Set
        {
            throw new Error('protected::getKeys() is unimplemented');
        }

        public function clone():BaseNode
        {
            throw new Error('clone() is unimplemented');
        }
    }
}