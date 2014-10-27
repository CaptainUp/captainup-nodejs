{spawn} = require 'child_process'


# Bake builds the Captain Up SDK
task 'bake', 'Builds the Captain Up SDK', ->

  # Build the NodeJS version by:
  # - Running a bare compilation on the SDK files and the NodeJS wrapper
  # - concatenating them together and outputting to `index.js`
  run "coffee -bjcp lib/captain.coffee lib/wrappers/node.coffee lib/index.coffee > index.js"

  # Build the Parse version by:
  # - Running a bare compilation on the SDK files and the Parse wrapper
  # - concatenating them together and outputting them to `captain.parse.js`
  run "coffee -bjcp lib/captain.coffee lib/wrappers/parse.coffee lib/index.coffee > captainup.parse.js", ->
    # Copy the parse build into the sample playground app `cloud` directory
    run "cp captainup.parse.js samples/playground/cloud"


# Deploys the sample app to Parse
task 'deploy', 'Deploys the sample app to Parse', ->

  # Compile HAML files to HTML files
  run "cd samples/playground/public && haml index.haml index.html", ->
    # Deploy to parse
    run "cd samples/playground && parse deploy"


# `run` spawns a bash process, sends a command to it and hooks its stdout and sterr
# to the current process.
# 
# @param command - {String} the command to run
# @param callback - {Function} Will be called after the command finished, if it
# finished successfully
# 
# Example Usage:
# 
#   run "echo hi", -> run "echo bye"
#   > hi
#   > bye
# 
module.exports = run = (command, callback) ->
  # Run the command
  cmd = spawn '/bin/sh', ['-c', command]
  # Bind `stdout` and `stderr`
  cmd.stdout.on 'data', (data) -> process.stdout.write(data)
  cmd.stderr.on 'data', (data) -> process.stderr.write(data)
  # Kill the command on SIGHUP event
  process.on 'SIGHUP', -> cmd.kill()
  # After the command finished, and if it has done so successfully,
  # call the callback
  cmd.on 'exit', (code) -> callback() if callback? and code is 0

