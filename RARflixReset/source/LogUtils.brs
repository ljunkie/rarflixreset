
Sub Debug(msg as String, server=invalid)
    if m.Logger = invalid then m.Logger = createLogger()
    logDate = getLogDate()
    m.Logger.Log(logDate + " : " + msg) ' log file for download
End Sub

Function createLogger() As Object
    logger = CreateObject("roAssociativeArray")
    logger.Enabled = 1
    logger.Log = loggerLog
    logger.EnablePapertrail = loggerEnablePapertrail
    logger.LogToPapertrail = loggerLogToPapertrail


    logger.EnablePapertrail()
    GetGlobalAA().AddReplace("logger", logger)

    return logger
End Function

Sub loggerEnablePapertrail()
    port = CreateObject("roMessagePort")
    addr = CreateObject("roSocketAddress")
    udp = CreateObject("roDatagramSocket")

    udp.setMessagePort(port)

    addr.setHostname("logs.papertrailapp.com")
    addr.setPort(26634)
    udp.setSendToAddress(addr)

    m.SyslogSocket = udp
    m.SyslogPackets = CreateObject("roList")

    aa = GetGlobalAA()
    tag = "RARflixReset"

    m.SyslogHeader = "<135> " + tag + ": "
End Sub

Sub loggerLogToPapertrail(msg)
    bytesLeft = 1024 - Len(m.SyslogHeader)
    if bytesLeft > Len(msg) then
        packet = m.SyslogHeader + msg
    else
        packet = m.SyslogHeader + Left(msg, bytesLeft)
    end if

    m.SyslogPackets.AddTail(packet)

    ' If we have anything backed up, try to send it now.
    while m.SyslogSocket.isWritable() AND m.SyslogPackets.Count() > 0
        m.SyslogSocket.sendStr(m.SyslogPackets.RemoveHead())
    end while
End Sub


Sub loggerLog(msg)
    print msg
    m.LogToPapertrail(msg)
End Sub