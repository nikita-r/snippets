
function Test-TcpPortDetailed {
    [CmdletBinding()] param (

    [Parameter(Mandatory)]
    [string]$ComputerName,

    [Parameter(Mandatory)]
    [ValidateRange(1,65535)]
    [int]$Port,

    [int]$msTimeout = 5000 )

    $SocketErrorDescriptions = @{
        0 = 'Success'
        10013 = 'Access denied. Permission issue or local policy prevented the socket operation.'
        10014 = 'Bad address. Invalid pointer/address supplied to the socket API.'
        10022 = 'Invalid argument. One or more socket arguments were invalid.'
        10024 = 'Too many open files/sockets. Process or system resource exhaustion.'
        10035 = 'Operation would block. Non-blocking socket cannot complete immediately.'
        10036 = 'Operation now in progress. A blocking operation is currently executing.'
        10037 = 'Operation already in progress. A second blocking call was attempted.'
        10038 = 'Socket operation on nonsocket. The handle is not a socket.'
        10039 = 'Destination address required. No remote endpoint was specified.'
        10040 = 'Message too long. Datagram exceeds buffer or protocol limit.'
        10041 = 'Protocol wrong type for socket.'
        10042 = 'Bad protocol option.'
        10043 = 'Protocol not supported.'
        10044 = 'Socket type not supported.'
        10045 = 'Operation not supported on this socket.'
        10046 = 'Protocol family not supported.'
        10047 = 'Address family not supported by protocol family.'
        10048 = 'Address already in use. Local address/port is already bound.'
        10049 = 'Cannot assign requested address. The local or remote address is not valid in this context.'
        10050 = 'Network is down.'
        10051 = 'Network is unreachable. No route to the target network.'
        10052 = 'Network dropped connection on reset.'
        10053 = 'Software caused connection abort. Local host aborted the connection.'
        10054 = 'Connection reset by peer. Remote host actively reset the connection.'
        10055 = 'No buffer space available. System lacked buffer resources.'
        10056 = 'Socket is already connected.'
        10057 = 'Socket is not connected.'
        10058 = 'Cannot send after socket shutdown.'
        10060 = 'Connection timed out. No response before timeout (often filtered/drop firewall or unreachable path).'
        10061 = 'Connection refused. Target host reachable, but nothing is listening on the port (or a reject/RST was returned).'
        10064 = 'Host is down.'
        10065 = 'No route to host / host unreachable.'
        10067 = 'Too many processes.'
        10091 = 'Network subsystem unavailable.'
        10092 = 'Winsock DLL version out of range.'
        10093 = 'Successful WSAStartup not yet performed.'
        10101 = 'Graceful shutdown in progress.'
        10109 = 'Class type not found.'
        11001 = 'Host not found. DNS name does not exist.'
        11002 = 'Nonauthoritative host not found / temporary DNS failure.'
        11003 = 'This is a nonrecoverable DNS error.'
        11004 = 'Valid name, but no data record of requested type.'
    }

    $client = $null

    $sw = [diagnostics.Stopwatch]::StartNew()
    try {
        $client = [net.Sockets.TcpClient]::new()
        $connectTask = $client.ConnectAsync($ComputerName, $Port)
        $completed = $connectTask.Wait($msTimeout)

        if (-not $completed) {
            $sw.Stop()

            [psCustomObject] @{
                ComputerName = $ComputerName
                Port         = $Port
                Connected    = $false
                msElapsed    = $sw.ElapsedMilliseconds
                ErrorCode    = 10060
                ErrorName    = 'TimedOut'
                Description  = $SocketErrorDescriptions[10060]
            }

            return
        }

        # Force any async exception to surface
        $connectTask.GetAwaiter().GetResult()

        $sw.Stop()

        [psCustomObject] @{
            ComputerName = $ComputerName
            Port         = $Port
            Connected    = $true
            msElapsed    = $sw.ElapsedMilliseconds
            ErrorCode    = 0
            ErrorName    = 'Success'
            Description  = $SocketErrorDescriptions[0]
        }
    } catch {
        $sw.Stop()

        $socketException = $null
        if ($_.Exception -is [net.Sockets.SocketException]) {
            $socketException = $_.Exception
        } elseif ($_.Exception.InnerException -is [net.Sockets.SocketException]) {
            $socketException = $_.Exception.InnerException
        }

        if ($socketException) {
            $numericError = [int] $socketException.SocketErrorCode
            $textError = [string] $socketException.SocketErrorCode

            [psCustomObject] @{
                ComputerName = $ComputerName
                Port         = $Port
                Connected    = $false
                msElapsed    = $sw.ElapsedMilliseconds
                ErrorCode    = $numericError
                ErrorName    = $textError
                Description  = if ($SocketErrorDescriptions.ContainsKey($numericError)) {
                                   $SocketErrorDescriptions[$numericError]
                               } else {
                                   $socketException.Message
                               }
            }
        } else {

            [psCustomObject] @{
                ComputerName = $ComputerName
                Port         = $Port
                Connected    = $false
                msElapsed    = $sw.ElapsedMilliseconds
                ErrorCode    = $null
                ErrorName    = $_.Exception.GetType().FullName
                Description  = $_.Exception.Message
            }
        }
    } finally {
        if ($client) { $client.Dispose() }
    }
}
