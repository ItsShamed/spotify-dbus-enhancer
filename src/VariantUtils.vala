using GLib;

namespace SpotifyHook.VariantUtils
{
    public static unowned string GetChildString(Variant variant, size_t index)
    {
        return variant.get_child_value(index).get_string();
    }

    public static int32 GetChildInt32(Variant variant, size_t index)
    {
        return variant.get_child_value(index).get_int32();
    }

    public static uint32 GetChildUint32(Variant variant, size_t index)
    {
        return variant.get_child_value(index).get_uint32();
    }

    public static (unowned string)[] GetChildStrv(Variant variant, size_t index)
    {
        return variant.get_child_value(index).get_strv();
    }
}
