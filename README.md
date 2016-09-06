# Grithin's Bluebird Enhancements

## Use

### Expanding List of Promises

Whereas `Promise.all` does not account for array additions, `Promise.expanding_all` does
```coffee
delayed = (delay)->
	new Promise (resolve, reject)->
		setTimeout(resolve, delay)

promises = [delayed(1000)]
Promise.expanding_all(promises).then ()->
	console.log('done')
promises.push delayed(4000)
```


### Converting to Promiser

Bluebird turns a node-callback-style function into a promise, changing the params:
```coffee
connection.query 'SELECT * from sellers', (err, rows, fields)->
	''
query = Promise.promisify connection.query.bind(connection)
query('SELECT * from seller').then (rows)-> # can use .catch for errors
	''
```

I've created `Promise.convert` for when a function does not conform to the node-callback-style, or when more information about the arguments is desired
```coffee
query = Promise.convert(connection.query.bind(connection), color:'blue')
query('SELECT * from seller').then ({in_args, out_args, context})->
	{color} = context
	[query] = in_args
	[err, rows, fields] = out_args
```

### Later
My version of deferred

```coffee
# Normal resolve/reject
promised = Promise.later()
promised.then (resolved)-> c resolved
promised.resolve('resolved')

promised = Promise.later()
promised.catch (resolved)-> c resolved
promised.reject('rejected')

# Still allows inner function to call resolve/reject
promised = Promise.later((resolve, reject)-> resolve('inner resolve'))
promised.then (resolved)-> c resolved
```


### Promise While Loop
It is sometimes desirable to duplicate a synchronous while loop with functions that involve promises.  So, I constructed too for doing this

_promise while loop_
```coffee
i	=	0
condition = ()->
	i < 5
callback = ()->
	new Promise (resolve)->
		console.log(i)
		i += 1
		Promise.delay(300).then ()-> resolve()

Promise.while(condition, callback).then ()->
	console.log('done')
```