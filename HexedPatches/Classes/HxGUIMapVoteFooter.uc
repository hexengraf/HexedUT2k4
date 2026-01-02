class HxGUIMapVoteFooter extends MapVoteFooter;

var localized string VoteCaption;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    sb_Background.WinHeight = 0.666;
    ed_Chat.WinTop = sb_Background.WinTop + sb_Background.WinHeight + 0.01;
    ed_Chat.WinLeft = 0;
    ed_Chat.WinWidth = 1;
    ed_Chat.CaptionWidth = 0.10;
    ed_Chat.bBoundToParent = true;
    ed_Chat.bScaleToParent = true;
    b_Submit.Caption = VoteCaption;
    b_Submit.bBoundToParent = true;
    b_Submit.bScaleToParent = true;
    b_Submit.WinTop = ed_Chat.WinTop + ed_Chat.WinHeight + 0.05;
    b_Submit.WinLeft = 0;
    b_Submit.WinWidth = 0.495;
    b_Close.bBoundToParent = true;
    b_Close.bScaleToParent = true;
    b_Close.WinTop = ed_Chat.WinTop + ed_Chat.WinHeight + 0.05;
    b_Close.WinLeft = 0.505;
    b_Close.WinWidth = 0.495;

    Super.InitComponent(MyController, MyOwner);
}

function bool MyOnDraw(canvas C)
{
    return false;
}

defaultproperties
{
    VoteCaption="Vote"
}
