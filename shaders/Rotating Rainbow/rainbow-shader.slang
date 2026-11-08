// Made by Jediweirdo. Do what you want with it

#language slang 2026
import luduvo;

// A Rainbow bold ink outline that follows the shape of every
// part, mesh and character wearing the material.
struct Ink : IMaterial, IOutline
{
    [Range(0, 15)] [Group("Outline")] float inkWeight = 3;                 // outline width in pixels
    [Range(0, 1)] [Group("Outline")] float lineRoughness = 0;                     // 0 draws a clean line, 1 a rough hand-drawn one
    [Range(0, 1)] [Group("Cel")] float colorDisplacement = 0;          // angle displacement for the rainbow color
    Surface surface(SurfaceInput i)
    {
        return Surface(i);
    }

    Outline outline(OutlineInput i)
    {
        float3 palette[6] = {
            float3(1, 0, 0), // red       0°
            float3(1, 1, 0), // yellow   60°
            float3(0, 1, 0), // green   120°
            float3(0, 1, 1), // cyan    180°
            float3(0, 0, 1), // blue    240°
            float3(1, 0, 1)  // magenta 300°
        };

        float2 p = i.objectPosition.xy;
        float angle = 0.0; // angle of the object position in radians. Think of this like a color wheel position
        if (dot(p, p) > 0.0)
            angle = atan2(p.y, p.x);

        // 6.2831853 = 2π
        float turns = frac(angle / (6.2831853 + colorDisplacement)) - 1.0; // turns = angle / (2π + colorDisplacement) - 1
        float colorLocation = turns * 6.0; // [colorLocation].[progress to next color]

        int lastColor = int(colorLocation) % 6; // extracts the color location
        int nextColor = (lastColor + 1) % 6; // extracts the next color location

        Outline o = Outline(i);
        o.color = lerp(palette[lastColor], palette[nextColor], // blends the two palette colors together
            frac(colorLocation)); // extracts color progress from colorLocation (the decimal part)

        float wobble = frac(sin(dot(i.objectPosition, float3(12.9898, 78.233, 37.719))) * 43758.5453); // random generator
        o.width = inkWeight * (1.0 + lineRoughness * (2.0 * wobble - 1.0));
        return o;

    }};

export struct Material : IMaterial = Ink;
