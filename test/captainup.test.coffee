assert = require 'assert'
captain = require '../index'

describe 'Captain Up', ->
	
	it 'has a version number', ->
		# Expect the version number to be in the format of `x.x.x`
		expect(captain.version).to.match /\d+.\d+\.\d+/


	# Configuration specs
	# --------------------------------------------------------------------------------------
	describe 'Configuration', ->

		# Delete and reload Captain Up from the required modules cache, so every
		# configuration test will start from scratch
		beforeEach ->
			# Get the resolved filename of the captain up module
			filename = require.resolve('../index')
			# Delete it from the required modules cache
			delete require.cache[filename]
			# And re-require it
			captain = require '../index'

		it 'Throws an error if no API key was passed', ->
			expect(captain.up).to.throw Error, /API key/
			expect(captain.up.bind(this, api_secret: 'secret')).to.throw Error, /API key/

		it 'Throws an error if no API secret was passed', ->
			expect(captain.up.bind(this, api_key: 'api key')).to.throw Error, /API secret/

		it 'Can configure the API version', ->
			captain.up(api_key: 'api key', api_secret: 'secret', api_version: 'v100')
			expect(captain.api_version).to.equal 'v100'

		it 'Sets the API version to the most up-to-date version by default', ->
			captain.up(api_key: 'api key', api_secret: 'secret')
			expect(captain.api_version).to.equal 'v1'

		it 'Can configure the API base', ->
			captain.up(api_key: 'api key', api_secret: 'secret', api_base: '/search')
			expect(captain.api_base).to.equal '/search'

		it 'Sets the API base to the most up-to-date version by default', ->
			captain.up(api_key: 'api key', api_secret: 'secret')
			expect(captain.api_base).to.equal '/mechanics/v1'

		it 'Can configure the API host', ->
			captain.up(api_key: 'api key', api_secret: 'secret', api_host: 'google.com')
			expect(captain.api_host).to.equal 'google.com'

		it 'Sets the API host to captainup.com by default', ->
			captain.up(api_key: 'api key', api_secret: 'secret')
			expect(captain.api_host).to.equal 'captainup.com'

		it 'Can configure the API protocol', ->
			captain.up(api_key: 'api key', api_secret: 'secret', api_protocol: 'http')
			expect(captain.api_protocol).to.equal 'http'

		it 'Sets the API protocol to HTTPS by default', ->
			captain.up(api_key: 'api key', api_secret: 'secret')
			expect(captain.api_protocol).to.equal 'https'

		it 'Sets the base URL correctly by default', ->
			captain.up(api_key: 'api key', api_secret: 'secret')
			expect(captain.api_base_url).to.equal 'https://captainup.com/mechanics/v1'


	# API Resources specs
	# -------------------------------------------------------------------------------------
	describe 'API Resources', ->

		before ->
			captain.up
				api_key: process.env['CAPTAIN_UP_NODEJS_SDK_API_KEY']
				api_secret: process.env['CAPTAIN_UP_NODEJS_SDK_API_SECRET']
				api_protocol: process.env['CAPTAIN_UP_NODEJS_SDK_API_PROTOCOL']
				api_host: process.env['CAPTAIN_UP_NODEJS_SDK_API_HOST']

		# Status Resource
		# -----------------------------------------------------------------------------------
		describe 'Get Status', ->

			it 'Retrieves the API status', (done) ->

				captain.status (err, status) ->
					expect(err).to.be.null
					expect(status.code).to.equal 200
					expect(status.message).to.equal 'All is good'
					expect(status.data).to.exist
					done()


		# Apps Resource
		# -----------------------------------------------------------------------------------
		describe 'Apps', ->

			it 'Retrieves the current app', (done) ->

				captain.apps.get (err, app) ->
					expect(err).to.be.null
					expect(app.id).to.equal process.env['CAPTAIN_UP_NODEJS_SDK_API_KEY']
					expect(app.name).to.be.a 'string'
					expect(app.url).to.be.a 'string'
					expect(app.game_center_intro_title).to.be.a 'string'
					expect(app.game_center_intro_text).to.be.a 'string'
					expect(app.game_center_intro_text_html).to.be.a 'string'
					expect(app.sign_up_title).to.be.a 'string'
					expect(app.sign_up_text).to.be.a 'string'
					expect(app.sign_up_text_html).to.be.a 'string'
					expect(app.portal_custom_view).to.be.a 'string'
					expect(app.portal_custom_view_html).to.be.a 'string'
					expect(app.theme).to.be.a 'string'
					expect(app.primary_color).to.be.a 'string'
					expect(app.primary_color_light).to.be.a 'string'
					expect(app.primary_color_dark).to.be.a 'string'
					expect(app.secondary_color).to.be.a 'string'
					expect(app.secondary_color_dark).to.be.a 'string'
					expect(app.grey_color).to.be.a 'string'
					expect(app.black_color).to.be.a 'string'
					expect(app.white_color).to.be.a 'string'
					expect(app.hud_position).to.be.a 'string'
					expect(app.hud_position_left).to.be.a 'string'
					expect(app.hud_position_bottom).to.be.a 'string'
					expect(app.theme_css).to.be.a 'string'
					expect(app.hud_position_bottom).to.be.a 'string'
					expect(app.updated_at).to.be.a 'string'
					expect(app.created_at).to.be.a 'string'
					expect(app.levels).to.be.an 'array'
					expect(app.badges).to.be.an 'array'
					expect(app.action_settings).to.be.an 'array'
					expect(app.logo).to.be.a 'string'
					expect(app.first_mission).to.be.a 'string'
					done()


		# Users Resource
		# -----------------------------------------------------------------------------------
		describe 'Users', ->

			it 'Retrieves a user', (done) ->

				captain.users.get '22161230313409025506561', (err, user) ->
					expect(err).to.be.null
					expect(user.id).to.exist
					expect(user.name).to.be.a 'string'
					expect(user.image).to.be.a 'string'
					expect(user.user_state).to.exist
					expect(user.points).to.be.a 'number'
					expect(user.activities).to.be.an 'array'
					expect(user.badge_progress).to.be.an 'object'
					expect(user.total_actions).to.be.a 'number'
					expect(user.action_counter).to.be.an 'object'
					expect(user.level).to.be.an 'object'
					done()


		# Actions Resource
		# -----------------------------------------------------------------------------------
		describe 'Actions', ->

			it 'Creates an action', (done) ->

				captain.actions.create({
					user: '22161230313409025506561'
					action: {
						name: 'test',
						entity: {
							type: 'SDK',
							name: 'NodeJS SDK',
							version: '1.0.0',
							url: 'http://nodejs.captainup.com/'
						}
					}
				}).then (response) ->
					expect(response.code).to.equal 200
					expect(response.object).to.equal 'action'
					expect(response.levels).to.be.an 'array'
					expect(response.badges).to.be.an 'array'
					expect(response.points).to.be.a 'number'
					expect(response.base_points).to.be.a 'number'
					expect(response.points_multiplier).to.be.a 'number'
					expect(response.badge_progress).to.be.an 'object'
					expect(response.current_missions).to.be.an 'array'
					expect(response.data.name).to.equal 'test'
					expect(response.data.entity.type).to.equal 'SDK'
					expect(response.data.entity.name).to.equal 'NodeJS SDK'
					expect(response.data.entity.version).to.equal '1.0.0'
					expect(response.data.entity.url).to.equal 'http://nodejs.captainup.com/'
					expect(response.data.detail).to.be.an 'object'
					expect(response.data._id).to.exist
					expect(response.data.player_id).to.equal '22161230313409025506561'
					expect(response.data.timestamp).to.exist
					expect(response.data.points).to.equal response.points
					done()

