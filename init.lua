Monitor = {left_count = 0,count = 0,limit = 30, date = nil}

function date()
	return os.date("%Y:%m:%d")
end

function Monitor:new (o,count)
	o = o or {}
	setmetatable(o,self)
	self.__index = self
	self.count = count or 0
	self.left_count = self.limit - self.count
	self.date = date()
	return o
end



function Monitor:incr()
	if(self.date ~= date()) then
		self.date = date()
		self.count = 0
		self.left_count = limit
	end

	self.count = self.count + 1
	self.left_count = self.limit - self.count
	self.left_count = self.left_count < 0 and 0 or self.left_count
	return self.left_count
end

monitor = Monitor:new(nil,0)


hs.hotkey.bind({"alt", "ctrl"}, "H", function()
  hs.notify.new({title="Hammerspoon", informativeText="Hello Hammerspoon!"}):send()
end)

workWifi = {['yuanw']='yw20162016',['DSJK_WIRELESS']='Jw4Fm9@Kv$',['ojbk']='zxcv()_+'}

function afterAwake()
  local currWifi = hs.wifi.currentNetwork()
  if hs.caffeinate.watcher.screensDidWake == 4 then
    hs.notify.new({title="Awake now", informativeText="prepare to reconnect wifi"}):send()
    hs.wifi.disassociate()

    for wifi,pw in pairs(workWifi) do
      rt = hs.wifi.associate(wifi,pw)
      if rt == true then
        hs.notify.new({title="火箭已发射", informativeText="连接到"..wifi}):send()
	break
      end
    end
    
    hs.notify.new({title="火箭发射失败", informativeText="请手动发射"}):send()
  end 
end


-- cafWatcher = hs.caffeinate.watcher.new(afterAwake)
-- cafWatcher:start()

function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder" or	 appName == "iTerm") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end

        if (appName == 'WeChat') then
        	monitor:incr()
        	hs.notify.new({title="微信今天用量",informativeText="已使用"..monitor.count.."次，还可以使用"..monitor.left_count.."次"}):send()
        	if(monitor.left_count <=0 )then
        		local hide = appObject:hide()
        		if(hide) then
		        	hs.notify.new({title="微信禁用",informativeText="已使用"..monitor.count.."次，超过可用次数"}):send()
        		end
        	end
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
