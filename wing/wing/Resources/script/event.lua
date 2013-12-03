--=======================================================================
-- File Name    : event.lua
-- Creator      : yestein(yestein86@gmail.com)
-- Date         : 2013-11-28 20:57:43
-- Description  :
-- Modify       :
--=======================================================================

function Event:Preload()
	self.tbGlobalEvent = {}
end

function Event:ReigseterEvent(szEvent, fnCallBack, ...)
	if not self.tbGlobalEvent[szEvent] then
		self.tbGlobalEvent[szEvent] = {}
	end
	local tbCallBack = self.tbGlobalEvent[szEvent]
	tbCallBack[#tbCallBack + 1] = {fnCallBack, arg}
	local nRegisterId = #tbCallBack
	return nRegisterId
end

function Event:UnReigseterEvent(szEvent, nRegisterId)
	
end

function Event:FireEvent(szEvent, ...)
	self:CallBack(self.tbGlobalEvent[szEvent], arg);
end

Event.nRunTime = 0;
function Event:CallBack(tbEvent, tbArg)
--local nTime = KGRLInterface.GetTickCount();	
	if (not tbEvent) then
		return;
	end
	--为了防止循环中出现新注册导致出错，采用Copy方式
	for nRegisterId, tbCallFunc in pairs(Lib:CopyTB1(tbEvent)) do
		if (tbEvent[nRegisterId]) then	-- 检测是否未被删除
			local varCallBack	= tbCallFunc[1];
			local varParam	= tbCallFunc[2];
			local tbCallBack	= nil;
			if (varParam.n ~= 0) then		-- 如果传入了自定义的参数
				tbCallBack	= {varCallBack, unpack(varParam)};
				Lib:MergeTable(tbCallBack, tbArg);
			else
				tbCallBack	= {varCallBack, unpack(tbArg)};
			end
			if (bIsEvent) then
				Lib:CallBack(tbCallBack);
			else
				local ret = {Lib:CallBack(tbCallBack)};
--Event.nRunTime = Event.nRunTime + KGRLInterface.GetTickCount() - nTime;
				return unpack(ret);
			end
		end
	end

--Event.nRunTime = Event.nRunTime + KGRLInterface.GetTickCount() - nTime;
end