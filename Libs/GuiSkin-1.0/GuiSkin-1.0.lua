local MAJOR,MINOR = "GuiSkin-1.0", 1
local GuiSkin, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
local GS =GuiSkin;



if not GuiSkin then return end -- No upgrade needed



local function printTable(t,s)
    if s==nil then s=""; end;
    for i,v in pairs(t) do
        print (s..i.."=",v);
        if type(v)=="table" then printTable(v,s.."   ") end
    end;
end

function GS:GetLayout()
    return GS.layouts[GS.layoutName];
end

function GS:SetLayout(name)
    if GS.layouts[name]~=nil then
        GS.layoutName=name;
    else
        self:Print("There is no such layout.");--todo maybe print available layouts
    end;
end;

function GS:SetFontLook(f)
    local l=self:GetLayout();
    local font=CreateFont(tostring(self).."guiskinfont");
    if f:IsObjectType("FontString") then
        font:SetFont(l.font,l.fontsize);
        font:SetTextColor(unpack(l.fontcolor))
        f:SetFontObject(font)
    elseif f:IsObjectType("Button") then
	local fontHighlight=CreateFont(tostring(self).."guiskinfonthighlight");
	local fontDisabled=CreateFont(tostring(self).."guiskinfontdiabled");
        font:SetFont(l.font,l.fontsize);
        fontDisabled:SetFont(l.font,l.fontsize);
        fontHighlight:SetFont(l.font,l.fontsize);
        font:SetTextColor(unpack(l.fontbuttonnormal));
        fontDisabled:SetTextColor(unpack(l.fontbuttondisabled));
        fontHighlight:SetTextColor(unpack(l.fontbuttonhighlight));
        f:SetNormalFontObject(font);
        f:SetDisabledFontObject(fontDisabled);
        f:SetHighlightFontObject(fontHighlight);
    end
end
function GS:SetButtonLook(f)
    local l=self:GetLayout();
    self:SetFontLook(f)
    if l.skinbuttons==true then
        self:SetFrameLook(f, true)
        f:SetNormalTexture("")
        f:SetHighlightTexture("")
        f:SetPushedTexture("")
        f:SetDisabledTexture("")
        f:SetScript("OnEnter",function()
            f:SetBackdropColor(unpack(l.buttonbackdropcolorin))
            f:SetBackdropBorderColor(unpack(l.buttonbordercolorin))
        end)
        f:SetScript("OnLeave",function()
            f:SetBackdropColor(unpack(l.buttonbackdropcolorout))
            f:SetBackdropBorderColor(unpack(l.buttonbordercolorout))
        end)
        
        f:SetBackdropColor(unpack(l.buttonbackdropcolorout))
        f:SetBackdropBorderColor(unpack(l.buttonbordercolorout))
    else
        self:SetFrameLook(f, true)
        f:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
        f:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
        f:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
        f:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
        f:SetScript("OnEnter",function()
        end)
        f:SetScript("OnLeave",function()
        end)
    end
end

-- set Frame look
function GS:SetFrameLook(f,backgroundPicture)
    local l=GS:GetLayout();
    
    if (f:IsObjectType("Button") or backgroundPicture==nil) then --goNormal is used mainly for buttons - cuz they are also frames, but we dont want them to be skinned as other frames :)
        f:SetBackdrop({
            bgFile = GS.blank,
            edgeFile = GS.blank,
            tile = false, tileSize = 0, edgeSize = 1,
            insets = { left = -1, right = -1, top = -1, bottom = -1}
        })
        f:SetBackdropColor(unpack(l.backdropcolor))
        f:SetBackdropBorderColor(unpack(l.bordercolor))
    else
        
        local bgpic=backgroundPicture;
        
        f:SetBackdrop( {
            bgFile =bgpic, -- DkpBidder["media"].blank,  -- path to the background texture
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",  -- path to the border texture
            
            tile = false,    -- true to repeat the background texture to fill the frame, false to scale it
            tileSize = 32,  -- size (width or height) of the square repeating background tiles (in pixels)
            edgeSize =12,  -- thickness of edge segments and square size of edge corners (in pixels)
            insets = { left = 3, right = 3, top = 3, bottom = 3}
        })
        if backgroundPicture==nil then f:SetBackdropColor(unpack(l.backdropcolor)) end;
        
        
    end
end

-- create Texture function
function GS:CreateTexture(name,level,width,height,point,relativeTo,point2,x,y,texturePath)
    local texture=self:CreateTexture(name,level);
    
    
    texture:SetWidth(width);
    texture:SetHeight(height);
    texture:SetTexCoord(0, 1, 0, 1);
    texture:SetPoint(point,relativeTo,point2,x,y);
    texture:SetTexture(texturePath);--[[Interface\TaxiFrame\UI-TaxiFrame-TopRight]]
    texture:SetAlpha(1);
    texture:Show();
    return texture;
end

function GS:CreateFontString(name,level,text,point,relativeTo,point2,x,y)
    
    local fs=self:CreateFontString(name,level,"GameFontNormal");
    if point then fs:SetPoint(point,relativeTo,point2,x,y); end
    fs:SetText(text);
    return fs;
end;
function GS:CreateCheckBox(text)
    local frame = CreateFrame("CheckButton", nil, self,"InterfaceOptionsCheckButtonTemplate");
    frame:SetWidth(24);
    frame:SetHeight(24);
    frame.text=GS.CreateFontString(self,nil,"ARTWORK",text,"LEFT",frame,"RIGHT",0,0);
    frame.text:SetTextColor(1,1,1,1);
    return frame;
end;

function GS:CreateFrame(name,title,frameType,width,height,point,relativeTo,point2,x,y)-- naming should be adjusted
    local f=CreateFrame("Frame",name,UIParent,"GameTooltipTemplate");
    table.insert(_G.UISpecialFrames, name);
    f:SetWidth(width);
    f:SetHeight(height);
    f:Show();
    f:EnableMouse(true);
    f:SetMovable(true);
    f:SetPoint(point,relativeTo,point2,x,y)
    f:SetScript("OnMouseDown",
    function(self)
        self:StartMoving();
    end)
    f:SetScript("OnMouseUp",
    function(self)
        self:StopMovingOrSizing();
    end)
    f:SetFrameStrata("MEDIUM");
    f:SetToplevel(true);
    if frameType=="BASIC" then
        f:SetBackdrop( {
            bgFile =[[Interface\DialogFrame\UI-DialogBox-Background]],
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false,
            tileSize = 32,
            edgeSize =32,
            insets = { left=11,right=11, top=12, bottom=10}
        })
    end;
    --close button
    f.view={};
    f.view["closeButton"]= CreateFrame("Button",name.."closeButton", f, "UIPanelCloseButton");
    local cb=f.view["closeButton"];
    cb:SetPoint("TOPRIGHT",f,"TOPRIGHT",-4,-4);
    cb:SetWidth(32);
    cb:SetHeight(32);
    --//
    
    --titleframe and text
    local v=f.view;
    v.titleFrame = CreateFrame("Frame",name.."_titleFrame",f)
    v.titleString=self.CreateFontString(v.titleFrame,name.."_title","ARTWORK",title,"TOP",v.titleFrame,"TOP",18,-14);
    v.titleString:SetFont([[Fonts\MORPHEUS.ttf]],14);
    v.titleString:SetTextColor(1,1,1,1);--shadow??
    
    v.titleFrame:SetHeight(40)
    v.titleFrame:SetWidth(width/3);--v.titleString:GetWidth() + 40);
    ----print("TUTAJ "..v.Title:GetWidth())
    
    v.titleString:SetPoint("TOP", f, "TOP", 0,2);
    v.titleFrame:SetPoint("TOP",v.titleString, "TOP", 0, 12);
    v.titleFrame:SetMovable(true)
    v.titleFrame:EnableMouse(true)
    v.titleFrame:SetScript("OnMouseDown",function()
        f:StartMoving()
    end)
    v.titleFrame:SetScript("OnMouseUp",function()
        f:StopMovingOrSizing()
    end)
    v.titleFrame.texture=self.CreateTexture(v.titleFrame,name.."_titleFrameTexture","ARTWORK",300,68,"TOP", v.titleFrame, "TOP", 0,2,[[Interface\DialogFrame\UI-DialogBox-Header]]);
    return f;
end;
