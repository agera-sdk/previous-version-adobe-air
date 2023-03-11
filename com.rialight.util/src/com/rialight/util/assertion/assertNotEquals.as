package com.rialight.util.assertion
{
    public function assertNotEquals(left:*, right:*, errorMessage:String = ''):void
    {
        if (left == right) throw new AssertionError(errorMessage || 'Assertion failed');
    }
}