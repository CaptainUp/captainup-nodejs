// Require the Captain Up SDK
var captain = require('cloud/captainup.parse.js');

// Configure the Captain Up SDK
captain.up({
	// Your API Key
	api_key: 'YOUR API KEY',
	// Your API Secret
	api_secret: 'YOUR API SECRET'
});

// Initialize Express in Cloud Code.
var express = require('express');
var app = express();

// Specify the folder to find templates
app.set('views', 'cloud/views');
// Set the template engine to EJS
app.set('view engine', 'ejs');

// Cookie parsing middleware
app.use(express.cookieParser());
// Captain Up cookies middleware
app.use(captain.middlewares.cookies());
// Body parsing middleware
app.use(express.bodyParser());

// 
app.get('/get-status', function(req, res) {
	
	// captain.status({
	// 	success: function(data) {
	// 		res.json(data);
	// 	}
	// });
	
	captain.status().done(function(data) {
		res.json(data);
	});

});

// 
app.get('/get-app', function(req, res) {
	
	// captain.apps.get({
	// 	success: function(data) {
	// 		res.json(data);
	// 	}
	// });
	
	captain.apps.get().done(function(data) {
		res.json(data);
	});

});


app.get('/get-user', function(req, res) {
	
	// captain.users.get('22161230313409025506561', {
	// 	success: function(data) {
	// 		res.json(data);
	// 	}
	// });
	
	captain.users.get('22161230313409025506561').done(function(data) {
		res.json(data);
	});

});


app.get('/create-action', function(req, res) {
	
	// captain.actions.create({
	// 	user: '22161230313409025506561',
	// 	action: {
	// 		name: 'test',
	// 		entity: {
	// 			type: 'SDK',
	// 			name: 'NodeJS SDK',
	// 			version: '1.0.0',
	// 			url: 'http://nodejs.captainup.com/'
	// 		}
	// 	}
	// }, {
	// 	success: function(data) {
	// 		res.json(data);
	// 	}
	// });
	
	captain.actions.create({
		user: '22161230313409025506561',
		action: {
			name: 'test',
			entity: {
				type: 'SDK',
				name: 'NodeJS SDK',
				version: '1.0.0',
				url: 'http://nodejs.captainup.com/'
			}
		}
	}).done(function(data) {
		res.json(data);
	});

});


app.get('/current-player-create-action', function(req, res) {
	
	
	// captain.current_user.actions.create({
	// 	action: {
	// 		name: 'test',
	// 		entity: {
	// 			type: 'SDK',
	// 			name: 'NodeJS SDK',
	// 			version: '1.0.0',
	// 			url: 'http://nodejs.captainup.com/'
	// 		}
	// 	}
	// }, {
	// 	success: function(data) {
	// 		res.json(data);
	// 	}
	// });
	
	req.captain.current_user.actions.create({
		action: {
			name: 'test',
			entity: {
				type: 'SDK',
				name: 'NodeJS SDK',
				version: '1.0.0',
				url: 'http://nodejs.captainup.com/',
				awesome: 'very'
			}
		}
	}).done(function(data) {
		res.json(data);
	}).fail(function(data) {
		res.json(data);
	});

});


// Attach the Express app to Cloud Code.
app.listen();