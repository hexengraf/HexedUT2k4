class HxGUIFramedImage extends HxGUIFramedMultiComponent;

struct HxGUIImageSource
{
    var Material Image;
    var Color Color;
    var eImgStyle Style;
    var eImgAlign Align;
    var float RenderWeight;
    var bool bSubImage;
    var int X1;
    var int Y1;
    var int X2;
    var int Y2;
};

var EMenuRenderStyle RenderStyle;
var array<HxGUIImageSource> ImageSources;
var array<GUIImage> Images;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
    local int i;

    Super.InitComponent(MyController, MyOwner);
    for (i = 0; i < ImageSources.Length; ++i)
    {
        CreateImage(ImageSources[i]);
    }
}

function AddImage(HxGUIImageSource Source)
{
    ImageSources[ImageSources.Length] = Source;
    CreateImage(Source);
}

function CreateImage(HxGUIImageSource Source)
{
    Local GUIImage NewImage;

    NewImage = GUIImage(CreateComponent("XInterface.GUIImage", true));
    NewImage.Image = Source.Image;
    NewImage.ImageColor = Source.Color;
    NewImage.ImageStyle = Source.Style;
    NewImage.ImageAlign = Source.Align;
    if (Source.RenderWeight > 0)
    {
        NewImage.RenderWeight = Source.RenderWeight;
    }
    if (Source.bSubImage)
    {
        NewImage.X1 = Source.X1;
        NewImage.Y1 = Source.Y1;
        NewImage.X2 = Source.X2;
        NewImage.Y2 = Source.Y2;
    }
    if (NewImage.Image == None)
    {
        NewImage.Image = Material'engine.WhiteSquareTexture';
    }
    NewImage.ImageRenderStyle = RenderStyle;
    Images[Images.Length] = NewImage;
}

defaultproperties
{
    RenderStyle=MSTY_Alpha
}
