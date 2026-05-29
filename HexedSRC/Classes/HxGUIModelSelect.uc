class HxGUIModelSelect extends HxGUIFloatingWindow;

var automated HxGUIFramedSection MainSection;
var automated HxGUIFramedSection ListSection;
var automated HxGUIVertImageListBox ModelList;
var automated MoComboBox co_Race;
var automated GUIButton b_PreviewBox;
var automated GUILabel l_ButtonAnchor;
var automated GUIButton b_Cancel;
var automated GUIButton b_Ok;

var private array<xUtil.PlayerRecord> PlayerList;
var private SpinnyWeap PreviewModel;
var private vector PreviewOffset;
var private int PreviewSpin;
var private rotator PreviewRotation;
var private int DisplayFOV;
var private string InvalidTypes;
var private string IgnoredTypes;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.Initcomponent(MyController, MyOwner);
    MainSection.Insert(ListSection);
    MainSection.Insert(co_Race);
    MainSection.Insert(b_PreviewBox);
    MainSection.Insert(l_ButtonAnchor);
    ListSection.Insert(ModelList);
    class'xUtil'.static.GetPlayerList(PlayerList);
    RefreshCharacterList(InvalidTypes);
    PopulateRaces();
}

event Opened(GUIComponent Sender)
{
    local PlayerController PC;

    Super.Opened(Sender);
    PC = PlayerOwner();
    if (PreviewModel == None)
    {
        PreviewModel = PC.Spawn(class'XInterface.SpinnyWeap');
        PreviewModel.SetDrawType(DT_Mesh);
        PreviewModel.SetDrawScale(1.0);
        PreviewModel.bHidden = true;
        PreviewModel.bPlayCrouches = false;
        PreviewModel.bPlayRandomAnims = false;
        PreviewModel.SpinRate = 0;
        PreviewModel.AmbientGlow = 40;
    }
    UpdateRotation(PC);
}

function Free()
{
    Super.Free();
    if (PreviewModel != None)
    {
        PreviewModel.Destroy();
    }
    PreviewModel = None;
}

function PopulateRaces()
{
    local string Race;
    local int i;

    co_Race.MyComboBox.List.bInitializeList = true;
    co_Race.bIgnoreChange = true;
    co_Race.AddItem("All");
    for (i = 0; i < PlayerList.Length; ++i)
    {
        Race = PlayerList[i].Race;
        if (Race != "" && co_Race.MyComboBox.List.FindIndex(Race, true) == -1)
        {
            co_Race.AddItem(Race);
        }
    }
    co_Race.bIgnoreChange = false;
    RaceOnChange(None);
}

function RefreshCharacterList(string ExcludedChars, optional string Race)
{
    local array<string> Excluded;
    local int i;
    local int j;

    ModelList.List.bNotify = False;
    ModelList.Clear();
    Split(ExcludedChars, ";", Excluded);
    for (i = 0; i < PlayerList.Length; ++i)
    {
        if (Race == "" || Race ~= PlayerList[i].Race)
        {
            if (PlayerList[i].Menu != "")
            {
                for (j = 0; j < Excluded.Length; ++j)
                {
                    if (InStr(";"$PlayerList[i].Menu$";", ";"$Excluded[j]$";") != -1)
                    {
                        break;
                    }
                }
                if (j < Excluded.Length)
                {
                    continue;
                }
            }
            ModelList.List.Add(PlayerList[i].Portrait, i, int(!IsUnLocked(PlayerList[i])));
        }
    }
    ModelList.List.LockedMat = Texture'PlayerPictures.cDefault';
    ModelList.List.bNotify = true;
}

function ModelListOnChange(GUIComponent Sender)
{
    local ImageListElem Elem;

    ModelList.List.GetAtIndex(ModelList.List.Index, Elem.Image, Elem.Item, Elem.Locked);
    if (Elem.Item >= 0 && Elem.Item < PlayerList.Length)
    {
        if (Elem.Locked == 1)
        {
            b_Ok.DisableMe();
        }
        else
        {
            b_Ok.EnableMe();
        }
        MainSection.SetCaption(PlayerList[Elem.Item].DefaultName);
    }
    else
    {
        MainSection.SetCaption("");
    }
    UpdatePreview();
}

function RaceOnChange(GUIComponent Sender)
{
    local string Race;

    Race = co_Race.GetText();
    RefreshCharacterList(InvalidTypes, Eval(Race != "All", Race, ""));
}

function UpdatePreview()
{
    local xUtil.PlayerRecord Record;
    local int Index;

    Index = ModelList.List.GetItem();
    if (Index >= 0 && Index < PlayerList.Length)
    {
        Record = PlayerList[Index];
        PreviewModel.LinkMesh(Mesh(DynamicLoadObject(Record.MeshName, class'Mesh')));
        PreviewModel.Skins[0] = Material(DynamicLoadObject(Record.BodySkinName, class'Material'));
        PreviewModel.Skins[1] = Material(DynamicLoadObject(Record.FaceSkinName, class'Material'));
        PreviewModel.LoopAnim('Idle_Rest', 1.0 / PreviewModel.Level.TimeDilation);
    }
}

function bool InternalOnDraw(Canvas C)
{
    local vector CameraPosition;
    local rotator CameraRotation;
    local vector X;
    local vector Y;
    local vector Z;

    b_PreviewBox.Style.Draw(
        C,
        MenuState,
        b_PreviewBox.Bounds[0],
        b_PreviewBox.Bounds[1],
        b_PreviewBox.Bounds[2] - b_PreviewBox.Bounds[0],
        b_PreviewBox.Bounds[3] - b_PreviewBox.Bounds[1]);
    C.GetCameraLocation(CameraPosition, CameraRotation);
    GetAxes(CameraRotation, X, Y, Z);
    PreviewModel.SetLocation(
        CameraPosition + (PreviewOffset.X * X) + (PreviewOffset.Y * Y) + (PreviewOffset.Z * Z));
    C.DrawActorClipped(
        PreviewModel,
        false,
        b_PreviewBox.ClientBounds[0],
        b_PreviewBox.ClientBounds[1],
        b_PreviewBox.ClientBounds[2] - b_PreviewBox.ClientBounds[0],
        b_PreviewBox.ClientBounds[3] - b_PreviewBox.ClientBounds[1],
        true,
        DisplayFOV);
    return true;
}

function HandleParameters(string Param1, string Param2)
{
    local int Index;
    local int i;

    for (i = 0; i < PlayerList.Length; ++i)
    {
        if (PlayerList[i].DefaultName ~= Param1 && IsUnlocked(PlayerList[i]))
        {
            Index = ModelList.List.FindItem(i);
            if (Index >= 0)
            {
                ModelList.List.SetIndex(Index);
                ModelList.List.SetTopItem(
                    Max(0, Min(ModelList.ItemCount(), Index + 12) - 12 - (Index % 4)));
                if (ModelList.List.MyScrollBar != None)
                {
                    ModelList.List.MyScrollBar.AlignThumb();
                }
            }
        }
    }
    UpdatePreview();
}

function string GetDataString()
{
    local int Index;

    Index = ModelList.List.GetItem();
    if (Index >= 0 && Index < PlayerList.Length)
    {
        return PlayerList[Index].DefaultName;
    }
    return "";
}

function bool IsHiddenCharacter(string CharacterMenuString)
{
    local array<string> RecordFilters;
    local int i;

    if (CharacterMenuString == "")
    {
        return false;
    }
    Split(CharacterMenuString, ";", RecordFilters);
    for (i = RecordFilters.Length - 1; i >= 0; --i)
    {
        if (InStr(";"$IgnoredTypes$";", ";"$RecordFilters[i]$";") != -1)
        {
            RecordFilters.Remove(i, 1);
            continue;
        }
    }
    return RecordFilters.Length > 0;
}

function bool IsUnlocked(xUtil.PlayerRecord Record)
{
    return !IsHiddenCharacter(Record.Menu) || class'UT2K4MainPage'.static.IsUnlocked(Record.Menu);
}

function bool FloatingPreDraw(Canvas C)
{
    local float ActualSpacing;
    local float VerticalSpacing;
    local float HorizontalSpacing;

    if (bInit)
    {
        ActualSpacing = SPACING * C.ClipY;
        VerticalSpacing = ActualSpacing / ActualHeight();
        HorizontalSpacing = ActualSpacing / ActualWidth() / 2;
        MainSection.WinLeft = 3.5 * HorizontalSpacing;
        MainSection.WinTop =
            (HxGUIHeader(t_WindowTitle).GetDesiredHeight(C) + 1.5 * ActualSpacing) / ActualHeight();
        MainSection.WinWidth = 1.0 - (7 * HorizontalSpacing);
        MainSection.WinHeight = 1.0 - (2 * VerticalSpacing) - MainSection.WinTop;
    }
    return Super.FloatingPreDraw(C);
}

function bool InternalOnCapturedMouseMove(float DeltaX, float DeltaY)
{
    local Rotator Delta;
    local Vector X;
    local Vector Y;
    local Vector Z;

    PreviewSpin -= 256 * DeltaX;
    Delta.Yaw = PreviewSpin;
    GetAxes(PreviewRotation, X, Y, Z);
    X = vector(Delta) >> PreviewRotation;
    Delta.Yaw += 16384;
    Y = vector(Delta) >> PreviewRotation;
    PreviewModel.SetRotation(OrthoRotation(X, Y, Z));
    return true;
}

function UpdateRotation(PlayerController PC)
{
    PreviewRotation = PC.Rotation;
    PreviewRotation.Pitch += 32768;
    PreviewRotation.Roll += 32768;
    PreviewModel.SetRotation(PreviewRotation);
    PreviewSpin = 0;
}

function bool InternalButtonsOnPreDraw(Canvas C)
{
    if (l_ButtonAnchor.bInit)
    {
        l_ButtonAnchor.bInit = MainSection.bInit;
        b_Cancel.WinLeft = l_ButtonAnchor.WinLeft;
        b_Cancel.WinTop = l_ButtonAnchor.WinTop;
        b_Cancel.WinWidth = (l_ButtonAnchor.WinWidth - 0.005) / 2;
        b_Ok.WinLeft = b_Cancel.WinLeft + b_Cancel.WinWidth + 0.005;
        b_Ok.WinTop = l_ButtonAnchor.WinTop;
        b_Ok.WinWidth = b_Cancel.WinWidth;
    }
    return false;
}

function bool InternalOnClick(GUIComponent Sender)
{
    Controller.CloseMenu(Sender == b_Cancel);
    return true;
}

defaultproperties
{
    Begin Object class=HxGUIFramedSection Name=MainFramedSection
        ColumnWidths=(0.5,0.5)
        ExpandIndices=(0,2)
        MaxItemsPerColumn=2
    End Object
    MainSection=MainFramedSection

    Begin Object class=HxGUIFramedSection Name=ListFramedSection
        LeftPadding=0
        TopPadding=0
        RightPadding=0
        BottomPadding=0
        StyleName="HxBackground"
        bNoHeader=true
        ExpandIndices=(0)
        RenderWeight=0.1
    End Object
    ListSection=ListFramedSection

    Begin Object Class=HxGUIVertImageListBox Name=ModelImageListBox
        CellStyle=CELL_FixedCount
        NoVisibleRows=3
        NoVisibleCols=4
        bStandardized=false
        bBoundToParent=true
        bScaleToParent=true
        OnChange=ModelListOnChange
        TabOrder=0
    End Object
    ModelList=ModelImageListBox

    Begin Object Class=moComboBox Name=RaceComboBox
        Caption="Race"
        Hint="Filter the available characters by race."
        bReadOnly=true
        CaptionWidth=0.2
        bBoundToParent=true
        bScaleToParent=true
        OnChange=RaceOnChange
        TabOrder=1
    End Object
    co_Race=RaceComboBox

    Begin Object class=GUIButton Name=PreviewBoxButton
        StyleName="HxBackgroundDarker"
        bStandardized=false
        bTabStop=false
        bNeverFocus=true
        bDropTarget=true
        OnDraw=InternalOnDraw
        OnCapturedMouseMove=InternalOnCapturedMouseMove
    End Object
    b_PreviewBox=PreviewBoxButton

    Begin Object class=GUILabel Name=ButtonAnchorLabel
        StandardHeight=0.03
        bStandardized=true
        bInit=true
        OnPreDraw=InternalButtonsOnPreDraw
    End Object
    l_ButtonAnchor=ButtonAnchorLabel

    Begin Object Class=GUIButton Name=CancelButton
        Caption="Cancel"
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=InternalOnClick
        TabOrder=2
    End Object
    b_Cancel=CancelButton

    Begin Object Class=GUIButton Name=OkButton
        Caption="Ok"
        StandardHeight=0.03
        bStandardized=true
        StyleName="HxSquareButton"
        bRepeatClick=false
        OnClick=InternalOnClick
        TabOrder=3
    End Object
    b_Ok=OkButton

    WindowName="Select Character"
    WinLeft=0.17
    WinTop=0.165
    WinWidth=0.66
    WinHeight=0.62
    bPersistent=false
    PreviewOffset=(X=250,Z=-3)
    DisplayFOV=25
    InvalidTypes="DUP"
    IgnoredTypes="SP"
}
