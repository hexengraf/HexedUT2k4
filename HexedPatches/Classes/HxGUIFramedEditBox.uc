class HxGUIFramedEditBox extends HxGUIFramedMultiComponent;

var localized string Caption;

var GUIEditBox EditBox;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    CreateComponent("XInterface.GUIEditBox", true);
}

function InternalOnCreateComponent(GUIComponent NewComp, GUIComponent Sender)
{
    if (GUIEditBox(NewComp) != None)
    {
        EditBox = GUIEditBox(NewComp);
        EditBox.StyleName = StyleName;
        EditBox.FontScale = FontScale;
        EditBox.Caption = Caption;
        EditBox.Hint = Hint;
        EditBox.OnChange = OnChange;
        EditBox.OnKeyEvent = InternalOnKeyEvent;
    }
}

function bool InternalOnKeyEvent(out byte Key, out byte State, float Delta)
{
    return OnKeyEvent(Key, State, Delta) || EditBox.InternalOnKeyEvent(Key, State, Delta);
}

function SetCaption(string NewCaption)
{
    Caption = NewCaption;
    EditBox.Caption = Caption;
}

function SetText(string NewText)
{
    EditBox.SetText(NewText);
}

function string GetText()
{
    return EditBox.GetText();
}

function float GetFontHeight(Canvas C)
{
    local float Height;

    GetFontSize(EditBox, C,,, Height);
    return Height;
}

defaultproperties
{
    StyleName="HxEditBox"
    FontScale=FNS_Small
    OnCreateComponent=InternalOnCreateComponent
}
