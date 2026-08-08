; =====================================================================
;  Nexpart / WORLDPAC automation - AutoHotkey v2
;  Free, local, no AI. Requires AutoHotkey v2 installed (autohotkey.com).
;
;  HOW TO USE:
;  1. Install AutoHotkey v2 (free) -> autohotkey.com/download
;  2. Right-click this file > "Run Script" (or double-click once AHK is installed)
;  3. Use the built-in "Window Spy" tool (comes with AHK) to find:
;       - exact Window Titles for WORLDPAC and your browser
;       - exact screen coordinates OR element text for each button
;     Window Spy is in the AHK Start Menu folder after install.
;  4. Replace every "TODO" below with the real values from Window Spy.
;  5. Test ONE section at a time (comment out the others with ";") before
;     chaining the whole flow - this saves a lot of debugging pain.
; =====================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
SetTitleMatchMode 2   ; lets WinTitle match partial window titles

; ---------------------------------------------------------------------
; SHARED SETTINGS
; ---------------------------------------------------------------------
DocsFolder := A_MyDocuments          ; Windows "Documents" folder, resolved automatically
WorldpacWinTitle := "TODO - part of WORLDPAC window title"
BrowserWinTitle  := "TODO - e.g. 'Nexpart' or 'Google Chrome'"
NexpartURL := "https://3506235.nexpart.com"

; ---------------------------------------------------------------------
; HOTKEYS - press these while the script is running
; ---------------------------------------------------------------------
; Ctrl+Alt+W  -> run the WORLDPAC invoice-to-PDF flow
^!w:: RunWorldpacPrint()

; Ctrl+Alt+N  -> run the Nexpart order loop
^!n:: RunNexpartOrders()

Return  ; end of auto-execute section

; =====================================================================
; PART 1: WORLDPAC - open, go to invoice, print to PDF
; =====================================================================
RunWorldpacPrint() {
    ; --- Launch WORLDPAC if it's not already running ---
    if !WinExist(WorldpacWinTitle) {
        Run "TODO - full path to WORLDPAC.exe shortcut"
        WinWait WorldpacWinTitle, , 30
    }
    WinActivate WorldpacWinTitle
    WinWaitActive WorldpacWinTitle, , 10
    Sleep 500

    ; --- Navigate to the invoice screen ---
    ; TODO: replace with real clicks/keystrokes for your WORLDPAC menu path
    ; Example pattern (uncomment and adjust once you know the real coordinates):
    ; Click 120, 90      ; e.g. "Invoices" menu
    ; Sleep 300
    ; Click 200, 250     ; e.g. specific invoice row
    ; Sleep 300

    ; --- Print the invoice ---
    Send "^p"            ; Ctrl+P opens Print dialog in most Windows apps
    Sleep 800
    SelectMicrosoftPrintToPDF()

    ; --- Save dialog: choose filename + Documents folder ---
    Sleep 800
    SaveAsPDF("Invoice_" . FormatTime(, "yyyyMMdd_HHmmss"))
}

; =====================================================================
; PART 2: Nexpart - login, browse orders, print each to PDF
; =====================================================================
RunNexpartOrders() {
    ; --- Open the site in your default browser ---
    Run NexpartURL
    Sleep 3000
    WinActivate BrowserWinTitle
    WinWaitActive BrowserWinTitle, , 10

    ; --- Click the Login button ---
    ; TODO: replace with real coordinates (use Window Spy) or use
    ; ClickByImage() below if you'd rather click based on a screenshot match.
    Click 0, 0   ; TODO: Login button position

    ; If your browser has the username/password SAVED, it will usually
    ; auto-fill once you click into the fields. If a Chrome/Edge
    ; "use saved password" prompt appears, just:
    Sleep 1000
    Send "{Enter}"   ; submits the login form once fields are filled

    Sleep 3000

    ; --- Navigate: My Account > Order Activity > My Sellers Orders ---
    ; TODO: three clicks, one per menu level
    Click 0, 0   ; My Account
    Sleep 500
    Click 0, 0   ; Order Activity
    Sleep 500
    Click 0, 0   ; My Sellers Orders
    Sleep 1000

    ; --- List of sellers to process (edit this list as needed) ---
    Sellers := ["Auto Parts Centres", "NAPA Canada"]

    for seller in Sellers {
        ; TODO: click on the seller name/tab - coordinates or ClickByImage
        ; ClickByText(seller)  ; see helper below if you set it up
        Sleep 800
        ProcessOrdersForSeller(seller)
    }
}

; ---------------------------------------------------------------------
; Loop through the visible order numbers for one seller
; ---------------------------------------------------------------------
ProcessOrdersForSeller(seller) {
    ; TODO: You'll need to tell this how many orders are in the list,
    ; or better, loop until a "next order" click fails / no more rows.
    ; Below is a placeholder loop for N orders using row Y-coordinates.

    OrderRowYStart := 300     ; TODO: Y coordinate of first order row
    RowHeight := 30           ; TODO: pixel gap between rows
    OrderCount := 10          ; TODO: how many orders visible per page

    Loop OrderCount {
        rowY := OrderRowYStart + (A_Index - 1) * RowHeight

        ; --- Copy the order # to clipboard first (as requested) ---
        Click 150, rowY        ; TODO: X = order# column
        Send "^c"
        Sleep 200
        orderNum := A_Clipboard
        if (orderNum = "")
            continue

        ; --- Open the order ---
        Click 150, rowY
        Sleep 1000

        ; --- Print ---
        Send "^p"
        Sleep 800
        SelectMicrosoftPrintToPDF()
        Sleep 800
        SaveAsPDF(seller . "_" . orderNum)

        ; --- Go back to the order list ---
        Send "!{Left}"   ; Alt+Left = browser Back
        Sleep 1000
    }
}

; =====================================================================
; HELPERS
; =====================================================================

; Selects "Microsoft Print to PDF" in whatever print dialog is open.
; Works for both the native Windows print dialog and Chrome's print
; dialog (which has its own "Destination" dropdown).
SelectMicrosoftPrintToPDF() {
    ; Chrome/Edge print preview: click the Destination dropdown, then
    ; type to filter, then Enter. Coordinates vary - use Window Spy.
    Click 0, 0   ; TODO: "Destination" / printer dropdown
    Sleep 300
    SendText "Microsoft Print to PDF"
    Sleep 300
    Send "{Enter}"
    Sleep 300
    Send "{Enter}"   ; confirms "Print" / "Save" button in the dialog
}

; Types a filename into the native Windows "Save Print Output As" dialog
; and saves it into the Documents folder.
SaveAsPDF(filename) {
    Sleep 800
    ; Native Save dialog is usually already focused on the filename field
    Send "^a"                     ; select existing text
    SendText DocsFolder . "\" . filename . ".pdf"
    Sleep 200
    Send "{Enter}"
    Sleep 1000
    ; If a "replace existing file?" prompt appears:
    if WinExist("Confirm Save As") {
        Send "{Enter}"
    }
}
