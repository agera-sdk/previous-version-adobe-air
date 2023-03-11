package com.rialight.util
{
    import flash.utils.setTimeout;

    /**
     * The Promise object represents the eventual completion (or failure)
     * of an asynchronous operation and its resulting value.
     * 
     * <p>For more information, consult
     * https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise.</p>
     *
     * <p><b>Example:</b></p>
     * 
     * <listing version="3.0">
     * promiseObject
     *     .then(function(value:*):* {})
     *     .otherwise(function(error:*):* {})
     *     .always(function():void {});
     * </listing>
     */
    public final class Promise
    {
        // implementation based on
        // https://github.com/taylorhakes/promise-polyfill

        private var m_state:Number = 0;
        private var m_handled:Boolean = false;
        private var m_value:* = undefined;
        private var m_deferreds:Vector.<PromiseHandler> = new Vector.<PromiseHandler>;

        private static function bindFunction(fn:Function, thisArg:*):Function
        {
            return function(...argumentsList):void
            {
                fn.apply(thisArg, argumentsList);
            };
        }

        public function Promise(fn:Function)
        {
            doResolve(fn, this);
        }

        private static function handle(self:Promise, deferred:PromiseHandler):void
        {
            while (self.m_state === 3)
            {
                self = self.m_value;
            }
            if (self.m_state === 0)
            {
                self.m_deferreds.push(deferred);
                return;
            }
            self.m_handled = true;
            Promise._immediateFn(function():void
            {
                var cb:Function = self.m_state === 1 ? deferred.onFulfilled : deferred.onRejected;
                if (cb === null)
                {
                    (self.m_state === 1 ? Promise.privateResolve : Promise.privateReject)(deferred.promise, self.m_value);
                    return;
                }
                var ret:* = undefined;
                try
                {
                    ret = cb(self.m_value);
                }
                catch (e:*)
                {
                    Promise.privateReject(deferred.promise, e);
                    return;
                }
                Promise.privateResolve(deferred.promise, ret);
            });
        }

        private static function privateResolve(self:Promise, newValue:*):void
        {
            try
            {
                // Promise Resolution Procedure: https://github.com/promises-aplus/promises-spec#the-promise-resolution-procedure
                if (newValue === self)
                {
                    throw new TypeError('A promise cannot be resolved with itself.');
                }
                if (newValue is Promise)
                {
                    self.m_state = 3;
                    self.m_value = newValue;
                    Promise.finale(self);
                    return;
                }
                self.m_state = 1;
                self.m_value = newValue;
                Promise.finale(self);
            }
            catch (e:*)
            {
                Promise.privateReject(self, e);
            }
        }

        private static function privateReject(self:Promise, newValue:*):void
        {
            self.m_state = 2;
            self.m_value = newValue;
            Promise.finale(self);
        }

        private static function finale(self:Promise):void
        {
            if (self.m_state === 2 && self.m_deferreds.length === 0)
            {
                Promise._immediateFn(function():void
                {
                    if (!self.m_handled)
                    {
                        Promise._unhandledRejectionFn(self.m_value);
                    }
                });
            }

            for (var i:Number = 0, len:Number = self.m_deferreds.length; i < len; i++)
            {
                handle(self, self.m_deferreds[i]);
            }
            self.m_deferreds = null;
        }

        /**
         * Takes a potentially misbehaving resolver function and make sure
         * onFulfilled and onRejected are only called once.
         *
         * Makes no guarantees about asynchrony.
         */
        private static function doResolve(fn:Function, self:Promise):void
        {
            var done:Boolean = false;
            try
            {
                fn(
                    function(value:*):*
                    {
                        if (done) return;
                        done = true;
                        Promise.privateResolve(self, value);
                    },
                    function(reason:*):*
                    {
                        if (done) return;
                        done = true;
                        Promise.privateReject(self, reason);
                    }
                );
            }
            catch (ex:*)
            {
                if (done) return;
                done = true;
                Promise.privateReject(self, ex);
            }
        }

        /**
         * The <code>Promise.allSettled()</code> static method takes an iterable of promises
         * as input and returns a single Promise.
         * This returned promise fulfills when all of the input's promises settle
         * (including when an empty iterable is passed), with an array of objects that
         * describe the outcome of each promise.
         * <p><b>Example:</b></p>
         * <listing version="3.0">
         * const promise1:Promise = Promise.resolve(3);
         * const promise2:Promise = new Promise(function(resolve:Function, reject:Function):void
         * {
         *     setTimeout(reject, 100, 'foo');
         * });
         * Promise.allSettled([promise1, promise2])
         *     .then(function(results:Array):void
         *     {
         *         for each (var result:* in results)
         *         {
         *             trace(result.status);
         *         }
         *     });
         * // expected output:
         * // 'fulfilled'
         * // 'rejected'
         * </listing>
         * 
         * @return A <code>Promise</code> that is:
         * <ul>
         * <li><b>Already fulfilled,</b> if the iterable passed is empty.</li>
         * <li><b>Asynchronously fulfilled,</b> when all promises in the given
         * iterable have settled (either fulfilled or rejected).
         * The fulfillment value is an array of objects, each describing the
         * outcome of one promise in the iterable, in the order of the promises passed,
         * regardless of completion order. Each outcome object has the following properties:
         *   <ul>
         *     <li><code>status</code>: A string, either <code>"fulfilled"</code> or <code>"rejected"</code>, indicating the eventual state of the promise.</li>
         *     <li><code>value</code>: Only present if <code>status</code> is <code>"fulfilled"</code>. The value that the promise was fulfilled with.</li>
         *     <li><code>reason</code>: Only present if <code>status</code> is <code>"rejected"</code>. The reason that the promise was rejected with.</li>
         *   </ul>
         * </li>
         * <p>If the iterable passed is non-empty but contains no pending promises,
         * the returned promise is still asynchronously (instead of synchronously) fulfilled.</p>
         * </ul>
         */
        public static function allSettled(promises:Array):Promise
        {
            return new Promise(function(resolve:Function, reject:Function):void
            {
                var args:Array = promises.slice(0);
                if (args.length === 0)
                {
                    resolve([]);
                    return;
                }
                var remaining:Number = args.length;
                function res(i:Number, val:*):void
                {
                    if (val is Promise)
                    {
                        Promise(val).then(
                            function(val:*):*
                            {
                                res(i, val);
                            },
                            function(e:*):*
                            {
                                args[i] = { status: 'rejected', reason: e };
                                if (--remaining === 0)
                                {
                                    resolve(args);
                                }
                            }
                        );
                        return;
                    }
                    args[i] = { status: 'fulfilled', value: val };
                    if (--remaining === 0)
                    {
                        resolve(args);
                    }
                }
                for (var i:Number = 0; i < args.length; ++i)
                {
                    res(i, args[i]);
                }
            });
        } // allSettled

        /**
         * See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/any
         */
        public static function any(promises:Array):Promise
        {
            return new Promise(function(resolve:Function, reject:Function):void
            {
                var args:Array = promises.slice(0);
                if (args.length === 0)
                {
                    reject(undefined);
                    return;
                }
                var rejectionReasons:Array = [];
                for (var i:Number = 0; i < args.length; ++i)
                {
                    try
                    {
                        Promise.resolve(args[i])
                            .then(resolve)
                            .promiseCatch(function(error:*):*
                            {
                                rejectionReasons.push(error);
                                if (rejectionReasons.length === args.length)
                                {
                                    reject(
                                        new AggregateError(
                                            rejectionReasons,
                                            'All promises were rejected'
                                        )
                                    );
                                }
                            });
                    }
                    catch (ex:*)
                    {
                        reject(ex);
                    }
                }
            });
        } // any

        public function always(callback:Function):Promise
        {
            return promiseFinally(callback);
        }

        public function promiseFinally(callback:Function):Promise
        {
            return this.then(
                function(value:*):*
                {
                    return Promise.resolve(callback()).then(function(_:*):*
                    {
                        return value;
                    });
                },
                function(reason:*):*
                {
                    return Promise.resolve(callback()).then(function(_:*):*
                    {
                        return Promise.reject(reason);
                    });
                }
            );
        } // promiseFinally

        public function otherwise(onRejected:Function):Promise
        {
            return this.promiseCatch(onRejected);
        }

        public function promiseCatch(onRejected:Function):Promise
        {
            return this.then(null, onRejected);
        }

        public function then(onFulfilled:Function, onRejected:Function = null):Promise
        {
            var prom:Promise = new Promise(function(_a:*, _b:*):void {});
            Promise.handle(this, new PromiseHandler(onFulfilled, onRejected, prom));
            return prom;
        }

        /**
         * See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/all.
         */
        public static function all(promises:Array):Promise
        {
            return new Promise(function(resolve:Function, reject:Function):void
            {
                var args:Array = promises.slice(0);
                if (args.length === 0)
                {
                    resolve([]);
                    return;
                }
                var remaining:Number = args.length;

                function res(i:Number, val:*):void
                {
                    try
                    {
                        if (val is Promise)
                        {
                            Promise(val).then(
                                function(val:*):*
                                {
                                    res(i, val);
                                },
                                reject
                            );
                            return;
                        }
                        args[i] = val;
                        if (--remaining === 0)
                        {
                            resolve(args);
                        }
                    }
                    catch (ex:*)
                    {
                        reject(ex);
                    }
                }

                for (var i:Number = 0; i < args.length; i++)
                {
                    res(i, args[i]);
                }
            });
        } // all

        /**
         * See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/resolve
         */
        public static function resolve(value:*):Promise
        {
            if (value is Promise)
            {
                return Promise(value);
            }

            return new Promise(function(resolve:Function, reject:Function):void
            {
                resolve(value);
            });
        }

        /**
         * See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/reject
         */
        public static function reject(value:*):Promise
        {
            return new Promise(function(resolve:Function, reject:Function):void
            {
                reject(value);
            });
        }

        /**
         * See https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Promise/race
         */
        public static function race(promises:Array):Promise
        {
            return new Promise(function(resolve:Function, reject:Function):void
            {
                for each (var arg:* in promises)
                {
                    Promise.resolve(arg).then(resolve, reject);
                }
            });
        }

        private static function _immediateFn(fn:Function):void
        {
            setTimeout(fn, 0);
        }

        private static function _unhandledRejectionFn(err:*):void
        {
            trace('Possible Unhandled Promise Rejection:', err);
        }
    }
}