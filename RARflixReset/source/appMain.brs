Sub Main(params As Object)
    initTheme()

    screen = CreateObject("roGridScreen")
    screen.show()

    showDialog()

    Debug("exiting now")
End Sub


sub showDialog(testDone=false) 
    port = CreateObject("roMessagePort")
    dialog = CreateObject("roMessageDialog")
    dialog.SetMessagePort(port) 
    total = PrintRegistry()
    if total > 0 or testDone = true then 
        dialog.SetTitle("Reset ALL RARflix Preferences?")
        dialog.SetText("WARNING! This will reset ALL settings! You will need to configure everything all over again.")
        dialog.AddButton(1, "NO! Get me out of here")
        dialog.AddButton(2, "YES - I'm feeling lucky today")
    else 
        dialog.SetTitle("RARflix Preferences are empty.")
        dialog.SetText(chr(10)+chr(10))
        dialog.AddButton(0, "OK - I guess I'm done here!")
    end if
    dialog.EnableBackButton(false)
    dialog.Show()
    while True
        dlgMsg = wait(0, dialog.GetMessagePort())
        If type(dlgMsg) = "roMessageDialogEvent"
            if dlgMsg.isButtonPressed()
                if dlgMsg.GetIndex() = 2
                    EraseRegistry()
                    showDialog()
                    dialog.close()
                else 
                    exit while
                end if
            else if dlgMsg.isScreenClosed()
                exit while
            end if
        end if
    end while 
    if dialog <> invalid then dialog.Close()
end sub

Sub showScreen(contentID As String, options As String)
    screen = CreateObject("roParagraphScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)

    screen.addParagraph("contentID = " + contentID)
    screen.addParagraph("options = " + options)

    screen.Show()

    while true
        msg = wait(0, port)
        if msg <> invalid
            exit while
        end if
    end while
End Sub

function getLogDate(epoch=invalid) as string
    datetime = CreateObject( "roDateTime" )
     ' convert epoch if given - otherwise use the current time
    if epoch <> invalid then 
        datetime.FromSeconds(epoch)
    end if
    datetime.ToLocalTime()
    date = datetime.AsDateString("short-date")
    hours = datetime.GetHours()
	if hours < 10 then 
        hours = "0" + tostr(hours)
    else 
        hours = tostr(hours)
    end if
    minutes = datetime.GetMinutes()
    if minutes < 10 then 
        minutes = "0" + tostr(minutes)
    else 
        minutes = tostr(minutes)
    end if
    seconds = datetime.GetSeconds()
    if seconds < 10 then 
        seconds = "0" + tostr(seconds)
    else 
        seconds = tostr(seconds)
    end if
	return date + " " + hours + ":" + minutes + ":" + seconds
end function


function PrintRegistry()
    Debug("------- REGISTRY --------")
    reg = CreateObject("roRegistry")
    regList = reg.GetSectionList()
    count = 0
    for each e in regList
        count = count+1
        Debug("Section->" + tostr(e))
        sec = CreateObject("roRegistrySection", e)
        keyList = sec.GetKeyList()
        for each key in keyList
            count = count+1
            value = sec.Read(key)
            Debug("    " + tostr(key) + " : " + tostr(value))
        next
    next
    Debug("--- END OF REGISTRY -----")
    return count
end function

sub EraseRegistry() 
    Debug("--- BEGIN DELETING REGISTRY -----")
    reg = CreateObject("roRegistry")
    regList = reg.GetSectionList()
    for each e in regList
       're = CreateObject("roRegex", "^\d+$", "")       
       ' the regex above -- these were added by the Plex AppManager() used the value as key -- wrong order
       '       was: RegWrite("first_playback_timestamp", "misc", tostr(Now().AsSeconds()))
       ' should be: RegWrite("first_playback_timestamp", tostr(Now().AsSeconds()) , "misc")
       
       Debug("Removing section: " + tostr(e))
       reg.Delete(e)
    next
    Debug("--- END DELETING REGISTRY -----")

    PrintRegistry()
end sub


sub initTheme()
    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    background = "#000000"
    titleText = "#BFBFBF"
    normalText = "#999999"
    detailText = "#74777A"
    subtleText = "#525252"
    plexOrange = "#FFA500"



    'theme.ThemeType = "generic-dark"
    theme.BackgroundColor = background
    theme.DialogTitleText="#000000"
    theme.DialogBodyText="#333333"
    theme.ButtonNormalColor = "#555555"
    theme.GridScreenBackgroundColor = background
    theme.GridScreenRetrievingColor = subtleText
    theme.GridScreenListNameColor = titleText
    ' We don't  need the rest set -- but might be useful later
    '    theme.CounterSeparator = normalText
    '    theme.CounterTextRight = normalText
    '    ' Defaults for all GridScreenDescriptionXXX
    '
    '    theme.ListScreenHeaderText = titleText
    '    theme.ListItemText = normalText
    '    theme.ListItemHighlightText = titleText
    '    theme.ListScreenDescriptionText = normalText
    '
    '    theme.ParagraphHeaderText = titleText
    '    theme.ParagraphBodyText = normalText
    '
    '
    '
    '    theme.TextScreenBodyText = "#f0f0f0"
    '    theme.TextScreenBodyBackgroundColor = "#111111"
    '    theme.TextScreenScrollBarColor = "#a0a0a0"
    '    theme.TextScreenScrollThumbColor = "#f0f0f0"
    '
    '    theme.RegistrationCodeColor = plexOrange
    '    theme.RegistrationFocalColor = normalText
    '
    '    theme.SearchHeaderText = titleText
    '    theme.ButtonMenuHighlightText = plexOrange 'titleText
    '    theme.ButtonMenuNormalText = titleText
    '
    '    theme.PosterScreenLine1Text = titleText
    '    theme.PosterScreenLine2Text = normalText
    '
    '    theme.SpringboardTitleText = titleText
    '    theme.SpringboardArtistColor = titleText
    '    theme.SpringboardArtistLabelColor = detailText
    '    theme.SpringboardAlbumColor = titleText
    '    theme.SpringboardAlbumLabelColor = detailText
    '    theme.SpringboardRuntimeColor = normalText
    '    theme.SpringboardActorColor = titleText
    '    theme.SpringboardDirectorColor = titleText
    '    theme.SpringboardDirectorLabel = detailText
    '    theme.SpringboardGenreColor = normalText
    '    theme.SpringboardSynopsisColor = normalText
    '    theme.SpringboardAllow6Buttons = "true"
    '    ' Not sure these are actually used, but they should probably be normal
    '    theme.SpringboardSynopsisText = normalText
    '    theme.EpisodeSynopsisText = normalText

    app.SetTheme(theme)
end sub
