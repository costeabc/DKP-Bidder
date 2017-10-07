LibStub("GuiSkin-1.0").layoutName="default";
LibStub("GuiSkin-1.0").layouts={
    ["default"]={
        ["bordercolor"] = { .6,.6,.6,0 },
        ["titlebackdropcolor"] = { .0,.0,.0,1 },
        ["backdropcolor"] = { .1,.1,.1,0.8 },
        ["buttonbackdropcolorout"] = { .05,.05,.05,1 },
        ["buttonbackdropcolorin"] = { .1,.05,.05,1 },
        ["buttonbordercolorin"] = { 0.7,.1,.1,1 },
        ["buttonbordercolorout"] = { .6,.6,.6,1 },
        ["font"]=[=[Interface\Addons\KSQ-dkpBidder\Font\arial.ttf]=],
        ["fontsize"]=13,
        ["fontcolor"]={1,.8,0,1},
        ["fontbuttonnormal"]={1,.8,0,1},
        ["fontbuttondisabled"]={0.5,0.5,0.5,1},
        ["fontbuttonhighlight"]={1,1,1,1},
        ["skinbuttons"]=false,
        ["mainframepicture"]="Interface\\AddOns\\KSQ-dkpBidder\\Images\\GoldBackground.tga",
        ["timeframesetbackground"]=false
    },
    ["tukui"]={
        ["bordercolor"] = { .6,.6,.6,1 },
        ["titlebackdropcolor"] = { .3,.3,.3, 1 },
        ["backdropcolor"] = { .1,.1,.1,1 },
        ["buttonbackdropcolorout"] = { .05,.05,.05,1 },
        ["buttonbackdropcolorin"] = { .1,.1,.2,1 },
        ["buttonbordercolorin"] = { .2,.4,1,1 },
        ["buttonbordercolorout"] = { .6,.6,.6,1 },
        ["font"]=[=[Interface\Addons\KSQ-dkpBidder\Font\arial.ttf]=],
        ["fontsize"]=12,
        ["fontcolor"]={1,1,1,1},
        ["fontbuttonnormal"]={1,1,1,1},
        ["fontbuttondisabled"]={0.5,0.5,0.5,1},
        ["fontbuttonhighlight"]= { .2,.4,1,1 },
        ["skinbuttons"]=true,
        ["mainframepicture"]=nil,
        ["timeframesetbackground"]=true
    }
}
LibStub("GuiSkin-1.0")["blank"] = [[Interface\AddOns\DKP-Bidder\arts\blank.tga]];

