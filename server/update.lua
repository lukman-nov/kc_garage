if Config.CheckForUpdates then
  local function CheckMenuVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/lukman-nov/kc_garage/main/version.txt', function(err, text, headers)
      local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')
      if not text then
        return
      end
      if text:gsub("%s+", "") ~= currentVersion:gsub("%s+", "") then
        print('--------------------------------------------------------------')
        print(('| [^3kc_garage^7] Update are available in the new version: %s |'):format(text:gsub("%s+", "")))
        print('--------------------------------------------------------------')
      end
    end)
  end
  CheckMenuVersion()
end
