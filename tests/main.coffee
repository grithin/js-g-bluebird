# gulp build && mocha tests/main.js
expect = require('chai').expect
require("blanket")()

global.Promise = require('bluebird')

require('../dist/main.js')

describe("Test Suite", ()->
	describe(".later", ()->
		did_run = false
		it("promise callback run", ()->
			pending_promise = Promise.later ()->
				did_run = true
			expect(did_run).to.equal(true)
		)
		it("promise unfulfilled", ()->
			pending_promise = Promise.later (()->)
			expect(pending_promise.isFulfilled()).to.equal(false)
		)
		it("promise fulfilled", ()->
			pending_promise = Promise.later (()->)
			pending_promise.resolve('test')
			expect(pending_promise.isFulfilled()).to.equal(true)
		)

		# doesn't run
		it("promise resolve correct value", ()->
			pending_promise = Promise.later (()->)
			pending_promise.then (value)->
				expect(value).to.equal('test')

			pending_promise.resolve('test')
		)

		# doesn't run
		it("promise reject correct value", ()->
			pending_promise = Promise.later (()->)
			pending_promise.catch (value)->
				expect(value).to.equal('test')
			pending_promise.reject('test')
		)
	)
	describe(".expanding_all", ()->
		it("empty array", (done)->
			ended = false
			Promise.expanding_all([]).then ()->
				ended = true
			setTimeout((()->
					expect(ended).to.equal(true)
					done()
				), 50)
		)
		it("expanded unfulfilled", (done)->
			ended = false
			delayed = (delay)->
				new Promise (resolve, reject)->
					setTimeout(resolve, delay)

			promises = [delayed(50)]
			Promise.expanding_all(promises).then ()->
				ended = true
			promises.push delayed(500)

			setTimeout((()->
					expect(ended).to.equal(false)
					done()
				), 50)
		)
		it("expanded fulfilled", (done)->
			ended = false
			delayed = (delay)->
				new Promise (resolve, reject)->
					setTimeout(resolve, delay)

			promises = [delayed(40)]
			Promise.expanding_all(promises).then ()->
				ended = true
			promises.push delayed(5)

			setTimeout((()->
					expect(ended).to.equal(true)
					done()
				), 50)
		)
	)
)