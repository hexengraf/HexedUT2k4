class HxGUIFramedImage extends HxGUIFramedComponent;

var Material Image;
var Color ImageColor;
var eImgStyle ImageStyle;
var EMenuRenderStyle ImageRenderStyle;
var Material FallbackImage;
var Color FallbackColor;
var int X1;
var int Y1;
var int X2;
var int Y2;

var GUIImage FramedImage;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    Super.InitComponent(MyController, MyOwner);
    FramedImage = GUIImage(MyComponent);
    FramedImage.Image = Image;
    FramedImage.ImageColor = ImageColor;
    FramedImage.ImageStyle = ImageStyle;
    FramedImage.ImageRenderStyle = ImageRenderStyle;
    FramedImage.X1 = X1;
    FramedImage.Y1 = Y1;
    FramedImage.X2 = X2;
    FramedImage.Y2 = Y2;
}

function SetImage(Material M)
{
    Image = M;
    if (Image != None)
    {
        FramedImage.Image = Image;
        FramedImage.ImageColor = ImageColor;
    }
    else
    {
        FramedImage.Image = FallbackImage;
        FramedImage.ImageColor = FallbackColor;
    }
}

function SetImageStyle(eImgStyle Style)
{
    ImageStyle = Style;
    FramedImage.ImageStyle = ImageStyle;
}

function SetImageColor(Color C)
{
    ImageColor = C;
    FramedImage.ImageColor = C;
}

defaultproperties
{
    DefaultComponentClass="XInterface.GUIImage"
    Image=Material'engine.WhiteSquareTexture'
    ImageColor=(R=255,G=255,B=255,A=255)
    ImageStyle=ISTY_Stretched
    ImageRenderStyle=MSTY_Alpha
    X1=-1
    Y1=-1
    X2=-1
    Y2=-1
    FallbackImage=Material'engine.WhiteSquareTexture'
    FallbackColor=(R=0,G=0,B=0,A=255)
    bNeverFocus=true
    OnPreDraw=InternalOnPreDraw
    OnRendered=InternalOnRendered
}
