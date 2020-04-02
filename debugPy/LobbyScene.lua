--这里不是继承，而是函数覆盖

local TransmitLogin = require("Lobby32.src.Common.GameTeaBusiness.TransmitLogin")
TransmitLogin.lastLinkSrsInfo = TransmitLogin.lastLinkSrsInfo or {}
local CellLinkState = import("...Common.GameTea.CellLinkState",CURRENT_MOUDLE_NAME)
local CellLinkSRS = import("...Common.GameTeaBusiness.CellLinkSRS",CURRENT_MOUDLE_NAME)

local LINKSRS_MAX_USE_TIMES = 3

function TransmitLogin:start(nUserType, strName, strPassword,timeout,srsGroupID,updateResult)
    if TransmitLogin.super.start(self,timeout) == false then
        return
    end
    self._updateResult = updateResult
    self._srsGroupID = srsGroupID
    if self._srsGroupID == 0 or self._srsGroupID == nil then
        self._srsGroupID = KW_CONFIG_DEFAULT_SRS_GROUP_ID
    end
    self._nUserType = nUserType
    self._strName = strName
    self._strPassword = strPassword
    local CellRoomHeartBeat = import("...Common.GameTeaBusiness.CellRoomHeartBeat",CURRENT_MOUDLE_NAME)
    CellRoomHeartBeat.stop()
    
    local SRS = GT.SRSManager:getInstance():getSRSBySRSGroupID(self._srsGroupID)
    if SRS and SRS:getLinkState() == bf.SrsLinkState.LINK_STATE_SUCCESS then
        SRS:cancelLinkSRS()
        SRS:removeAllLinkStateScriptFunc()
        SRS:setLinkState(bf.SrsLinkState.LINK_STATE_CLOSE)
        GT.SRSManager:getInstance():removeSRS(SRS)
    end
    local linkSRS = self:getLinkSRS(self._srsGroupID)
    linkSRS:addCellCallBack(self, self.onLinkSRSCallBack)
    linkSRS:start(5 * 1000,self:getLeftTime(),self._srsGroupID, self._localSRSList)   
end

function TransmitLogin:getLinkSRS(srsGroupID)
    local linkSRS = CellLinkState.getCellSRSByGroupID(srsGroupID)

    local linkSRSInfo = self:getLinkSRSInfo(srsGroupID, linkSRS)
    if linkSRS == nil then
        linkSRS = CellLinkSRS:new()
        self:setLinkSRSInfo(srsGroupID, linkSRS)
    elseif linkSRS == linkSRSInfo.linkSRS then
		if linkSRSInfo.times == LINKSRS_MAX_USE_TIMES then
			CellLinkState.removeCellSRSByGroupID(srsGroupID)
	        linkSRS = CellLinkSRS:new()
	        self:setLinkSRSInfo(srsGroupID, linkSRS)
		else
			linkSRSInfo.times = linkSRSInfo.times + 1
		end
	end
	return linkSRS
end

function TransmitLogin:getLinkSRSInfo(srsGroupID,linkSRS)
    if not TransmitLogin.lastLinkSrsInfo[srsGroupID] then
        TransmitLogin.lastLinkSrsInfo[srsGroupID] = {linkSRS = linkSRS, times = 0}
    end
    return TransmitLogin.lastLinkSrsInfo[srsGroupID]
end

function TransmitLogin:setLinkSRSInfo(srsGroupID, linkSRS)
    TransmitLogin.lastLinkSrsInfo[srsGroupID] = {linkSRS = linkSRS, times = 1}
end

function TransmitLogin:onLinkSRSCallBack(cellLinkSRS, type, data)
    if type == GT.Cell.TYPE.SUCCESS then
        if self._updateResult then
            local CellLogin = import("Lobby32.src.LobbySceneBaoBao.GameTeaBusiness.CellLogin")
            local cellLogin = CellLogin:new()
            cellLogin:addCellCallBack(self, self.onCellLoginCallBack)
            cellLogin:start(self._nUserType,self._strName,self._strPassword,self:getLeftTime(),self._srsGroupID)
        else
            local CellReqHotUpdateVer = import("Lobby32.src.Common.GameTeaBusiness.CellReqHotUpdateVer")
            local cellReqHotUpdateVer = CellReqHotUpdateVer:new()
            cellReqHotUpdateVer:addCellCallBack(self, self.onCellReqHotUpdateVerCallBack)
            cellReqHotUpdateVer:start(self:getLeftTime())

        end
       

    elseif type == GT.Cell.TYPE.FAIL then
        self:setMessage("连接服务器失败,请稍后尝试!")
        self:fail(data)
    elseif type == GT.Cell.TYPE.TIMEOUT then
        self:setMessage("连接服务器超时,请稍后尝试!")
        self:timeout(data)
    end
end

return TransmitLogin