import net
from os import commandLineParams, splitPath, getAppFilename
from strutils import parseUINT, removeSuffix
from strformat import `&`

## handle a client
proc handle(server: Socket) =
  defer:
    server.close()
  var
    input = ""
    output = ""

  while true:
    stdout.write "$ "
    input = readLine(stdin)
    send(server, input)
    if input == "": return
    if input == "exit": return
    if input == "STOP": return
    output = recv(server, 4096)
    removeSuffix(output, "\n")
    echo output

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
    client = newSocket(buffered = false)

  
  client.connect(ip, port)

  handle(client)
