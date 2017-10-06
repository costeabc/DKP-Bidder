local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
local GRI=LibStub("GuildRosterInfo-1.0");
local L = LibStub("AceLocale-3.0"):GetLocale("DKP-Bidder")

function B:GROUP_ROSTER_UPDATE()
    if B.bidMaster then
        if not UnitInRaid("player") then
            
            self:StopBids();
            
        else
            local name;
            for i=1, MAX_RAID_MEMBERS do
                name=GetRaidRosterInfo(i);
                if name==B.bidMaster then
                    t=true;
                    break;
                end;
            end;
            if name~=B.bidMaster then
                self:StopBids();
            end
            
        end
    end
end
function B:GUILD_ROSTER_UPDATE(arg,arg2)
    
	--[[if (B.view.rosterFrame==nil) then
		GRI:UpdateData()
	else
		if ((B.view.rosterFrame:IsVisible()) or B.mainFrame:IsVisible()) and GetNumGuildMembers()>0 then
			GRI:UpdateData()
		end;
    end;]]
end;
function B:RosterDataUpdate() --THIS IS SO BUGGED
    if GetNumGuildMembers()>0 then
        B.view.rosterFrame:UpdateList();
        B.view.dkpAmountString:SetText(L["DKP: "]..GRI:GetNet(UnitName("player")));
    end
end


function B:ClearTransferQueue()
    if #B.transfer>0 then
        self:Print(L["Clearing transfer queue. No DKP manager was found. There must be at least one player with working manager module in order to perform transfer."]);
        wipe(self.transfer);
    end
end
function B:Transfer(amount,players)
    amount=math.floor(amount/#players);
    
    for i=1,#players do
        table.insert(B.transfer,{name=players[i],amount=amount});
        self:Print(L["Adding transfer into queue: "]..amount..L[" DKP to "]..B.colors.class[GRI:GetClass(players[i])][5]..players[i]);
    end
    self:Print(L["Looking for DKP manager."]);
    self:Send("LFDKPManager",nil,"GUILD");
    self:ScheduleTimer(self.ClearTransferQueue, 3,self);
end

function B:Send(msg,data,dist,target)
    local sendData={msg=msg,data=data};
    local msg=self:Serialize(sendData);
    SendAddonMessage(B.prefix,msg,dist,target);
end;

function B:Bid(amount)
    if amount>=self.minBid then
        self:Send("playerBid",amount, "WHISPER", self.bidMaster);
    else
        self:Print(L["You have to bid more then minimum bid: "]..self.minBid);
    end
end

function B:StopBids()
    B.bidMaster=nil;
    B.view.bidMasterString:SetText(L["Bid Master: none"]);
    B.view.overBidButton:Disable();
    B.view.bidButton:Disable();
end

local realmName="-"..GetRealmName();
function B:OnCommReceived(prefix, message, distribution, sender)
    sender=string.gsub(sender, realmName, "");
    suc,data=self:Deserialize(message);
    if suc then
        local msg=data.msg;
        local data=data.data
        if (prefix==B.prefix) then
            if (msg=="IAMDKPManager") then
                if #B.transfer>0 then
                    B:Print(L["DKP master found: "]..sender..". "..L["Sending transfer request."]);
                    for i=1,#B.transfer do
                        self:Send("transferDKP",{transferTo=B.transfer[1].name,amount=B.transfer[1].amount},"WHISPER",sender);
                        table.remove(B.transfer,1);
                    end
                end
            elseif (msg=="startTimer") then
                if (sender==B.bidMaster) then
                    B:CreateTimerFrame(tonumber(data));
                end
            elseif (msg=="broadcastBid") then
                if (sender==B.bidMaster) then
                    if self:GetBidderList():GetDataByKey(data.bidderName)~=nil then
                        self:GetBidderList():GetDataByKey(data.bidderName)[3].name=tonumber(data.amount);
                        self:GetBidderList():GetDataByKey(data.bidderName)[3].timeOfBid=data.timeOfBid
                    else
                        local listItem={
                            self.countingFunction,
                            {name=data.bidderName,color=B.colors.class[GRI:GetClass(data.bidderName)]},
                            {name=tonumber(data.amount),timeOfBid=data.timeOfBid},
                            {func=function(a,b,d) return d.net end, data=GRI:GetPlayerData(data.bidderName)},
                        }
                        
                        self:GetBidderList():AddData(listItem,data.bidderName);
                    end
                    self:GetBidderList():Sort(3,function(a1,b1) return a1.timeOfBid<b1.timeOfBid end);
                    self:GetBidderList():Sort(3,function(a1,b1) return a1.name>b1.name end);--this sorts by amount of dkp
                    self:GetBidderList():UpdateView();
                end
            elseif msg=="startBids" then
                B.view.bidMasterString:SetText(L["Bid Master: "]..sender);
                B.bidMaster=sender;
                self:GetBidderList():RemoveAll();
                B.view.minBidString:SetText(L["Min bid: "]..data.minBid);
                B.view.bidEditBox:SetNumber(tonumber(data.minBid));
                B.minBid=tonumber(data.minBid);
                B.view.itemLinkEditBox:SetText(data.item);----------------TODO tu jest linjka z editboxem nowym
                B.view.overBidButton:Enable();
                B.view.bidButton:Enable();
                PlaySound("RaidWarning", "Master");
                B.mainFrame:Show()
            elseif msg=="stopBids" then
                if sender==B.bidMaster then
                    self:StopBids()
                    
                end
            elseif msg=="askForVersion" then
                
                B:Send("returnVersion",self.ver,"WHISPER",sender);
            elseif msg=="error" then
                self:Print(B.colors["red"]..L["Error message"]..B.colors["close"]..": '"..data..B.colors["close"].."'");
            elseif msg=="info" then
                local a,b,amount=string.find(data,L["Your dkp have changed by .+\. Reason: .+\. Your new dkp amount is (.+)"]);
                if a~=nil then
                    GRI:SetNet(UnitName("player"),amount);
                    
                    B.view.rosterFrame:UpdateList();
                    B.view.dkpAmountString:SetText(L["DKP: "]..GRI:GetNet(UnitName("player")));
                end;
                self:Print(B.colors["blue"]..L["Info"]..B.colors["close"]..": "..data..B.colors["close"].."");
                
            end
        end
    end
end;
local function noWhisperSpam(self,event,msg)
    return string.find(msg,"<DKP.Manager>.+");
end
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER",noWhisperSpam)

