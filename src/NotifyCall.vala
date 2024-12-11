using GLib;

namespace SpotifyHook
{
    public struct NotifyCall
    {
        public string AppName;
        public uint ReplacesId;
        public string AppIcon;
        public string Summary;
        public string Body;
        public (unowned string)[] Actions;
        public Variant Hints;
        public int ExpireTimeout;
    }

    public NotifyCall? VariantToNotifyCall(Variant? variant)
    {
        if (variant == null)
        {
            debug("Cannot convert null Variant to notify call struct");
            return null;
        }

        if (!Variant.is_signature("(susssasa{sv}i)"))
        {
            debug("Variant does not respect NotifyCall signature");
            return null;
        }

        NotifyCall call = {
            AppName: VariantUtils.GetChildString(variant, 0),
            ReplacesId: VariantUtils.GetChildUint32(variant, 1),
            AppIcon: VariantUtils.GetChildString(variant, 2),
            Summary: VariantUtils.GetChildString(variant, 3),
            Body: VariantUtils.GetChildString(variant, 4),
            Actions: VariantUtils.GetChildStrv(variant, 5),
            Hints: variant.get_child_value(6),
            ExpireTimeout: VariantUtils.GetChildInt32(variant, 7)
        };
        return call;
    }
}
