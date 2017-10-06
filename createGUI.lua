local gs=LibStub("GuiSkin-1.0");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
local L = LibStub("AceLocale-3.0"):GetLocale("DKP-Bidder")
local GRI=LibStub("GuildRosterInfo-1.0");--todo tutaj tez?
function B:CreateGUI()
    Bidder.mainFrame=CreateFrame("Frame","DkpBidderGUIframe",UIParent);
    table.insert(_G.UISpecialFrames, "DkpBidderGUIframe");
    local f=Bidder.mainFrame;
    f:SetWidth(265);
    f:SetHeight(395);
    f:Hide();
    f:EnableMouse(true);
    f:SetMovable(true);
    f:SetPoint('TOPRIGHT',UIParent,'TOPRIGHT',-100 ,0)
    f:SetScript("OnMouseDown",
    function(self)
        self:StartMoving();
    end)
    f:SetScript("OnMouseUp",
    function(self)
        self:StopMovingOrSizing();
    end)
    f:SetScript("OnShow",
    function(self)
        PlaySound(839);
        if GetNumGuildMembers()>0 then
            GRI:UpdateData()
            B.view.dkpAmountString:SetText("DKP: "..GRI:GetNet(UnitName("player")));
            
        end;
        GuildRoster();
    end)
    f:SetScript("OnHide",
    function(self)
        PlaySound("igCharacterInfoClose");
    end)
    
    
    f:SetFrameStrata("MEDIUM");
    f:SetToplevel(true);
    local v=self.view;
    local dividerWidth=(B.mainFrame:GetWidth()-8)*256/(256-52);
    
    --BORDER textures part
    v["logoTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_logoTexture","BACKGROUND",58,58,"TOPLEFT", B.mainFrame, "TOPLEFT", 0,-8,[[Interface\Addons\DKP-Bidder\Arts\Logo2.tga]]);
    v["topRightTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_topRightTexture","BORDER",128,256,"TOPRIGHT", B.mainFrame, "TOPRIGHT", 35,0,[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]);
    v["topLeftTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_topLeftTexture","BORDER",256,256,"TOPLEFT", B.mainFrame, "TOPLEFT", -8,0,[[Interface\TaxiFrame\UI-TaxiFrame-TopLeft]]);
    v["botLeftTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_botLeftTexture","BORDER",256,286,"BOTTOMLEFT", B.mainFrame, "BOTTOMLEFT", -8,-76,[[Interface\TaxiFrame\UI-TaxiFrame-BotLeft]]);
    v["botRightTexture"]=gs.CreateTexture(B.mainFrame,self.ver.."_botRightTexture","BORDER",128,286,"BOTTOMRIGHT", B.mainFrame, "BOTTOMRIGHT", 35,-76,[[Interface\TaxiFrame\UI-TaxiFrame-BotRight]]);
    
    
    --close button
    self.view["closeButton"]= CreateFrame("Button",self.ver.."closeButton", self.mainFrame, "UIPanelCloseButton");
    local cb=self.view["closeButton"];
    cb:SetPoint("TOPRIGHT",self.mainFrame,"TOPRIGHT",5,-8);
    cb:SetWidth(32);
    cb:SetHeight(32);
    --//
    
    
    --top gui part
    v.dkpAmountString=gs.CreateFontString(B.mainFrame,self.ver.."_dkpAmountString","ARTWORK","DKP:","TOPLEFT",B.mainFrame,"TOPLEFT",70,-45);
    local t=v.dkpAmountString
    t:SetFont([[Fonts\MORPHEUS.ttf]],18);
    --t:SetTextColor(1,1,1,1);
    --//
    
    --info part
    v.basicInfoTitleString=gs.CreateFontString(B.mainFrame,self.ver.."_basicInfoTitleString","ARTWORK","Info","TOP",B.mainFrame,"TOP",0,-80);
    v.minBidString=gs.CreateFontString(B.mainFrame,self.ver.."_minBidString","ARTWORK","Min bid: unknown","LEFT",B.mainFrame,"LEFT",20,0);
    v.minBidString:SetPoint("TOP",v.basicInfoTitleString,"BOTTOM",0,-4);
    v.bidMasterString=gs.CreateFontString(B.mainFrame,self.ver.."_BidMasterString","ARTWORK","Bid master: unknown","TOPLEFT",v.minBidString,"BOTTOMLEFT",0,-5);
    
    
    
    v.itemLinkString=gs.CreateFontString(f,nil,"ARTWORK","Item: ","TOPLEFT",v.bidMasterString,"BOTTOMLEFT",0,-5);
    
    v.itemLinkEditBox = CreateFrame("EditBox", nil, f, "InputBoxTemplate")
    
    v.itemLinkEditBox:SetPoint('LEFT', v.itemLinkString,'RIGHT',10 ,0)
    v.itemLinkEditBox:SetPoint('RIGHT', B.mainFrame,'RIGHT',-16 ,0)
    v.itemLinkEditBox:Show();
    v.itemLinkEditBox:Disable();
    v.itemLinkEditBox:SetAutoFocus(false);
    
    
    v.itemLinkEditBox:SetHeight(20);
    v.tooltipFrameHelp = CreateFrame("Frame",nil,f)
    v.itemLinkEditBox:SetScript("OnEnter", function(self)
        v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
            B:ShowGameTooltip();
        end)
    end)
    v.itemLinkEditBox:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        v.tooltipFrameHelp:SetScript("OnUpdate", 	function()
            -- Dont do anything
        end)
    end)
    
    
    
    
    v.listDivider=gs.CreateTexture(B.mainFrame,self.ver.."_dividerBorder","ARTWORK",dividerWidth,16,"LEFT", B.mainFrame, "LEFT", 6,0,[[Interface\MailFrame\MailPopup-Divider]]);
    v.listDivider:SetPoint("TOP",v.itemLinkEditBox,"BOTTOM",0,-2);
    --//
    
    --bidding list part
    v.listTitleString=gs.CreateFontString(B.mainFrame,self.ver.."_listTitleString","ARTWORK","Bidding list","TOP",v.listDivider,"BOTTOM",0,4);
    v.listTitleString:SetPoint("LEFT",(f:GetWidth()-v.listTitleString:GetWidth())/2+2,0);
    local data={columns={L["Nr"],L["Name"],L["Bid"],L["Total"]},columnsWidth={25,128,40,40},rows=5,height=70};
    self.countingFunction=function(a) return a.."." end;
    v.bidderList=LibStub("WowList-1.0"):CreateNew(self.ver.."_bidderList",data,B.mainFrame);
    v.bidderList:SetPoint('TOP', v.listTitleString,'BOTTOM', 0,-6);
    v.bidderList:SetPoint('LEFT', B.mainFrame,'LEFT', 16,0);
    v.bidderList:SetMultiSelection(false);
    --//
    
    
    --buttons part
    --button divider
    v.buttonDivider=gs.CreateTexture(B.mainFrame,nil,"ARTWORK",dividerWidth,16,"LEFT", v.listDivider, "LEFT", 0,0,[[Interface\MailFrame\MailPopup-Divider]]);
    v.buttonDivider:SetPoint("TOP",v.bidderList,"BOTTOM",0,0);
    --bidEditBox
    v.bidEditBox = CreateFrame("EditBox", self.ver.."Amount", B.mainFrame, "InputBoxTemplate")
    v.bidEditBox:SetMaxLetters(5)
    v.bidEditBox:SetNumeric()
    v.bidEditBox:SetNumber(0);
    v.bidEditBox:SetPoint('LEFT', B.mainFrame,'LEFT', 22,0)
    v.bidEditBox:SetPoint('TOP', v.buttonDivider,'BOTTOM', 0,-2)
    v.bidEditBox:SetAutoFocus(false);
    v.bidEditBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus();
    end)
    --//bidEditBox
    
    
    --Bid Button
    v.bidButton = CreateFrame("Button", self.ver.."ButtonBid", B.mainFrame, "UIPanelButtonTemplate")
    v.bidButton:SetText("Bid");
    v.bidButton:SetPoint('TOPLEFT', v.bidEditBox,'TOPRIGHT', 5,0)
    v.bidButton:SetScript("OnClick",function(self)
        B:Bid(v.bidEditBox:GetNumber());
    end)
    --//Bid Button
    
    
    ---EditBox for over bidding
    v.overBidEditBox = CreateFrame("EditBox", self.ver.."OverAmount", B.mainFrame, "InputBoxTemplate")
    v.overBidEditBox:SetMaxLetters(6)
    v.overBidEditBox:SetNumeric()
    v.overBidEditBox:SetPoint('TOPLEFT', v.bidEditBox,'BOTTOMLEFT',0 ,-5)
    v.overBidEditBox:SetNumber(10);
    v.overBidEditBox:Show();
    v.overBidEditBox:SetAutoFocus(false);
    v.overBidEditBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus();
    end)
    v.overBidEditBox:SetScript("OnTextChanged",function()
        v.overBidButton:SetText(L["OverBid by "]..v.overBidEditBox:GetNumber());
    end)
    --//EditBox
    
    --OverBid Button
    v.overBidButton = CreateFrame("Button", self.ver.."ButtonOverBid", B.mainFrame, "UIPanelButtonTemplate")
    
    v.overBidButton:SetText(L["OverBid by "]..v.overBidEditBox:GetNumber());
    v.overBidButton:SetPoint('TOPLEFT',v.overBidEditBox,'TOPRIGHT', 5,0)
    v.overBidButton:SetScript("OnClick",function()
        if B:GetBidderList():GetData(1)~=nil then
            B:Bid(v.overBidEditBox:GetNumber()+B:GetBidderList():GetData(1)[3].name);
        else
            B:Bid(B.minBid);
        end
    end)
    --//OverBid Button
    
    --Roster button
    v.openRosterButton= CreateFrame("Button", nil, B.mainFrame, "UIPanelButtonTemplate")
    v.openRosterButton:SetText(L["Open DKP roster"]);
    v.openRosterButton:SetPoint('TOPLEFT', v.overBidButton,'BOTTOMLEFT', 0,-5)
    v.openRosterButton:SetScript("OnClick",function(self)
        B.view.rosterFrame:Show();
    end)
    --//Roster Button
    
    
    
    
    self:CreateTitle()
    self:CreateTimerFrame();
    v.timerFrame:SetPoint("BOTTOMLEFT",B.mainFrame,"BOTTOMLEFT",14,20);
    v.timerFrame:SetWidth(B.mainFrame:GetWidth()-24);
    v.timerFrame:SetHeight(16);
    --self:CreateTimerFrame(30);
    v.rosterFrame=B:CreateRosterFrame();
    
    --disable buttons
    v.overBidButton:Disable();
    v.bidButton:Disable();
    self:CreateMinimapIcon();
    
end



--SET TITLE - window with linked item or other useless info.
function Bidder:CreateTitle()
    local v=B.view;
    v.titleFrame = CreateFrame("Frame",self.ver.."_TitleFrame",B.mainFrame)
    v.titleString=gs.CreateFontString(B.mainFrame,self.ver.."_Title","ARTWORK","DKP Bidder","TOP",v.titleFrame,"TOP",18,-14);
    local title=self.view["title"];
    v.titleFrame:SetHeight(20)
    v.titleFrame:SetWidth(v.titleString:GetWidth() + 20)
    v.titleString:SetPoint("TOP", B.mainFrame, "TOP", 18,-18);
    v.titleFrame:SetPoint("TOP", v.titleString, "TOP", 0, 0);
    v.titleFrame:SetMovable(true)
    v.titleFrame:EnableMouse(true)
    v.titleFrame:SetScript("OnMouseDown",function()
        B.mainFrame:StartMoving()
    end)
    v.titleFrame:SetScript("OnMouseUp",function()
        B.mainFrame:StopMovingOrSizing()
    end)
end
function B:ShowGameTooltip()
    local v=self.view;
    GameTooltip_SetDefaultAnchor( GameTooltip, UIParent )
    GameTooltip:ClearAllPoints();
    GameTooltip:SetPoint("bottom", v.itemLinkEditBox, "top", 0, 0)
    GameTooltip:ClearLines()
    
    if v.itemLinkEditBox:GetText()~="" then
        GameTooltip:SetHyperlink(v.itemLinkEditBox:GetText())
    end
    
end


B.timeLeft=0;

function B:CreateTimerFrame(timeleft)--TODO: move this to gui lib, and fix so it wouldnt call onupdate all the time :/ create->remove create->remove
    if timeleft==nil then timeleft=-1 end;
    local v=B.view;
    B.timerIsOn=true;
    if v.StringTimer~=nil then v.StringTimer:SetText("Time left for bidding: "..timeleft); end;
    B.timeLeft=timeleft;
    B.lastTimerValue=timeleft;
    if(v.timerFrame == nil) then
        v.timerFrame = CreateFrame("Frame",self.ver.."_timerFrameBackground", B.mainFrame);
        
        v.timerProgressFrame = CreateFrame("Frame",self.ver.."_timerFrame", v.timerFrame);
        
        
        v.timerProgressFrame:SetScript("onUpdate",function (self,elapse)
            if B.timeLeft>0 and B.timerIsOn then
                local a=B.timeLeft;
                v.timerProgressFrame:SetHeight(self:GetParent():GetHeight())
                v.timerProgressFrame:SetBackdropColor(0.5-B.timeLeft/B.lastTimerValue/2,B.timeLeft/B.lastTimerValue/2,0,1)
                v.timerProgressFrame:SetWidth((self:GetParent():GetWidth())*B.timeLeft/B.lastTimerValue)
                B.timeLeft=B.timeLeft-elapse;
                if ceil(B.timeLeft)<ceil(a) then
                    if ceil(a)~=0 then v.StringTimer:SetText(L["Time left: "]..ceil(B.timeLeft)); end;
                end;
            elseif B.timerIsOn then
                v.timerProgressFrame:SetWidth(-1);
                B.timerIsOn=false;
                
                v.StringTimer:SetText(L["Timer off."]);
                
            end;
        end);
        local backdrop = {
            bgFile =  gs.blank,  -- path to the background texture
            edgeFile = "",  -- path to the border texture
            tile = false,    -- true to repeat the background texture to fill the frame, false to scale it
            tileSize = 0,  -- size (width or height) of the square repeating background tiles (in pixels)
            edgeSize = 0,  -- thickness of edge segments and square size of edge corners (in pixels)
            insets = {    -- distance from the edges of the frame to those of the background texture (in pixels)
                left = 0,
                right =0,
                top = 0,
                bottom = 0
            }
        }
        v.timerProgressFrame:SetBackdrop(backdrop);
        
        
        v.timerProgressFrame:SetHeight(v.timerFrame:GetHeight()-2);
        v.timerProgressFrame:SetWidth(0);
        
        v.StringTimer  = v.timerProgressFrame:CreateFontString(self.ver.."StringTimer","OVERLAY","GameFontNormal")
        v.StringTimer:SetText("Timer off.");
        v.timerProgressFrame:Show();
        v.timerProgressFrame:SetPoint("TOPLEFT",v.timerFrame,"TOPLEFT",0,0);
        v.StringTimer:SetPoint("TOP",v.timerFrame,"TOP",0,-3);
        B.timerIsOn=false;
    end
    
    
    
    
    --for not reapeatable call on settext;
    
    
end

function B:ToggleBidder()
	if (not self.mainFrame:IsShown()) then
        
        self.mainFrame:Show();
    else self.mainFrame:Hide()
    end
end

function B:CreateRosterFrame()
    
    local f=gs:CreateFrame(self.ver.."_RosterFrame","DKP Roster","BASIC",400,415,'LEFT',UIParent,'LEFT',100 ,0);--400 375
    f:Hide();
    
    f.showAlts=true;
    f.showOffline=true;
    f.view={};
    f:SetScript("OnShow",
    function(self)
        PlaySound("igCharacterInfoOpen");
        self:UpdateList();
        GuildRoster();
    end)
    f:SetScript("OnHide",
    function(self)
        PlaySound("igCharacterInfoClose");
    end)
    local v=f.view;
    
    
    v.dropDownMenu= CreateFrame("Frame", B.ver.."DKPBidder_TitleDropDownMenu", f, "UIDropDownMenuTemplate")
    
    function f:RightMouseClick(arg,arg2)
        local cursorX, cursorY = GetCursorPosition()
        local scale=UIParent:GetEffectiveScale();
        EasyMenu(B.dropDownMenuTable, self.view.dropDownMenu,"UIParent", cursorX/scale, cursorY/scale, "MENU",0.5)
        
    end
    
    
    
    local data={columns={L["Name"],L["Current"],L["Overall"],L["Spent"],L["Rank"]},columnsWidth={90,60,60,60,90},rows=20,height=280};
    v.bidderList=LibStub("WowList-1.0"):CreateNew(self:GetName().."_bidderList",data,f);
    v.bidderList:SetPoint('TOPLEFT', f,'TOPLEFT', 16,-60);
    v.bidderList:SetColumnSortFunction(1,function(a,b) return a.data.name<b.data.name end)
    v.bidderList:SetColumnSortFunction(2,function(a,b) return a>b end)
    v.bidderList:SetColumnSortFunction(3,function(a,b) return a>b end)
    v.bidderList:SetColumnSortFunction(4,function(a,b) return a>b end)
    v.bidderList:SetColumnSortFunction(5,function(a,b) return a.rankIndex>b.rankIndex end)
    v.bidderList.RegisterCallback(f, "RightMouseClick");
    
    
    
    
    
    v.filterFontString=gs.CreateFontString(f,nil,"ARTWORK","Filter: ","TOPLEFT",f,"TOPLEFT",16,-32);
    v.filterFontString:SetTextColor(1,1,1,1);
    ---FilterEditBox
    v.filterEditBox = CreateFrame("EditBox",nil, f, "InputBoxTemplate")
    v.filterEditBox:SetMaxLetters(20)
    v.filterEditBox:SetPoint('TOPLEFT', v.filterFontString,'TOPRIGHT',5 ,4)
    v.filterEditBox:Show();
    v.filterEditBox:SetAutoFocus(false);
    v.filterEditBox:SetHeight(20);
    v.filterEditBox:SetWidth(100);
    v.filterEditBox:SetScript("OnEscapePressed",function(self)
        self:ClearFocus();
    end)
    v.filterEditBox:SetScript("OnTextChanged",function(self)
        
        local txt=string.lower(v.filterEditBox:GetText());
        txt = string.gsub(txt, "(%W)", "%%%1")
        self:GetParent().view.bidderList:AddFilter("filterByEditBox",function(data)
            
            return  string.find(string.lower(data[1].data.main), txt) or
            string.find(string.lower(data[1].data.name), txt) or
            string.find(data[2], txt) or
            string.find(data[3], txt) or
            string.find(data[4], txt) or
            string.find(string.lower(data[5].name), txt);
        end);
        self:GetParent().view.bidderList:UpdateView();
    end)
    --//FilterEditBox
    
    
    
    
    
    
    
    
    v.altsCheckBox=gs.CreateCheckBox(f,"Show alts");
    v.altsCheckBox:Show();
    v.altsCheckBox:SetPoint('TOPLEFT', v.bidderList,'BOTTOMLEFT', 0,-10);
    v.altsCheckBox:SetChecked(true);
    v.altsCheckBox:SetScript("OnClick",function(self, button, down)
        if self:GetChecked() then
            self:GetParent().view.bidderList:RemoveFilter("showAlts");
            self:GetParent().view.bidderList:UpdateView();
        else
            self:GetParent().view.bidderList:AddFilter("showAlts",function(data) return data[1].data.main==data[1].data.name end);
            self:GetParent().view.bidderList:UpdateView();
        end
    end)
    
    v.offlineCheckBox=gs.CreateCheckBox(f,"Show offline");
    v.offlineCheckBox:Show();
    v.offlineCheckBox:SetPoint('BOTTOMLEFT',v.altsCheckBox,'BOTTOMRIGHT', 100,0);
    v.offlineCheckBox:SetChecked(true);
    v.offlineCheckBox:SetScript("OnClick",function(self, button, down)
        if self:GetChecked() then
            self:GetParent().view.bidderList:RemoveFilter("showOffline");
            self:GetParent().view.bidderList:UpdateView();
        else
            self:GetParent().view.bidderList:AddFilter("showOffline",function(data) return data[1].data.online end);
            self:GetParent().view.bidderList:UpdateView();
        end
    end)
    
    
    
    v.showRaidMembersCheckBox=gs.CreateCheckBox(f,"Raid only");
    v.showRaidMembersCheckBox:Show();
    v.showRaidMembersCheckBox:SetPoint('BOTTOMLEFT',v.offlineCheckBox,'BOTTOMRIGHT', 100,0);
    v.showRaidMembersCheckBox:SetChecked(false);
    v.showRaidMembersCheckBox:SetScript("OnClick",function(self, button, down)
        if not self:GetChecked() then
            self:GetParent().view.bidderList:RemoveFilter("showRaidMembersOnly");
            self:GetParent().view.bidderList:UpdateView();
        else
            self:GetParent().view.bidderList:AddFilter("showRaidMembersOnly",function(data)
                for i=1,MAX_RAID_MEMBERS do
                    if GetRaidRosterInfo(i)==data[1].data.name then return true end;
                end;
                return false
            end);
            self:GetParent().view.bidderList:UpdateView();
        end
    end)
    
    function f:UpdateList()
        local players=GRI:GetData();
        local v=self.view;
        local data;
        
        for i,d in pairs(v.bidderList:GetKeySet()) do
            
            if players[i]==nil then
                
                v.bidderList:RemoveData(d,i);
                
            end;
        end;
        
        for i,d in pairs(players) do
            
            if v.bidderList:GetDataByKey(i)==nil then
                data={
                    {
                        func=function(a,b,data) if data.main==data.name then return data.main else return data.name.."("..data.main..")" end end,
                        data={main=d.main,name=i,online=d.online},
                        color=d.color;
                    },
                    d.net,d.tot,(d.tot-d.net),{name=d.rank,rankIndex=d.rankIndex},
                }
                v.bidderList:AddData(data,i);
                
            else
                
                data=v.bidderList:GetDataByKey(i);
                data[1]={
                    func=function(a,b,data) if data.main==data.name then return data.main else return data.name.."("..data.main..")" end end,
                    data={main=d.main,name=i,online=d.online},
                    color=d.color,
                };
                data[2]=d.net
                data[3]=d.tot
                data[4]=(d.tot-d.net)
                data[5]={name=d.rank,rankIndex=d.rankIndex}
                
            end;
            
        end;
        v.bidderList:UpdateView();
    end;
    return f;
end;



--  Minimap Button  --
function B:ShowMinimapButton()
    B.view.minimapIcon:Show()
    B.DB.showMinimapIcon = true
end
function B:HideMinimapButton()
    B.view.minimapIcon:Hide()
    B.DB.showMinimapIcon = false
end

function B:CheckMinimapStatus()
    if not B.DB.showMinimapIcon then
        B.view.minimapIcon:Hide()
        return false;
    end
    return true;
end

function B:CreateMinimapIcon()
    B.view.minimapIcon=CreateFrame("Button", "DKPBidderMapIcon", Minimap);
    local button=B.view.minimapIcon;
    button:SetHeight(32)
    button:SetWidth(32)
    button:SetFrameStrata("MEDIUM")
    button:SetPoint("CENTER", -65.35,-38.8);--DkpBidder["settings"].icon_xpos, DkpBidder["settings"].icon_ypos)
    button:SetMovable(true)
    button:SetUserPlaced(true)
    
    
    local texture=button:CreateTexture("DKPBidder_minimapnormaltexture");
    
    
    texture:SetWidth(32);
    texture:SetHeight(32);
    
    texture:SetTexture([[Interface\Addons\DKP-Bidder\Arts\button_up.tga]]);--[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]
    texture:SetAllPoints();
    texture:SetTexCoord(0, 0.53125, 0, 0.53125);
    texture:SetAlpha(1);
    texture:Show();
    
    
    
    button:SetNormalTexture(DKPBidder_minimapnormaltexture);
    texture=button:CreateTexture("DKPBidder_minimappushedtexture");
    
    
    texture:SetWidth(32);
    texture:SetHeight(32);
    
    texture:SetTexture([[Interface\Addons\DKP-Bidder\Arts\button_up.tga]]);--[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]
    texture:SetAllPoints();
    texture:SetTexCoord(0, 0.53125, 0, 0.53125);
    texture:SetAlpha(1);
    texture:Show();
    button:SetPushedTexture(DKPBidder_minimappushedtexture);
    button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
    
    button:SetScript("OnEnter", function(self)
        GameTooltip_SetDefaultAnchor(GameTooltip,  UIParent )
        GameTooltip:SetPoint("bottom", B.view.minimapIcon, "top", 0, 0)
        local cs = "|cffffffcc"
        local ce = "|r"
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["DKP-Bidder "] .. B.ver)
        GameTooltip:AddLine(string.format(L["%sLeft-Click%s to toggle the addon."], cs, ce))
        GameTooltip:AddLine(string.format(L["%sRight-Click%s to move this button"], cs, ce))
        GameTooltip:AddLine(string.format(L["%sShift+Click%s to hide this button"], cs, ce))
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)
    
    local dragMode = nil
    
    local function moveButton(self)
        local centerX, centerY = Minimap:GetCenter()
        local x, y = GetCursorPosition()
        x, y = x / self:GetEffectiveScale() - centerX, y / self:GetEffectiveScale() - centerY
        centerX, centerY = math.abs(x), math.abs(y)
        centerX, centerY = (centerX / math.sqrt(centerX^2 + centerY^2)) * 80, (centerY / sqrt(centerX^2 + centerY^2)) * 80
        local newXPos = x < 0 and -centerX or centerX;
        local newYPos = y < 0 and -centerY or centerY;
        self:ClearAllPoints()
        self:SetPoint("CENTER",newXPos, newYPos);
    end
    
    button:SetScript("OnMouseUp", function(self)
        self:SetScript("OnUpdate", nil)
    end)
    
    button:SetScript("OnMouseDown", function(self, button)
        if IsShiftKeyDown() then
            B:HideMinimapButton();
        elseif button == "RightButton" then
            dragMode = nil
            self:SetScript("OnUpdate", moveButton)
        elseif button == "LeftButton" then
            B:ToggleBidder()
        end
    end)
    self:CheckMinimapStatus();
    
end
