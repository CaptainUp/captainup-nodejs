# Parse Wrapper
# ---------------------------------------------------------------------------------------
# Wrapper methods to the Parse environment


# Sends an HTTP request, and returns the response either as a promise or in a callback.
# 
# The promises are based on `Parse.Promise()`, for HTTP requests we use the Parse
# `Parse.Cloud.httpRequest()` function. This function acts as a wrapper for all the
# HTTP operations that we need in the Parse environment. A similar function, with
# (almost) the same signature and parameters, is implemented in `node.coffee` to fit
# the NodeJS environment.
# 
# Example Usage:
# 
#   captain.request(url: '/status').done (data) ->
#     console.log(data)
# 
#   captain.request
#     url: '/status'
#     success: (data) ->
#       console.log(data)
#     error: (error) ->
#       console.log(error)
# 
# @param options - {Object} an options hash:
#   - url - {String} Required. The relative URL of the API route we want to use
#   - method - {String} Optional. The HTTP method, set by default to 'GET'
#   - params - {Object} Optional. body parameters of the request.
#   - only_data - {Boolean} whether to only return the `data` section of the API
#     response, or the full API response, on successful requests. Set to false by
#     default.
#   - callback - {Object} Optional. A parse-style callback. Includes two functions
#     as keys: `success` and `error`.
# 
# @returns {Parse.Promise} a promise of the HTTP request
# 
CaptainUp::request = (options = {}) ->
	# Create a new Parse Promise
	promise = new Parse.Promise()
	# Add the `success` and `error` callbacks, if they exist
	promise.then(callback.success, callback.error) if options.callback
	# Send an HTTP request
	Parse.Cloud.httpRequest
		# Add the `url` option to the API base URL
		url: @api_base_url + options.url
		# Add the `params` to the body if it's a POST or PUT request
		body: options.params if options.method in ['POST', 'PUT']
		# Set the request method. By default it's set to 'GET'
		method: options.method || 'GET'
		# Set the correct HTTP headers for a JSON request
		headers:
			'Content-Type': 'application/json;charset=utf-8'
		# On success, resolve or reject the promise, based on the API response
		# code, and the configuration options.
		success: (response) ->
			# If the response status was not 200 or the API response code wasn't 200,
			# we reject the promise with the response body
			if response.status isnt 200 or response.data.code isnt 200
			then promise.reject(response.data)
			else
				# Otherwise, we resolve the promise. If the `only_data` option was set to
				# true, we only return the nested `data` section of the response.
				if options.only_data is true
				then promise.resolve(response.data.data)
				else promise.resolve(response.data)
		# On error, reject the promise with the data
		error: (response) ->
			promise.reject(response.data)
	# Return the promise
	return promise

