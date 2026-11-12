#language slang 2026
import luduvo;

struct Mirror : IMaterial
{
    [Group("Mirror")] [Range(0, 1)] float transparency = 1.0; // How much of a mirror the mirror is
    [Group("Mirror")] [Range(0, 1)] float blurryness = 0.05; // How blurry/glossy the mirror is

    Surface surface(SurfaceInput i)
    {
        Surface s = Surface(i);
        s.lit = true;
        s.roughness = blurryness;
        s.metallic = transparency;
        return s;
    }
};

export struct Material : IMaterial = Mirror;
