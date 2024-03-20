local mediaStorage = resolve:GetMediaStorage()
local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 500,200
local RunImport = false
local placeholder_text = "D:\\00_Renders\\..."
local rootFolder = mediaPool:GetRootFolder()
local topFolders = rootFolder:GetSubFolderList()

function PrintTable(tbl)
    for k, v in pairs(tbl) do
        print(k, v)
    end
end

print(rootFolder:GetName())

PrintTable(topFolders)

function FolderExists(folder, myFolders)

    --maybe this should be a while loop?
    for i, folderObjs in ipairs(myFolders) do

        local folderName = folderObjs:GetName()
        if folderName == folder then
            print(folderName)
            print("folder already exists in project")
            return true
        end
    end

    print("skill issue")
    return false

end

function ImportFiles(path)

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

Win = disp:AddWindow({
    ID = "MyWin",
    WindowTitle = "Import files from:",
    Geometry = { 100, 100, width, height },
    Spacing = 10,
    ui:VGroup{
        ID = "root",
        ui:HGroup{
            ID = "dst",
            ui:Label{ID = "DstLabel", Text = "Import from:"},
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
    disp:ExitLoop()
    RunImport = false
end

function Win.On.cancelButton.Clicked(ev)
    print("Cancel Clicked")
    disp:ExitLoop()
    RunImport = false
end

function Win.On.goButton.Clicked(ev)
    print("Go Clicked")
    disp:ExitLoop()
    RunImport = true
end

Itm = Win:GetItems()

Win:Show()
disp:RunLoop()
Win:Hide()

if RunImport then

    local directoryPath = Itm.DstPath.PlainText

    local folderList = mediaStorage:GetSubFolderList(directoryPath)

    for i, folder in ipairs(folderList) do

        local folderName = string.match(folder, "[^\\]+$")
        print(i .. ": " .. folderName)
        local checkFolder = FolderExists(folderName, topFolders)
        if not checkFolder then
            print("folder doesn't exist yet, creating...")
            mediaPool:AddSubFolder(rootFolder, folderName)
        end
        
        local fileList = mediaStorage:GetFileList(folder)
        ImportFiles(fileList)

    end

end
