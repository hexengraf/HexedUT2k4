class HxGUIFramedButton extends HxGUIFramedComponent;

var localized string Caption;

var GUIButton FramedButton;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    bNeverFocus = true;
    SetHint("");
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

defaultproperties
{
    StyleName="HxFlatButton"
    DefaultComponentClass="XInterface.GUIButton"
    OnCreateComponent=InternalOnCreateComponent
}
