# Load the buffer class explicitly, so the code will run on Parse
Buffer = require('buffer').Buffer
# Load the cryptography utility library
crypto = require 'crypto'

# The Captain Up NodeJS SDK
# --------------------------------------------------------------------------------------
class CaptainUp

	# The version of this package. Note that we must manually update this when
	# releasing new versions, as we can't use `pkginfo` in the Parse build.
	version: '0.9.1'

	# Initializes the Captain Up SDK.
	# 
	# @param options - {Hash} options hash:
	#   - api_key - {String} Required. Your API key
	#   - api_secret - {String} Required. Your API secret
	#   - api_version - {String} Optional. The API version. Defaults to 'v1'
	#   - api_base - {String} the base API path. Will be set to `/mechanics/v1`
	#     by default.
	#   - api_host - {String} the AI host, by default: 'captainup.com'
	#   - api_protocol {String} the HTTP protocol to use. 'https' by default.
	# 
	# @return {CaptainUp} the Captain Up SDK client, for chaining
	# 
	up: (options = {}) =>
		# Throw an error if no API key was passed
		unless options.api_key?
			throw new Error("Captain Up must be initialized with an API key")
		# Throw an error if no API secret was passed
		unless options.api_secret?
			throw new Error("Captain Up must be initialized with an API secret")

		# Get the App Key from the options
		@api_key = options.api_key
		# Get the App Secret from the options
		@api_secret = options.api_secret
		# Get the API Version from the options. Set to 'v1' by default.
		@api_version = options.api_version || 'v1'
		# The base API path. Will be set to '/mechanics/v1' by default
		@api_base = options.api_base || "/mechanics/#{@api_version}"
		# The base API host. Will be set to 'captainup.com' by default
		@api_host = options.api_host || 'captainup.com'
		# The API protocol. Will be set to 'https' by default
		@api_protocol = options.api_protocol || 'https'
		# Create the full base URL
		@api_base_url = @api_protocol + "://" + @api_host + @api_base

		# Initialize the resource classes
		@apps = new CaptainUp.Apps(this)
		@users = new CaptainUp.Users(this)
		@actions = new CaptainUp.Actions(this)
		# Initialize the middlewares
		@middlewares = new CaptainUp.Middlewares(this)
		# Return `this` for chaining
		return this


	# Returns the Captain Up API status
	# 
	# See: https://captainup.com/mechanics/v1/status
	# 
	# @param callback - {Function|Object} the node/parse callback
	# @return {Promise|Parse.Promise} the request's promise
	# 
	status: (callback) =>
		@request url: '/status', callback: callback


# Returns a new instance of the Captain Up SDK. Useful when working with
# multiple apps and API keys.
# 
# Example usage:
#   captain = require 'captainup'
#   app1 = captain.client.up(api_key: 'api_key', api_secret: 'api_secret')
# 
# @return {CaptainUp} a new instance of the Captain Up SDK
# 
CaptainUp::__defineGetter__ 'client', ->
	new CaptainUp()


# Captain Up Middlewares
# ----------------------------------------------------------------------------------------
class CaptainUp.Middlewares

	# The middlewares constructor. Simply assigns the `client` option to `@client`.
	# 
	# @param client - {CaptainUp} the Captain Up SDK client
	# 
	constructor: (client) -> @client = client

	
	# The `cookies` middleware parses the HTTP request cookies, tries to retrieve the
	# Captain Up user ID from them, if they're present, verifies that the ID hasn't
	# been tampered with, and adds it to the `req.captain.current_user` variable,
	# before moving on to the next middleware.
	# 
	# If the _cptup_sess` cookie is not set, the middleware will be skipped. If set,
	# the `cookies` middleware will break the cookie to two parts (separated by a
	# dot) - the `user_id` and the `hashed_id`. It will then sign the user ID using
	# SHA-512 over the API secret in lowercase hexadecimal digits digest, convert it
	# to a base 64 string, and remove the padding. If the newly signed user id matches
	# the received `hashed_id` we now the cookie hasn't been tampered with on the
	# client-side. If they do not match, we simply set add a `null` CurrentUser to
	# the request. The client can separate between the two by calling:
	# 
	#   req.captain.current_user.exists()
	# 
	# Regardless to whether the cookie exist or not, the middleware will add the
	# Captain Up SDK to the request under `req.captain` and the current user under
	# `req.captain.current_user`.
	# 
	cookies: =>
		# Return the middleware. We do this to allow future configuration options to it
		return (req, res, next) =>
			# Add Captain Up to the request object
			req.captain = @client
			# Only try to grab the user ID if the cookie exists
			if req.cookies._cptup_sess
				# Get the cookie value, and split it in two to the user id and hashed id
				[user_id, hashed_id] = req.cookies._cptup_sess.split('.')
				# Verify that `user_id` was not tampered with on the client side, by
				# hashing it with SHA-512 over the API secret and matching it with the
				# `hashed_id`.
				hash = crypto
					# Use a SHA-512 Hash with the app secret as the secret key
					.createHmac('sha512', @client.api_secret)
					# Update it with the user ID
					.update(user_id)
					# Return it as lowercase hexadecimal digits
					.digest('hex')
				# Now create a new Buffer with the hash, convert it to base 64 and remove
				# the unnecessary equal signs byte padding.
				hash = new Buffer(hash).toString('base64').replace(/\=+$/, '')
				# Try to match the hash with the signed user id you received in the cookie.
				# If they match, no one tampered with the user id, and we add the current
				# Captain Up user to the request. If not, we add a `null` user to the request.
				if hash is hashed_id
				# Set the `captain.current_user` on the request to CurrentUser instance
				then req.captain.current_user = new CaptainUp.CurrentUser(@client, user_id)
				# Otherwise, set it to a `null`ed Current User
				else req.captain.current_user = new CaptainUp.CurrentUser(@client, null)
				# Move on to the next middleware
				next()
			else
				# Set the `current_captain_user` to null if the cookie does not exist
				req.captain.current_user = new CaptainUp.CurrentUser(@client, null)
				# And move on to the next middleware
				next()


# Apps Resource
# ----------------------------------------------------------------------------------------
# Methods for the Captain Up App resource
# 
# See: https://captainup.com/help/api/reference/apps
# 
class CaptainUp.Apps

	# The constructor simply sets the Captain Up SDK client properly
	constructor: (client) -> @client = client

	# Retrieves a Captain Up app, based on the specified API key. Will only
	# return the nested `data` section of the API response on success.
	# 
	# See: https://captainup.com/help/api/reference/apps
	# 
	# Example Usage:
	# 
	#   captain.apps.get().done(function(data) {
	#     res.json(data);
	#   });
	# 
	# @param callback - {Function|Object} the node/parse callback
	# @return {Promise|Parse.Promise} the request's promise
	# 
	get: (callback) =>
		@client.request
			url: "/app/#{@client.api_key}"
			only_data: true
			callback: callback


# Users Resource
# ----------------------------------------------------------------------------------------
# Methods for the Captain Up User resource
# 
# See: https://captainup.com/help/api/reference/users
# 
class CaptainUp.Users

	# The constructor simply sets the Captain Up SDK client properly
	constructor: (client) -> @client = client

	# Retrieves a Captain Up user, based on the specified user id, and your API
	# key. Will only return the nested `data` section of the API response on
	# success.
	# 
	# See: https://captainup.com/help/api/reference/users
	# 
	# Example Usage:
	# 
	#   captain.users.get('22161230313409025506561').done(function(data) {
	#     res.json(data);
	#   });
	# 
	# @param callback - {Function|Object} the node/parse callback
	# @return {Promise|Parse.Promise} the request's promise
	# 
	get: (id, callback) =>
		@client.request
			url: "/players/#{id}?app=#{@client.api_key}&secret=#{@client.api_secret}"
			only_data: true
			callback: callback


# Actions Resource
# ----------------------------------------------------------------------------------------
# Methods for the Captain Up Action resource
# 
# See: https://captainup.com/help/api/reference/actions
# 
class CaptainUp.Actions

	# The constructor simply sets the Captain Up SDK client properly
	constructor: (client) -> @client = client

	# Creates a new Captain Up action, based on the received `options` and your
	# API key.
	# 
	# See: https://captainup.com/help/api/reference/actions
	# 
	# Example Usage:
	# 
	#   captain.actions.create({
	#     user: '22161230313409025506561',
	#     action: {
	#         name: 'test',
	#         entity: {
	#             type: 'SDK',
	#             name: 'NodeJS SDK',
	#             version: '1.0.0',
	#             url: 'http://nodejs.captainup.com/'
	#         }
	#     }
	#   }).done(function(data) {
	#     res.json(data);
	#   });
	# 
	# @param  options - {Object} options hash:
	#   - user - {String} the Captain Up user ID
	#   - action - {Object} the action object
	# @return {Promise|Parse.Promise} the request's promise
	# 
	create: (options = {}, callback) =>
		@client.request
			url: "/actions"
			method: 'POST'
			params:
				app: @client.api_key
				secret: @client.api_secret
				user: options.user
				action: options.action
			callback: callback


# Current User Resource
# --------------------------------------------------------------------------------------
class CaptainUp.CurrentUser

	# The constructor simply sets the Captain Up SDK `client` properly, along
	# with the `@user_id` (which can be null)

	# The constructor sets the base options for the instance: the Captain Up
	# SDK `@client`, along with the current user's actual `@user_id` (which
	# can be null).
	# 
	# It then creates the nested `actions` resource, based on the current user
	# ID.
	constructor: (@client, @user_id = null) ->
		# Create a nested actions resource
		@actions =
			# Creates a new action for the current user. The `create` action simply
			# adds the current `@user_id` to the options, before passing them to
			# the regular create method on the Action resource.
			# 
			# @param options - {Object} options hash:
			#   - action - {Object} the action object
			# @return {Promise|Parse.Promise} the request's promise
			create: (options = {}, callback) =>
				# Update the `options` with the `@user_id`
				options.user = @user_id
				# Create a new action using the actions resource
				@client.actions.create(options, callback)

	# Returns whether the current user exists or not.
	# 
	# @return {Boolean} whether the current user exists or not
	# 
	exists: ->
		return !!(@user_id)

