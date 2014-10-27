var Buffer, CaptainUp, crypto,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Buffer = require('buffer').Buffer;

crypto = require('crypto');

CaptainUp = (function() {
  function CaptainUp() {
    this.status = __bind(this.status, this);
    this.up = __bind(this.up, this);
  }

  CaptainUp.prototype.version = '0.9.0';

  CaptainUp.prototype.up = function(options) {
    if (options == null) {
      options = {};
    }
    if (options.api_key == null) {
      throw new Error("Captain Up must be initialized with an API key");
    }
    if (options.api_secret == null) {
      throw new Error("Captain Up must be initialized with an API secret");
    }
    this.api_key = options.api_key;
    this.api_secret = options.api_secret;
    this.api_version = options.api_version || 'v1';
    this.api_base = options.api_base || ("/mechanics/" + this.api_version);
    this.api_host = options.api_host || 'captainup.com';
    this.api_protocol = options.api_protocol || 'https';
    this.api_base_url = this.api_protocol + "://" + this.api_host + this.api_base;
    this.apps = new CaptainUp.Apps(this);
    this.users = new CaptainUp.Users(this);
    this.actions = new CaptainUp.Actions(this);
    this.middlewares = new CaptainUp.Middlewares(this);
    return this;
  };

  CaptainUp.prototype.status = function(callback) {
    return this.request({
      url: '/status',
      callback: callback
    });
  };

  return CaptainUp;

})();

CaptainUp.Middlewares = (function() {
  function Middlewares(client) {
    this.cookies = __bind(this.cookies, this);
    this.client = client;
  }

  Middlewares.prototype.cookies = function() {
    return (function(_this) {
      return function(req, res, next) {
        var hash, hashed_id, user_id, _ref;
        req.captain = _this.client;
        if (req.cookies._cptup_sess) {
          _ref = req.cookies._cptup_sess.split('.'), user_id = _ref[0], hashed_id = _ref[1];
          hash = crypto.createHmac('sha512', _this.client.api_secret).update(user_id).digest('hex');
          hash = new Buffer(hash).toString('base64').replace(/\=+$/, '');
          if (hash === hashed_id) {
            req.captain.current_user = new CaptainUp.CurrentUser(_this.client, user_id);
          } else {
            req.captain.current_user = new CaptainUp.CurrentUser(_this.client, null);
          }
          return next();
        } else {
          req.captain.current_user = new CaptainUp.CurrentUser(_this.client, null);
          return next();
        }
      };
    })(this);
  };

  return Middlewares;

})();

CaptainUp.Apps = (function() {
  function Apps(client) {
    this.get = __bind(this.get, this);
    this.client = client;
  }

  Apps.prototype.get = function(callback) {
    return this.client.request({
      url: "/app/" + this.client.api_key,
      only_data: true,
      callback: callback
    });
  };

  return Apps;

})();

CaptainUp.Users = (function() {
  function Users(client) {
    this.get = __bind(this.get, this);
    this.client = client;
  }

  Users.prototype.get = function(id, callback) {
    return this.client.request({
      url: "/players/" + id + "?app=" + this.client.api_key + "&secret=" + this.client.api_secret,
      only_data: true,
      callback: callback
    });
  };

  return Users;

})();

CaptainUp.Actions = (function() {
  function Actions(client) {
    this.create = __bind(this.create, this);
    this.client = client;
  }

  Actions.prototype.create = function(options, callback) {
    if (options == null) {
      options = {};
    }
    return this.client.request({
      url: "/actions",
      method: 'POST',
      params: {
        app: this.client.api_key,
        secret: this.client.api_secret,
        user: options.user,
        action: options.action
      },
      callback: callback
    });
  };

  return Actions;

})();

CaptainUp.CurrentUser = (function() {
  function CurrentUser(client, user_id) {
    this.client = client;
    this.user_id = user_id != null ? user_id : null;
    this.actions = {
      create: (function(_this) {
        return function(options, callback) {
          if (options == null) {
            options = {};
          }
          options.user = _this.user_id;
          return _this.client.actions.create(options, callback);
        };
      })(this)
    };
  }

  CurrentUser.prototype.exists = function() {
    return !!this.user_id;
  };

  return CurrentUser;

})();

CaptainUp.prototype.request = function(options) {
  var promise, _ref;
  if (options == null) {
    options = {};
  }
  promise = new Parse.Promise();
  if (options.callback) {
    promise.then(callback.success, callback.error);
  }
  Parse.Cloud.httpRequest({
    url: this.api_base_url + options.url,
    body: (_ref = options.method) === 'POST' || _ref === 'PUT' ? options.params : void 0,
    method: options.method || 'GET',
    headers: {
      'Content-Type': 'application/json;charset=utf-8'
    },
    success: function(response) {
      if (response.status !== 200 || response.data.code !== 200) {
        return promise.reject(response.data);
      } else {
        if (options.only_data === true) {
          return promise.resolve(response.data.data);
        } else {
          return promise.resolve(response.data);
        }
      }
    },
    error: function(response) {
      return promise.reject(response.data);
    }
  });
  return promise;
};

module.exports = new CaptainUp();
