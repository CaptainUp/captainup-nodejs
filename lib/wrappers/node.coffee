# NodeJS Wrapper
# ---------------------------------------------------------------------------------------
# Wrapper methods to the NodeJS environment


# Sends an HTTP request, and returns the response either as a promise or in a callback.
# 
# The promises use the `bluebird` library, for HTTP requests we use `request`. This
# function acts as a wrapper for all the HTTP operations that we need in the NodeJS
# environment. A similar function, with (almost) the same signature and parameters,
# is implemented in `parse.coffee` to fit the Parse environment.
# 
# Example Usage:
# 
#   captain.request(url: '/status').done (data) ->
#     console.log(data)
# 
#   captain.request url: '/status', (err, data) ->
#     console.log(data)
# 
# @param options - {Object} an options hash:
#   - url - {String} Required. The relative URL of the API route we want to use
#   - method - {String} Optional. The HTTP method, set by default to 'GET'
#   - params - {Object} Optional. body parameters of the request.
#   - only_data - {Boolean} whether to only return the `data` section of the API
#     response, or the full API response, on successful requests. Set to false by
#     default.
#   - callback - {Function} Optional. A node-style callback
# 
# @returns {Promise} a promise of the HTTP request
# 
CaptainUp::request = (options = {}) ->
	# Require `bluebird` and `request`. We require and cache them here as we're not
	# using them in the Parse environment
	@Promise ||= require 'bluebird'
	@Request ||= require 'request'
	# Create a new promise for the HTTP request
	promise = new @Promise (resolve, reject) =>
		# Send an HTTP request
		@Request
			# Add the `url` option to the API base URL
			url: @api_base_url + options.url
			# By default, send a GET request, or use the `method` option
			method: options.method || 'GET'
			# For POST and PUT requests, sets the content type to `application/json`
			# and serializes the body properly. In all requests, `true` tells the
			# library to parse all responses as JSON
			json: if options.method in ['POST', 'PUT'] then options.params else true
			# Gzip the request
			gzip: true
		# Callback, with any unexpected `error`, the `response` and the response `data`
		, (error, response, data) ->
			# Reject the promise with an error, if it occurred
			return reject(error) if error
			# If the HTTP status code of the response isn't 200 or the API response status
			# code isn't 200 we reject the promise with the data
			if response.statusCode isnt 200 or data.code isnt 200
			then reject(data)
			else
				# Otherwise, we resolve the promise with the response body. if `only_data` was
				# set to true in the options, we only return the nested `data` structure from
				# the API.
				if options.only_data is true then resolve(data.data) else resolve(data)
	# Register a node-style callback on the promise, if it was passed in the options
	promise.nodeify(options.callback) if options.callback
	# Return the promise
	return promise

