{BufferedProcess} = require 'atom'
#TODO: REMOVE
module.exports =
class RunFunction
  strToCmd: (str) ->
    res = str.split " "
    return {} =
      command: res.shift(),
      args: res
  run: (cmdStr,cb) ->
    if cmdStr?
      cmd = @strToCmd cmdStr
      command = cmd.command
      args = cmd.args
      stdout = (output) ->
        #if output.indexOf(str) > -1
      exit = (code) =>

      process = new BufferedProcess({command, args, stdout, exit})
    else
      return -1
