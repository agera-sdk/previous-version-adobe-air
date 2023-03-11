package com.rialight.util
{
    /**
     * @private
     */
    internal final class PromiseHandler
    {
        public var onFulfilled:Function;
        public var onRejected:Function;
        public var promise:Promise;

        public function PromiseHandler(onFulfilled:Function, onRejected:Function, promise:Promise)
        {
            this.onFulfilled = onFulfilled;
            this.onRejected = onRejected;
            this.promise = promise;
        }
    }
}