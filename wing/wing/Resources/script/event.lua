--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

function Event:Preload()
	self.tbGlobalEvent = {}

	Event:Test()
end

function Event:ReigseterEvent(szEvent, fnCallBack, ...)
	if not self.tbGlobalEvent[szEvent] then
		self.tbGlobalEvent[szEvent] = {}
	end
	local tbCallBack = self.tbGlobalEvent[szEvent]
	local nRegisterId = #tbCallBack + 1
	tbCallBack[nRegisterId] = {fnCallBack, {...}}
	return nRegisterId
end

function Event:UnReigseterEvent(szEvent, nRegisterId)
	if not self.tbGlobalEvent[szEvent] then
		return 0
	end
	local tbCallBack = self.tbGlobalEvent[szEvent]
	if not tbCallBack[nRegisterId] then
		return 0
	end
	tbCallBack[nRegisterId] = nil
	return 1
end

function Event:FireEvent(szEvent, ...)
	self:CallBack(self.tbGlobalEvent[szEvent], ...);
end


function Event:CallBack(tbEvent, ...)
	if not tbEvent then
		return
	end
	local tbCopyEvent = Lib:CopyTB1(tbEvent)
	for nRegisterId, tbCallFunc in pairs(tbCopyEvent) do
		if tbEvent[nRegisterId] then
			local fnCallBack = tbCallFunc[1]
			local tbPackArg = tbCallFunc[2]
			if #tbPackArg > 0 then
				Lib:MergeTable(tbPackArg, {...})
				pcall(fnCallBack, unpack(tbPackArg))
			else
				pcall(fnCallBack, ...)
			end
		end
	end
end