--repeat the following series of keys to cheat skills.

local utils = require 'utils'

local validArgs = validArgs or utils.invert({
  'start',
  'stop',
  'cmd',
  'verbose',
  'noverbose',
})

local args = utils.processArgs({...}, validArgs)
local persistTable = require 'persist-table'
persistTable.GlobalTable.AmosRepeatCmdTable = persistTable.GlobalTable.AmosRepeatCmdTable or {}
cmdTable = persistTable.GlobalTable.AmosRepeatCmdTable
cmdTable.Run = cmdTable.Run or "no"
cmdTable.Verbose = cmdTable.Verbose or "no"
cmdTable.Cmds = cmdTable.Cmds or {}
cmds = cmdTable.Cmds

function RepeatCmdList(n)
  if cmdTable.Run == "no" then return end
  if not cmds[tostring(n)] then n=1 end
  if cmdTable.Verbose == "yes" then print("running this command: "..cmds[tostring(n)]) end
  if cmds[tostring(n)] then
    cmd = cmds[tostring(n)]
    dfhack.run_command( cmd ) end
  n=n+1
  dfhack.timeout(200,'frames',
                 function ()
                   dfhack.script_environment('amos-repeater').RepeatCmdList(n)
                 end
                )
end
if args.verbose then
  cmdTable.Verbose = "yes"
  print("AmosRepeater Verbose is on")
elseif args.noverbose then
  cmdTable.Verbose = "no"
  print("AmosRepeater Verbose is off")
end

if args.cmd then
  cmdTable.Cmds = nil
  cmdTable.Cmds = {}
  cmds = cmdTable.Cmds
  local index = 1
  if cmdTable.Verbose == "yes" then
    print("unpacking args.cmd:") 
    for k,v in pairs(args.cmd) do print(" "..k.." - "..v) end
  end
  local argCmd = ""
  for k,v in pairs(args.cmd) do
    if not ( v==";" ) then
      if not ( argCmd == "" ) then
        if cmdTable.Verbose == "yes" then print("adding to argCmd: "..v) end
        argCmd = argCmd.." "..v
      else
        if cmdTable.Verbose == "yes" then print("starting argCmd: "..v) end
        argCmd = v
      end
    else
      if cmdTable.Verbose == "yes" then print("inputting "..tostring(index).." - "..argCmd) end
      cmds[tostring(index)] = argCmd
      print(tostring(index).." - "..cmds[tostring(index)])
      index = index + 1 
      argCmd = ""
    end
  end
  if not ( argCmd == "" ) then
    if cmdTable.Verbose == "yes" then print("inputting "..tostring(index).." - "..argCmd) end
    cmds[tostring(index)] = argCmd
    print(tostring(index).." - "..cmds[tostring(index)])
    index = index + 1 
    argCmd = ""
  end    

  if cmdTable.Verbose == "yes" then
    print("printing cmdTable:")
    for key,_ in pairs(cmdTable.Cmds._children) do 
      print(" key:"..key.." cmd:"..cmdTable.Cmds[key])
    end
  end
end

if args.start then
  if cmds["1"] then
    cmdTable.Run = "yes"
    RepeatCmdList(1)
    print("AmosRepeater started")
  else
    print("You need to set the command list with -cmd [ first command ; second command ...]")
  end
elseif args.stop then
  cmdTable.Run = "no"
  print("AmosRepeater stopped")
end
