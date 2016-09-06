`global= (typeof(global) != 'undefined' && global)  || (typeof(window) != 'undefined' && window) || this`
promise = global.Promise || require('bluebird')
global.Promise = promise


#/return a promise that has a resolve and reject method (such that it can resolve itself)

###*
@param	fn	<optional, fn(resolve, reject)>
###

Promise.later = (fn) ->
	resolve = undefined
	reject = undefined
	promise = new Promise((lresolve, lreject) ->
		resolve = lresolve
		reject = lreject
		if fn
			fn resolve, reject	)

	promise.resolve = resolve
	promise.reject = reject
	promise

#/ like Promise.all, but handles expanding array of promises

###*
@note	if a promise is added after the previous array was already considered resolved, it will not un-resolve the promise returned by this function
@param	[<promise>,...]
###

Promise.expanding_all = (promises) ->
	new Promise((resolve, reject) ->
		recurse = (promises, resolve) ->
			args = undefined
			if typeof promises != typeof {} or !Array.isArray(promises)
				throw new Error('Promises not an array of promises')
			if promises.length == 0
				return resolve()
			args = arguments
			count = promises.length
			Promise.all(promises).then ->
				if promises.length != count
					return recurse.apply this, args

				resolve()

		recurse promises, resolve
	)

Promise.while = (condition, callback)->
	next = (condition, callback)->
		if condition() # while condition
			callback().then ()-> next(condition, callback)
		else
			Promise.resolve()
	Promise.resolve(next(condition, callback))

# See README
Promise.convert = (callback, context)->
	()->
		primary_args = Array.prototype.slice.call(arguments)
		new Promise (resolve)->
			resolver = ()->
				# "return" kept for backwards compatibility (phantomjs)
				resolve({out_args: arguments, in_args: primary_args, context: context}) #< more is more

			primary_args.push resolver
			_.partial.apply(_,[callback].concat primary_args)()

			#callback.bind_args(primary_args)()


###
Call a series of functions, sequentially, while building, passing, and returning the array of individual function returns
	.serial([fn1,fn2,fn3], r0)
		fn1([r0]) -> r1
		fn2([r0, r1]) -> r2
		fn3([r0, r1, r2]) -> r3
		return [r0, r1, r2, r3]

Allows for non-promise-returning functions

Ex
	sequence = [
		()-> Promise.delay(1000).then(()->'bob1'),
		()-> Promise.delay(10).then(()->'bob2'),
		()-> Promise.delay(10).then(()->'bob3')
		]

	Promise.serial(sequence).then (r)->
		c arguments
###
Promise.serial = (sequence, first_result)->
	results = first_result != undefined && [first_result] || []

	call_next = (cb)->
		Promise.resolve(cb(results)).then (v)-> # dig, to allow non-promise fn's to be used
			results.push v

	Promise.each(sequence, call_next).then ()->
		results # return the results to the outside .then, if any


###
Call a series of functions, sequentially, while passing-thru the return, finally resolving with final fn return
	.serial([fn1,fn2,fn3], r0)
		fn1(r0) -> r1
		fn2(r1) -> r2
		fn3(r2) -> r3
		return r3

###
Promise.sequence = (sequence, first_result)->
	result = first_result
	call_next = (cb)->
		Promise.resolve(cb(result)).then (v)->
			result = v

	Promise.each(sequence, call_next).then ()->
		result # return the result of last fn


### Intended to replace the attached chain
Going from:
	bill().then(bob).then(sue)
to
	stack = Promise.stack(bill)
	stack bob
	stack sue


Ex
	# linear execution of looped promises.  If linear execution isn't desired, use Promise.all
	for i in [0...5]
		stack associate_product
	stack ()->
		# code that happens after the for loop

@NOTE	can access underlying promise with `stack.promise`
@NOTE	can stack either fn or promise
###
Promise.stack = (fn)->
	add_to_stack = (fn)->
		if !_.isFunction fn
			if _.isObject(fn) && fn.then
				add_to_stack.promise = add_to_stack.promise.then(()-> fn)
			else
				throw new Error('Stack addition not a fn or promise')
		else
			add_to_stack.promise = add_to_stack.promise.then(fn)

	add_to_stack.promise = Promise.resolve()

	# if maker is called with a fn, assume initialiser
	if fn
		add_to_stack(fn)

	add_to_stack
