local libName="WowList-1.0";
local MAJOR,MINOR = libName, 1
local WowList, oldminor = LibStub:NewLibrary(MAJOR, MINOR);
local WL =WowList;
if not WL then return end
WL.embeds = WL.embeds or {}
local MergeSort={}

function MergeSort:Sort(A, compare)
    local p=1;
    local r=#A;
    if p < r then
        local q = math.floor((p + r)/2)
        self:MergeSort(A, p, q,compare)
        self:MergeSort(A, q+1, r,compare)
        self:Merge(A, p, q, r,compare)
    end
end
function MergeSort:MergeSort(A,p,r, compare)
    if p < r then
        local q = math.floor((p + r)/2)
        self:MergeSort(A, p, q,compare)
        self:MergeSort(A, q+1, r,compare)
        self:Merge(A, p, q, r,compare)
    end
end

-- merge an array split from p-q, q-r
function MergeSort:Merge(A, p, q, r,compare)
    local n1 = q-p+1
    local n2 = r-q
    local left = {}
    local right = {}
    
    for i=1, n1 do
        left[i] = A[p+i-1]
    end
    for i=1, n2 do
        right[i] = A[q+i]
    end
    
    left[n1+1] = math.huge
    right[n2+1] = math.huge
    
    local i=1
    local j=1
    local resp;
    for k=p, r do
        
        if right[j]==math.huge then
            resp=false;
        elseif left[i]==math.huge then
            resp=true;
        else
            resp=compare(right[j],left[i]);
        end;
        if resp then
            A[k] = right[j]
            j=j+1
        else
            A[k] = left[i]
            i=i+1
            
        end
    end
end
function WL:CreateNew(name,data,parentFrame)
    assert(name, libName..":CreateNew requires name to be set!");
    local n=name;
    local f = CreateFrame("Frame", name, parentFrame);
    
    
    f:SetScript("OnShow",
    function(self)
        self:UpdateView();
        
    end)
    f.name=n;
    self:Embed(f);
    
    f.rowSize=data.height/data.rows;
    f.height=f.rowSize*(data.rows+1);
    
    f:CreateModel(data);
    return f;
    
end;

function WL:CreateModel(data)
    local gs=LibStub("GuiSkin-1.0");
    data.columnsWidth[0]=0;
    local dist=0;
    self.view={};
    self.keyPointers={};
    self.rows=data.rows;
    self.columns=#data.columnsWidth;
    self.selected={};
    self.filters={};
    self.options={singleSelect=false};
    self.columnsWidth=data.columnsWidth;
    self.defultRowsColor={1,1,1,1};
    --self.dataIdCounter=0;
    self.callbacks = LibStub("CallbackHandler-1.0"):New(self)
    self:EnableMouse(true);
    self:EnableMouseWheel(true)
    self:SetScript("OnMouseWheel", function(self, delta)
        local slider=self.view.slider;
        local minValue, maxValue =slider:GetMinMaxValues()
        if slider:GetValue()-delta>=minValue and slider:GetValue()-delta<=maxValue then
            slider:SetValue(slider:GetValue()-delta);
        end
    end)
    --/script MV=LibStub("AceAddon-3.0"):GetAddon("DKP Bidder").view.rosterFrame.view.bidderList.view["row_y1_x1"]:SetAlphaGradient(1,20);
    --["row_y1_x1"]:SetAlphaGradient(1,20);
    local view=self.view;
    for i=1,#data.columns do
        dist=data.columnsWidth[i-1]+dist;
        view["columnTitle_"..tostring(i)]=gs.CreateFontString(self,nil,"ARTWORK",data.columns[i],"TOPLEFT",self,"TOPLEFT",dist,0);
        
        
        view["row_y1_x"..i]=gs.CreateFontString(self,self.name.."_row_y1_x"..i,"ARTWORK","txt"..i,"LEFT",view["columnTitle_"..tostring(i)],"LEFT",0,0);
        view["row_y1_x"..i]:SetTextColor(unpack(self.defultRowsColor));
        
        
    end;
    if data.rows>1 then
        for y=1,data.rows do
            for x=1,#data.columns do
                local fs;
                if y~=1 then
                    view["row_y"..y.."_x"..x]=gs.CreateFontString(self,self.name.."_row_y"..y.."_x"..x,"ARTWORK","txt"..y.."_"..x,"LEFT",view["row_y"..(y-1).."_x"..x],"LEFT",0,0);
                    view["row_y"..y.."_x"..x]:SetTextColor(unpack(self.defultRowsColor));
                    --view["row_y"..y.."_x"..x]:SetAlphaGradient(math.floor((self.columnsWidth[x])/10)-3,8);
                    --view["row_y"..y.."_x"..x]:SetAlphaGradient(10,2);--
                    
                end;
                
            end;
        end;
    end
    dist=dist+data.columnsWidth[#data.columns];
    self:SetWidth(dist+5);
    self.innerWidth=dist;
    
    local height=self.height;
    self:SetHeight(height);
    
    WL.CreateSlider(self,height);
    WL.CreateBidListButtons(self);
    self.data={};
    
    self:UpdateView()
end;
function WL:CreateSlider(height)
    view=self.view;
    view["slider"] = CreateFrame("Slider", self.name.."_slider", self, "OptionsSliderTemplate");
    local slider=view["slider"];
    slider:SetWidth(10)
    slider:SetHeight(height);
    slider:SetPoint('TOPRIGHT',self,"TOPRIGHT",0,0);
    slider:SetOrientation('VERTICAL')
    getglobal(slider:GetName().."Text"):SetText("");
    getglobal(slider:GetName().."Low"):SetText('');
    getglobal(slider:GetName().."High"):SetText('');
    slider:SetMinMaxValues(0,0)
    slider:SetValueStep(1)
    slider:SetValue(0)
    slider:SetScript("OnValueChanged",function()
        self:SliderValueChanged();
    end)
    
end;
--[[@Deperacated as functionality is not working properly, and this can be changed by wipe function.
function WL.ClearTable(tab)
	if type(tab)=="table" then
		for i,v in pairs(tab) do
			if type(v)=="table" then
				WL.ClearTable(v)
			else
				v=nil;
			end

		end;
	else
		tab=nil;
	end
end]]
function WL:SliderValueChanged()
    if (self.view["slider"]:GetValue()~=self.view["slider"].lastValue) then
        self.view["slider"].lastValue=self.view["slider"]:GetValue();
        self:UpdateView();
        --TODO:Fire slider value changed
    end;
    
end;
function WL:CreateBidListButtons()
    WL.unselectedBackdrop = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        tile = true,
        tileSize = 32,
        edgeSize = 20,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    }
    WL.unselectedDarkBackdrop = {
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
        tile = true,
        tileSize = 32,
        edgeSize = 20,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    }
    WL.selectedBackdrop = {
        bgFile = "Interface\\Buttons\\UI-Listbox-Highlight",
        tile = false,
        tileSize = 32,
        edgeSize = 20,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    }
    WL.titleBackdrop = {
        bgFile = "Interface\\Buttons\\UI-Listbox-Highlight",
        tile = false,
        tileSize = 32,
        edgeSize = 20,
        insets = {
            left = 0,
            right = 0,
            top = 0,
            bottom = 0
        }
    }
    
    
    for i=1,self.columns do
        
        view["columnButton"..i]=CreateFrame("Frame",self.name.."columnButton"..i, self);
        local button=view["columnButton"..i];
        
        view["columnTitle_"..i]:SetParent(button);
        
        button:SetWidth(self.columnsWidth[i]);
        button:SetHeight(self.rowSize);--TODO: Arrange this maching the text size;
        button:SetBackdrop(WL.unselectedBackdrop)
        button:SetPoint("TOPLEFT",view["columnTitle_"..i],"TOPLEFT",-3,0);
        button:EnableMouse(true);
        button.columnNr=i;
        button:SetScript("OnEnter",
        function(self)
            if self.sortFunction then
                self:SetBackdrop(WL.selectedBackdrop)
            end;
            
        end)
        button:SetScript("OnLeave",
        function(self)
            if self.sortFunction then
                self:SetBackdrop(WL.unselectedBackdrop)
            end;
            
        end)
        button:SetScript("OnMouseDown",
        function(self)
            
            if self.sortFunction then
                if self.sortReversedFunction==nil then
                    self.sortReversedFunction=function(a,b)
                        if self.sortFunction(a,b)==self.sortFunction(b,a) then
                            return false;
                        else
                            return not self.sortFunction(a,b);
                        end;
                    end
                    
                end
                if not self.sortOrder then
                    self:GetParent():Sort(self.columnNr, self.sortFunction)
                    self.sortOrder=true;
                    for i=1,self:GetParent().columns do
                        
                        if i~=self.columnNr then
                            self:GetParent().view["columnButton"..i].sortOrder=false;
                        end;
                    end;
                    self:GetParent():UpdateView()
                    
                else
                    self.sortOrder=false;
                    
                    self:GetParent():Sort(self.columnNr,self.sortReversedFunction);
                    self:GetParent():UpdateView()
                end;
            end;
            
        end)
    end
    local view=self.view;
    for i=1,self.rows do
        
        view["rowButton"..i]=CreateFrame("Frame",self.name.."rowButton"..i, self);
        local button=view["rowButton"..i];
        for x=1,self.columns do
            view["row_y"..i.."_x"..x]:SetParent(button);
            view["row_y"..i.."_x"..x]:SetPoint("TOP",button,"TOP",0,0);
        end;
        button:SetWidth(self.innerWidth);
        button:SetHeight(self.rowSize);--TODO: Arrange this maching the text size;
        button:SetBackdrop(WL.unselectedBackdrop)
        if i==1 then
            button:SetPoint("TOPLEFT",view["columnButton"..i],"BOTTOMLEFT",0,0);
        else
            button:SetPoint("TOPLEFT",view["rowButton"..(i-1)],"TOPLEFT",0,-self.rowSize);
        end
        button:EnableMouse(true);
        
        
        button.dataNr=i;
        button.idNr=i;
        
        button:SetScript("OnEnter",
        function(self)
            if not self:GetParent().data[self.dataNr].isSelected then
                self:SetBackdrop(WL.unselectedDarkBackdrop)
            end
        end)
        button:SetScript("OnLeave",
        function(self)
            if self:GetParent().data[self.dataNr] and not self:GetParent().data[self.dataNr].isSelected then
                self:SetBackdrop(WL.unselectedBackdrop)
            end
        end)
        button:SetScript("OnMouseDown",
        function(self,button)
            local shiftClick=not IsControlKeyDown() and IsShiftKeyDown();
            local ctrlClick=IsControlKeyDown() and not IsShiftKeyDown();
            local singleSelection=self:GetParent().options.singleSelect;
            local isSelected=self:GetParent().data[self.dataNr].isSelected;
            --add local parent!
            if button=="LeftButton" then
                
                if ctrlClick and not singleSelection then
                    if not isSelected then
                        self:SetBackdrop(WL.selectedBackdrop);
                        self:GetParent().data[self.dataNr].isSelected=true;
                        self:GetParent().lastSelected=self:GetParent().data[self.dataNr];
                        self:GetParent().lastSelectedId=self.dataNr;
                    else
                        self:SetBackdrop(WL.unselectedDarkBackdrop)
                        self:GetParent().data[self.dataNr].isSelected=nil;
                        self:GetParent().lastSelected=nil;
                    end;
                elseif shiftClick and not singleSelection then
                    if self:GetParent().lastSelected==nil then
                        self:GetParent().lastSelected=self:GetParent().data[self.dataNr];
                        self:GetParent().lastSelectedId=self.dataNr;
                    end;
                    if self:GetParent().lastSelected~=self:GetParent().data[self:GetParent().lastSelectedId] then
                        for i=1,#self:GetParent().data do
                            if self:GetParent().data[i]==self:GetParent().lastSelected then
                                self:GetParent().lastSelectedId=i;
                                break;
                            end;
                        end;
                    end;
                    if self:GetParent().lastSelected==self:GetParent().data[self:GetParent().lastSelectedId] then
                        local order=1;
                        if self:GetParent().lastSelectedId>self.dataNr then order=-1; end;
                        
                        for i=self:GetParent().lastSelectedId,self.dataNr,order do
                            if not self:GetParent():CheckFilters(self:GetParent().data[i]) then
                                self:GetParent().data[i].isSelected=true;
                            end;
                        end;
                    end;
                    local m=self:GetParent().rows;
                    if #self:GetParent().data<m then m=#self:GetParent().data end;
                    for h=1,m do
                        if self:GetParent().data[self:GetParent().view["rowButton"..h].dataNr].isSelected then
                            self:GetParent().view["rowButton"..h]:SetBackdrop(WL.selectedBackdrop)
                        end;
                    end;
                else
                    --self:GetParent:UnselectAll();
                    for i=1,#self:GetParent().data do
                        self:GetParent().data[i].isSelected=nil;
                    end;
                    for h=1,self:GetParent().rows do
                        if h~=self.idNr then
                            self:GetParent().view["rowButton"..h]:SetBackdrop(WL.unselectedBackdrop)
                        end;
                    end;
                    
                    if not isSelected then
                        self:SetBackdrop(WL.selectedBackdrop);
                        self:GetParent().data[self.dataNr].isSelected=true;
                        self:GetParent().lastSelected=self:GetParent().data[self.dataNr];
                        self:GetParent().lastSelectedId=self.dataNr;
                    else
                        self:SetBackdrop(WL.unselectedDarkBackdrop)
                        self:GetParent().data[self.dataNr].isSelected=nil;
                        self:GetParent().lastSelected=nil;
                    end;
                end;
            elseif button=="RightButton" then
                if not isSelected then
                    for i=1,#self:GetParent().data do
                        self:GetParent().data[i].isSelected=nil;
                    end;
                    for h=1,self:GetParent().rows do
                        if h~=self.idNr then
                            self:GetParent().view["rowButton"..h]:SetBackdrop(WL.unselectedBackdrop)
                        end;
                    end;
                    self:SetBackdrop(WL.selectedBackdrop);
                    self:GetParent().data[self.dataNr].isSelected=true;
                    self:GetParent().lastSelected=self:GetParent().data[self.dataNr];
                    self:GetParent().lastSelectedId=self.dataNr;
                end
                
            end
            if button=="LeftButton" then
                self:GetParent().callbacks:Fire("SelectionChanged");
                self:GetParent().callbacks:Fire("LeftMouseClick",self.dataNr);
            elseif button=="MiddleButton" then self:GetParent().callbacks:Fire("MiddleMouseClick",self.dataNr)
            elseif button=="RightButton" then self:GetParent().callbacks:Fire("RightMouseClick",self.dataNr)
            end
        end)
    end
end
function WL:GetDataByKey(i)
    return self.keyPointers[i];
end;
function WL:GetKeySet()
    return self.keyPointers;
end;
function WL:AddData(data,key)
    assert(#data==self.columns,"Added data must equal number of columns!");
    assert(data.isSelected==nil ,"Data cannot contain field 'isSelected' as it is a restricted field.");--TODO maybe change to check if field is exists and then if its boolean leave it be.as this might be usefull for copying betwwen lists.
    if key~=nil then self.keyPointers[key]=data; end;
    data.isSelected=nil;
    table.insert(self.data,data);
end;
function WL:RemoveData(data,key)
    assert(#data==self.columns,"Removed data must equal number of columns!");
    if key~=nil then
        self.keyPointers[key]=nil;
    end;
    
    for i,v in ipairs(self.data) do
        if v==data then
            wipe(data);
            table.remove(self.data,i);
            
            break;
        end;
    end;
end;
function WL:GetSelected()
    local retData={};
    for i=1,#self.data do
        if self.data[i].isSelected then
            table.insert(retData,self.data[i]);
        end;
    end;
    
    if #retData>0 then return retData else return nil; end;
end;
function WL:GetLastSelected()
    return self.lastSelected;
end;
function WL:SetData(data)
    self.data=data;
end;
function WL:GetData(nr)
    return self.data[nr];
end;
function WL:SetMultiSelection(val)
    self.options={singleSelect=not val};
end;
function WL:RemoveAll()
    --WL.ClearTable(self.data)
    wipe(self.data);
    wipe(self.keyPointers);
    self.lastSelected=nil;
    --self.data={};
    self:UpdateView();
end;

function WL:Sort(column,compareFunction)
    MergeSort:Sort(self.data, function(a,b) return compareFunction(a[column],b[column]) end)
end;
function WL:UpdateView()
    local line;
    local lineplusoffset;
    
    local slider=self.view["slider"];
    self.skip=0;
    self.skipBeforeSlider=0
    for i=1,#self.data do
        if self:CheckFilters(self.data[i]) then
            self.skip=self.skip+1;
        end
    end
    if (#self.data-self.skip>self.rows) then
        slider:SetMinMaxValues(0, #self.data-self.rows-self.skip)
        slider:Enable()
        slider:Show();
    else
        slider:SetMinMaxValues(0, 0)
        slider:Disable();
        slider:Hide();
        
    end
    for i=1,#self.data do
        if self:CheckFilters(self.data[i]) then
			 if i<=math.floor(slider:GetValue())+self.skipBeforeSlider then self.skipBeforeSlider=self.skipBeforeSlider+1; end;
        end
    end
    
    local view=self.view;
    
	lineplusoffset = math.floor(slider:GetValue())+self.skipBeforeSlider;
    for line=1,self.rows do
        
        lineplusoffset=lineplusoffset+1;
        if lineplusoffset <= #self.data then
            while self:CheckFilters(self.data[lineplusoffset]) do
                
                lineplusoffset=lineplusoffset+1;
                if lineplusoffset > #self.data then break end;
            end;
        end;
        
        if lineplusoffset <= #self.data then
            
            for x=1,self.columns do
                local name=tostring(self.data[lineplusoffset][x])
                
                if self.view["columnButton"..x].displayFunction then
                    local color;
                    name,color=self.view["columnButton"..x].displayFunction(name);
                    if not name then
                        name=tostring(self.data[lineplusoffset][x]);
                    end
                    if not color then
                        view["row_y"..line.."_x"..x]:SetTextColor(unpack(self.defultRowsColor));
                    else
                        view["row_y"..line.."_x"..x]:SetTextColor(unpack(color));
                    end
                elseif type(self.data[lineplusoffset][x])=="table" then
                    if self.data[lineplusoffset][x].name~=nil then
                        name=tostring(self.data[lineplusoffset][x].name)
                    elseif self.data[lineplusoffset][x].func~=nil then
                        name=self.data[lineplusoffset][x].func(lineplusoffset,line,self.data[lineplusoffset][x].data);
                    end;
                    if self.data[lineplusoffset][x].color~=nil then
                        view["row_y"..line.."_x"..x]:SetTextColor(unpack(self.data[lineplusoffset][x].color));
                    else
                        view["row_y"..line.."_x"..x]:SetTextColor(unpack(self.defultRowsColor));
                    end;
                elseif type(self.data[lineplusoffset][x])=="function" then
                    name=self.data[lineplusoffset][x](lineplusoffset,line);
                    view["row_y"..line.."_x"..x]:SetTextColor(unpack(self.defultRowsColor));
                end
                
                view["row_y"..line.."_x"..x]:SetText(name);
                
                if(name~="") then
                    ---print(view["row_y"..line.."_x"..x]);
                    --print(view["row_y"..line.."_x"..x]:GetWidth());
                    --print(view["row_y"..line.."_x"..x]:GetText());
                    local lLen=100;--TODO: check this fix with settting this val to 100 if the one below is nil. What is that val i dont know atm :D cuz i dont wanna get into the code
                    if view["row_y"..line.."_x"..x]:GetText() then
                        lLen=(view["row_y"..line.."_x"..x]:GetWidth()/#view["row_y"..line.."_x"..x]:GetText());
                        
                    end
                    view["row_y"..line.."_x"..x]:SetAlphaGradient(math.floor((self.columnsWidth[x]-30)/lLen),8);
                end
                
                
            end;
            view["rowButton"..line].dataNr=lineplusoffset;
            view["rowButton"..line]:Show();
            if self.data[lineplusoffset].isSelected then
                view["rowButton"..line]:SetBackdrop(WL.selectedBackdrop)
            else
                view["rowButton"..line]:SetBackdrop(WL.unselectedBackdrop)
            end;
        else
            view["rowButton"..line]:Hide();
        end
    end
end
function WL:CheckFilters(data)
    for name,v in pairs(self.filters) do
        
        if not v(data) then
            return true
        end
    end
    return false;
end;
function WL:AddFilter(name,filterFunc)
    
    self.filters[name]=filterFunc;
end
function WL:RemoveFilter(name)
    self.filters[name]=nil;
end;
function WL:RemoveAllFilters()
    for i,v in pairs(self.filters) do
        self.filters[i]=nil;
    end
end;
function WL:SetColumnSortFunction(columnNr,sortFunc)
    assert(type(sortFunc)=="function", libName..":SetColumnSortFunction requires function as a second parameter")
    self.view["columnButton"..columnNr].sortFunction=sortFunc;
end;
function WL:SetColumnDisplayFunction(columnNr,displayFunc)
    assert(type(displayFunc)=="function", libName..":SetColumnDisplayFunction requires function as a second parameter")
    self.view["columnButton"..columnNr].displayFunction=displayFunc;
end;

for target, v in pairs(WL.embeds) do
    WL:Embed(target)
end


local mixins = {
    "CheckFilters",
    "AddFilter",
    "RemoveFilter",
    "RemoveAllFilters",
    "SetColumnSortFunction",
    "SetColumnDisplayFunction",
    "Sort",
    "CreateModel",
    "SliderValueChanged",
    "ChangeButtonState",
    "UpdateView",
    "AddData",
    "GetKeySet",
    "SetData",
    "GetSelected",
    "GetLastSelected",
    "GetDataByKey",
    "SetMultiSelection",
    "GetData",
    "RemoveAll",
    "RemoveData",
}


function WL:Embed(target)
    for k, v in pairs(mixins) do
        target[v] = self[v]
    end
    self.embeds[target] = true
    return target
end
