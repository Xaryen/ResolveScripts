local mediaStorage = resolve:GetMediaStorage()
--local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local ui = fu.UIManager
local Disp = bmd.UIDispatcher(ui)
local width,height = 500,200
local run_import = false

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

    local folderLisdt = mediaStorage:GetSubFolderList(directoryPath)
    local fileList = mediaStorage:GetFileList(directoryPath)

    print(fileList)
    print(#fileList)


    if fileList and #fileList > 0 then
        print("Files found in directory:")
        for i, filePath in ipairs(fileList) do
            print(i .. ": " .. filePath)
        end
    else
        print("No files found in the directory.")
    end

    if fileList then
        local addedItems = mediaStorage:AddItemListToMediaPool(fileList)
        if addedItems then
            print("files have been added to the Media Pool.")
        else
            print("files not added")
        end
    else
        print("No files found in the directory.")
    end

end
