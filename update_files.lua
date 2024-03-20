local mediaStorage = resolve:GetMediaStorage()
local ui = fu.UIManager
local Disp = bmd.UIDispatcher(ui)
local width,height = 500,50
local run_import = false

function Import_files(path)
    if path and #path > 0 then
        for i, filePath in ipairs(path) do
            print(i .. ": " .. filePath)
        end
        local addedItems = mediaStorage:AddItemListToMediaPool(path)
        if addedItems then
            print("files have been added to the Media Pool.")
        else
            print("files not added")
        end
    else
        print("No files found in the directory.")
    end

end


local is_windows = package.config:sub(1,1) ~= "/"
local placeholder_text = "/Users/yourname/Resolve Projects/"
if is_windows == true then
    placeholder_text = "D:\\00_Renders\\..."
end

Win = Disp:AddWindow({
    ID = "MyWin",
    WindowTitle = "Import files from:",
    Geometry = { 100, 100, width, height },
    Spacing = 10,
    ui:VGroup{
        ID = "root",
        ui:HGroup{
            ID = "dst",
            ui:Label{ID = "DstLabel", Text = "Location to write files to:"},
            ui:TextEdit{ID = "DstPath", Text = "", PlaceholderText = placeholder_text,}
        },
        ui:HGroup{
            ID = "buttons",
            ui:Button{ID = "cancelButton", Text = "Cancel"},
            ui:Button{ID = "goButton", Text = "Go"},
        },
    },
})

--Event handlers
function Win.On.MyWin.Close(ev)
    Disp:ExitLoop()
    run_import = false
end

function Win.On.cancelButton.Clicked(ev)
    print("Cancel Clicked")
    Disp:ExitLoop()
    run_import = false
end

function Win.On.goButton.Clicked(ev)
    print("Go Clicked")
    Disp:ExitLoop()
    run_import = true
end

Itm = Win:GetItems()

Win:Show()
Disp:RunLoop()
Win:Hide()

if run_import then

    local directoryPath = Itm.DstPath.PlainText

    print(directoryPath)

    assert (Itm.DstPath.PlainText ~= nil and Itm.DstPath.PlainText ~= "", "Found empty destination path! Refusing to run")

    local folderList = mediaStorage:GetSubFolderList(directoryPath)


    for i, folders in ipairs(folderList) do
        print(i .. ": " .. folders)
        local fileList = mediaStorage:GetFileList(folders)
        Import_files(fileList)
    end

end
