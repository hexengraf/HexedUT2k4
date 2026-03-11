class HxGUIFramedButton extends HxGUIFramedMultiComponent;

var localized string Caption;

var GUIButton FramedButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    CreateComponent("XInterface.GUIButton", true);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIButton(NewComp) != None)
    {
        FramedButton = GUIButton(NewComp);
        FramedButton.StyleName = StyleName;
        FramedButton.FontScale = FontScale;
        FramedButton.Caption = Caption;
        FramedButton.Hint = Hint;
        FramedButton.bRepeatClick = bRepeatClick;
        FramedButton.bNeverFocus = bNeverFocus;
        FramedButton.OnClick = OnClick;
        FramedButton.OnRightClick = OnRightClick;
    }
}

function SetCaption(string NewCaption)
{
    Caption = NewCaption;
    FramedButton.Caption = Caption;
}

function float GetFontHeight(Canvas C)
{
    local float Height;

    GetFontSize(FramedButton, C,,, Height);
    return Height;
}

defaultproperties
{
    StyleName="HxFlatButton"
    OnCreateComponent=InternalOnCreateComponent
}
