class HxGUIFramedLabel extends HxGUIFramedComponent;

var localized string Caption;
var eTextAlign TextAlign;
var Color TextColor;
var Color FocusedTextColor;
var Color BackColor;
var bool bTransparent;

var GUILabel FramedLabel;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    bNeverFocus = true;
    SetHint("");
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUILabel(NewComp) != None)
    {
        FramedLabel = GUILabel(NewComp);
        FramedLabel.StyleName = StyleName;
        FramedLabel.FontScale = FontScale;
        FramedLabel.TextAlign = TextAlign;
        FramedLabel.TextColor = TextColor;
        FramedLabel.FocusedTextColor = FocusedTextColor;
        FramedLabel.BackColor = BackColor;
        FramedLabel.bTransparent = bTransparent;
        FramedLabel.bNeverFocus = bNeverFocus;
        FramedLabel.Caption = Caption;
        FramedLabel.Hint = Hint;
    }
}

function SetCaption(string NewCaption)
{
    Caption = NewCaption;
    FramedLabel.Caption = Caption;
}

defaultproperties
{
    StyleName="HxListHeader"
    TextAlign=TXTA_Center
    TextColor=(R=255,G=210,B=0,A=255)
    FocusedTextColor=(R=255,G=210,B=0,A=255)
    BackColor=(R=32,G=50,B=106,A=255)
    bTransparent=false
    DefaultComponentClass="XInterface.GUILabel"
    OnCreateComponent=InternalOnCreateComponent
}
