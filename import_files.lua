--todo: checkbox for files vs folders
--add a goto root folder to fix some potential issues?

local mediaStorage = resolve:GetMediaStorage()
local mediaPool = resolve:GetProjectManager():GetCurrentProject():GetMediaPool()
local ui = fu.UIManager
local disp = bmd.UIDispatcher(ui)
local width,height = 500,200
local RunImport = false
local placeholder_text = "D:\\00_Renders\\..."
local rootFolder = mediaPool:GetRootFolder()
local topFolders = rootFolder:GetSubFolderList()

-- function PrintTable(tbl)
--     for k, v in pairs(tbl) do
--         print(k, v)
--     end
-- end

--PrintTable(topFolders)

function RemoveItemFromArray(item, array)
    local index = nil
    for i, v in ipairs(array) do
        if v == item then
            index = i
            break
        end
    end
    if index then
        table.remove(array, index)
        return true
    end
end


function GetAllClipsInProject()
    local allClips = {}

    -- Recursive function to traverse folders
    local function traverseFolders(folder)
        -- Get and add all clips in the current folder
        local clips = folder:GetClipList()
        for _, clip in ipairs(clips) do
            table.insert(allClips, clip)
        end

        -- Recurse into subfolders
        local subFolders = folder:GetSubFolderList()
        for _, subFolder in ipairs(subFolders) do
            traverseFolders(subFolder)
        end
    end

    -- Start the recursive traversal from the root folder
    traverseFolders(rootFolder)

    return allClips
end

function FolderExists(folder, myFolders)

    --maybe this should be a while loop?
    for i, folderObjs in ipairs(myFolders) do

        local folderName = folderObjs:GetName()
        if folderName == folder then
            print(folderName)
            print("folder already exists in project")
            return folderObjs
        end
    end

    print("folder doesn't exist")
    return false

end

function CheckFiles(fileName, clipList)
    for _, clips in ipairs(clipList) do
        local clipName = clips:GetName()
        if fileName == clipName then
        return true
        end
    end
    return false
end

function ImportFiles(paths)

    --PrintTable(paths)

    if paths and #paths > 0 then
        for i, filePath in ipairs(paths) do
            print(i .. ": " .. filePath)
        end
        local addedItems = mediaStorage:AddItemListToMediaPool(paths)
        if addedItems then
            print("files have been added to the Media Pool.")
            return addedItems
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

    local currentClips = GetAllClipsInProject()
    local directoryPath = Itm.DstPath.PlainText

    local folderList = mediaStorage:GetSubFolderList(directoryPath)

    --iterate over folders in target directory
    for i, folder in ipairs(folderList) do

        local folderName = string.match(folder, "[^\\]+$")

        print(i .. ": " .. folderName)

        local myFolder
        local checkFolder = FolderExists(folderName, topFolders)
        --recreate them as project bins if they don't already exist
        if checkFolder then
            myFolder = checkFolder
        else
            print("folder doesn't exist yet, creating...")
           myFolder = mediaPool:AddSubFolder(rootFolder, folderName)
        end

        local fileList = mediaStorage:GetFileList(folder)

        for i = #fileList, 1, -1 do
            local files = fileList[i]
            local fileName = string.match(files, "[^\\]+$")
            --print("checking " .. fileName)
            local alreadyExists = CheckFiles(fileName, currentClips)
            if alreadyExists then
                --print("removed item: " .. fileName)
                RemoveItemFromArray(files, fileList)
            end
        end



        local importedClips = ImportFiles(fileList)
        print(myFolder:GetName())

        -- by default stuff gets imported into a random location based on what's selected
        --  so move the imported stuff into the appropriate folder
        if importedClips and #importedClips > 0 then

            for _, clips in ipairs(importedClips) do
                --print("moving: " .. clips:GetName())
            end
            mediaPool:MoveClips(importedClips, myFolder)
        end

        --there's a visual bug where if you move the clips into currently open folder they'll appear duplicate until refresh

    end

end


