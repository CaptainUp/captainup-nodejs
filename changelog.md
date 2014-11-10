# 0.9.1

- Add an option to work with multiple instances of the Captain Up SDK. For example:

```coffee
captain = require 'captainup'

captain.client.up(api_key: 'api_key1', api_secret: 'api_secret1').apps.get()
captain.client.up(api_key: 'api_key2', api_secret: 'api_secret2').apps.get()
```

# 0.9.0

- First release