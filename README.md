![https://captainup.com/assets/help/nodejs/node-js-readme.png](Captain Up - Engagement Platform as a Service)

# Captain Up NodeJS SDK

![https://nodei.co/npm/captainup.png](https://nodei.co/npm/captainup.png?downloads=true)

`npm install captainup`

---

[Captain Up](https://captainup.com/) ∞ [Sign Up](https://captainup.com/users/sign_up) ∞ [Playground App](https://nodejs.captainup.com) ∞ [Documentation and Help](https://captainup.com/docs) ∞ [API Docs](https://captainup.com/help/api/reference/overview) ∞ [Features](https://captainup.com/features) ∞ [Client-side SDK](https://captainup.com/help/javascript/reference)

---

## Getting Started

If you haven't done so yet, [sign up to Captain Up](https://captainup.com/users/sign_up) (it's free!), check out [all the features](https://captainup.com/features), go over the [API docs](https://captainup.com/help/api/reference/overview) and [guides](https://captainup.com/docs) and [configure your app](https://captainup.com/help/getting-started/overview) to setup the right incentives for your community actions and behavior.

### Installation

- **NodeJS**: Install using `npm install captainup` or add `captainup` to your `package.json` dependencies.

- **Parse**: Download the `captainup.parse.js` file from above and copy it to your cloud code folder.

### Configuration

1. Require the Captain Up module:
    - **NodeJS**: `var captain = require('captainup');`
    - **Parse**: `var captain = require('cloud/captainup.parse.js');`

2. Initialize it with your API key and API secret:

```javascript
// Configure the Captain Up SDK
captain.up({
    // Your API Key
    api_key: 'your-api-key',
    // Your API Secret
    api_secret: 'your-api-secret'
});
```

(You can find your API key and secret key on the settings page in [your Captain Up dashboard](https://captainup.com/manage))


## Using the SDK

[Check out the playground app for live examples](https://nodejs.captainup.com)

**ProTip**: Looking for more sample code? The full source code for [the playground app](https://nodejs.captainup.com) can be found in the [samples directory of the SDK's GitHub repository](https://github.com/captainup/captainup-nodejs/blob/master/samples)

### Status

At any time, you can retrieve the Captain Up service status. The response will contain an HTTP status `code` and a human-readable message with information on the service status. You can manually check the service status on our [status page](http://status.captainup.com/).

```javascript
captain.status().done(function(data) {
    res.json(data);
});
```

### Apps

An app holds all the information and seetings about the way Captain Up works in your site or app, including information about the app's levels, badges, action settings, design, text, and other options. Check out the full [Apps API docs](https://captainup.com/help/api/reference/apps)

#### Retrieving an app

```javascript
captain.apps.get().done(function(data) {
    res.json(data);
});
```

### Users   

The user resource provides information about an app's users. Users share basic information and details such as the user name and the avatar image across all Captain Up apps, while the users' progress in each app is completely independent. Check out the full [Users API docs](https://captainup.com/help/api/reference/users) for more information.

#### Retrieving a user

```javascript
captain.users.get('22161230313409025506561').done(function(data) {
    res.json(data);
});
```

### Actions

Actions are the backbone of the Captain Up platform. Apps can gain deep insights on their users based on their actions; segment, engage, interact and incentivize their users based on user actions, and incentivize users with points, badges, levels, rewards and messages for doing these actions.

Captain Up supports completely dynamic actions, and every site and app can create and customize their own actions and how the experience evolves around them. [Learn more about actions](https://captainup.com/help/getting-started/custom-actions-tutorial).

#### Creating an action

```javascript
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
```


## Working with the current user

A Captain Up user ID is required in most requests that create or update users data and actions. In a lot of cases, you will want to use the current user's ID in these requests.

The Captain Up SDK provides a convenience ExpressJS middleware that automatically loads the user ID from your site's cookies, verifies it has not been tampered with, and adds it to `req.captain.current_user` to be used in your requests. More information on how this process works (with code examples) can be found at the [Actions API reference](https://captainup.com/help/api/reference/actions).

To enable this feature, you'll first need to configure the Captain Up client-side JavaScript SDK to update the user session:

```javascript
// Configuration options for the Captain Up JavaScript SDK:
captain.up({
    // Your API key
    api_key: 'your_api_key',
    // Enable server-side access to the user's session
    cookie: true
});
```

After enabling this option, Captain Up will store the current user ID, alongside a secure signed version of it inside a cookie called `_cptup_sess` under your domain.

To enable the Captain Up session middleware, add it right after the `express.cookieParser()` in your middlewares:

```javascript
// Cookie parsing middleware
app.use(express.cookieParser());
// Captain Up cookies middleware
app.use(captain.middlewares.cookies());
// Body parsing middleware
app.use(express.bodyParser());
```

That's it! You can now access `req.captain` and `req.captain.current_user` in all your request handlers. To check if there's currently a Captain Up user in the request, use `req.captain.current_user.exists()`. `req.captain` offers access to all the SDK functions, while `req.captain.current_user` allows you to send all the requests that involve the current user. Let's try it out. Run the code below, and after a few seconds you'll get several points and a new badge for being so awesome.

```javascript
// Create a new action for the current user
req.captain.current_user.actions.create({
    action: {
        // We'll do a 'test' action
        name: 'test',
        // You're testing the NodeJS SDK
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
})
```

## Callbacks and Promises

All the SDK methods that send requests to the Captain Up platform are asynchronous. The SDK supports both NodeJS-style callbacks, and promises.

### Callbacks

The last, optional, parameter each request method can receive is a callback function. The callback will be executed once data has returned from Captain Up, or when an error occurred.

- **NodeJS** - The callback should be in the usual signature of `function(error, response)`.
- **Parse** - In Parse, the callback is expected to be an object that contains two keys: `success` is the callback function to call after a successful request; `error` will be called if an error occurred.

```javascript
// NodeJS callbacks
captain.status(function(error, response) {
    // Will output: 'All is good'
    console.log(response.message);
});

// Parse callbacks
captain.status({
    success: function(response) {
        // Will output: 'All is good'
        console.log(response.message);
    },
    error: function(error) {
        // An error occurred...
    }
});
```

### Promises

All the Captain Up request methods also return [A+ compliant promises](https://github.com/promises-aplus/promises-spec). In NodeJS, we use [Bluebird promises](https://github.com/petkaantonov/bluebird), and on Parse we use [Parse.Promise](https://www.parse.com/docs/js/symbols/Parse.Promise.html). The promises will be resolved with the response, or be rejected with an error:

```javascript
    captain.status()
    .then(function(response) {
        // Will output: 'All is good'
        console.log(response.message);
    }, function(error) {
        // An error occurred...
    });
```


## Contributing

- Install NodeJS and CoffeeScript
- Clone the repository: `git clone git@github.com:CaptainUp/captain-nodejs.git`
- navigate to the repository `cd captain-nodejs`
- Install all dependencies: `npm install`
- Run the tests: `npm test`. Note that you'll need to have your API key and secret available as environment variables: `CAPTAIN_UP_NODEJS_SDK_API_KEY` and `CAPTAIN_UP_NODEJS_SDK_API_SECRET`
- Run the coverage report: `npm run coverage`
- Build and compile a new version: `cake bake`
- Deploy the sample app to Parse: `cake deploy`

## Changelog

See [changelog.md](https://github.com/captainup/captain-nodejs/blob/master/changelog.md)

## License

Copyright (c) 2014 Captain Up <team@captainup.com>

You are hereby granted a non-exclusive, worldwide, royalty-free license to use,
copy, modify, and distribute this software in source code or binary form for use
in connection with the web services and APIs provided by Captain Up.

As with any software that integrates with the Captain Up platform, your use of
this software is subject to the Captain Up Terms of Service at: https://captainup.com/legal/terms-of-service

This copyright notice shall be included in all copies, substantial portions or modified versions of the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

