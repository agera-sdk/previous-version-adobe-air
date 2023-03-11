package com.rialight.util
{
    /**
     * Formats parameterized string.
     * <p><b>Syntax</b></p>
     * <p>
     * <ul>
     * <li><code>$parameterName</code></li>
     * <li><code>$&lt;parameterName-withHyphensNUnderscores&gt;</code></li>
     * <li><code>$$</code> translates to a single dollar sign.</li>
     * </ul>
     * </p>
     * <p><b>Example</b></p>
     * <listing version="3.0">
     * assertEquals(format('$&lt;foo-qux&gt;', { 'foo-qux': 'Fq' }), 'Fq');
     * assertEquals(format('$&lt;foo-qux&gt;', {}), 'undefined');
     * assertEquals(format('$1', ['foo']), 'foo');
     * </listing>
     */
    public function format(base:String, argumentsObject:*):String
    {
        // argumentsObject = argumentsObject ?? {};
        argumentsObject = argumentsObject !== undefined && argumentsObject !== null ? argumentsObject : {};
        if (argumentsObject is Array)
        {
            var array:Array = argumentsObject;
            argumentsObject = {};
            var i:Number = 0;
            for each (var v:* in array)
            {
                argumentsObject[(++i).toString()] = v;
            }
        }
        else if (argumentsObject is Map)
        {
            argumentsObject = Map(argumentsObject).toPlainObject();
        }
        return base.replace(/\$([a-z0-9]+|\<[a-z0-9\-_]+\>|\$)/gi, function(_:*, s:String):String
        {
            return s == '$' ? '$' : String(argumentsObject[s.replace('<', '').replace('>', '')]);
        });
    }
}