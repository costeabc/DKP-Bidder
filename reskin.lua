local gs=LibStub("GuiSkin-1.0");
local B=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder");
function B:AttachSkin()
    
    local v=B.view;
    v.basicInfoTitleString:SetTextColor(1,1,1,1);
    v.listTitleString:SetTextColor(1,1,1,1);
    
    v.titleString:SetFont([[Fonts\MORPHEUS.ttf]],14);
    v.titleString:SetTextColor(1,1,1,1);--shadow??
    
    gs:SetFrameLook(v.timerFrame);
    
    local widthfull=(DkpBidderGUIframe:GetWidth()-30);--DkpBidder_ButtonBid:GetFontString():GetWidth()*4+20
    local width=widthfull/2;
    v.bidEditBox:SetWidth(width-10)
    v.overBidEditBox:SetWidth(width-10)
    v.bidButton:SetWidth(width)
    v.overBidButton:SetWidth(width)
    v.openRosterButton:SetWidth(width);
    
    v.bidEditBox:SetHeight(20)
    v.overBidEditBox:SetHeight(20)
    v.bidButton:SetHeight(20)
    v.overBidButton:SetHeight(20)
    v.openRosterButton:SetHeight(20);
end








