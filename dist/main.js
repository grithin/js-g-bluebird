(function(){global="undefined"!=typeof global&&global||"undefined"!=typeof window&&window||this;var r;r=global.Promise||require("bluebird"),global.Promise=r,Promise.later=function(n){var e,o;return o=void 0,e=void 0,r=new Promise(function(r,t){if(o=r,e=t,n)return n(o,e)}),r.resolve=o,r.reject=e,r},Promise.expanding_all=function(r){return new Promise(function(n,e){var o;return(o=function(r,n){var e,t;if(e=void 0,typeof r!=typeof{}||!Array.isArray(r))throw new Error("Promises not an array of promises");return 0===r.length?n():(e=arguments,t=r.length,Promise.all(r).then(function(){return r.length!==t?o.apply(this,e):n()}))})(r,n)})},Promise.while=function(r,n){var e;return e=function(r,n){return r()?n().then(function(){return e(r,n)}):Promise.resolve()},Promise.resolve(e(r,n))},Promise.convert=function(r,n){return function(){var e;return e=Array.prototype.slice.call(arguments),new Promise(function(o){var t;return t=function(){return o({out_args:arguments,in_args:e,context:n})},e.push(t),_.partial.apply(_,[r].concat(e))()})}},Promise.serial=function(r,n){var e,o;return o=void 0!==n&&[n]||[],e=function(r){return Promise.resolve(r(o)).then(function(r){return o.push(r)})},Promise.each(r,e).then(function(){return o})},Promise.sequence=function(r,n){var e,o;return o=n,e=function(r){return Promise.resolve(r(o)).then(function(r){return o=r})},Promise.each(r,e).then(function(){return o})},Promise.stack=function(r){var n;return n=function(r){if(_.isFunction(r))return n.promise=n.promise.then(r);if(_.isObject(r)&&r.then)return n.promise=n.promise.then(function(){return r});throw new Error("Stack addition not a fn or promise")},n.promise=Promise.resolve(),r&&n(r),n}}).call(this);
//# sourceMappingURL=main.js.map