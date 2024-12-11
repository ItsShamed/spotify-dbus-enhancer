using GLib;

namespace SpotifyHook.Domain
{
    public struct NotifyCall
    {
        public string AppName;
        public uint ReplacesId;
        public string AppIcon;
        public string Summary;
        public string Body;
        public (unowned string)[] Actions;
        public HashTable<string, Variant> Hints;
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

        if (variant.n_children() < 8)
        {
            debug("Variant does not have the right number of children??");
            return null;
        }

        Variant hintsVariant = variant.get_child_value(6);
        VariantIter hintsIter = hintsVariant.iterator();

        string? key = null;
        Variant? val = null;

        HashTable<string, Variant> hints =
            new HashTable<string, Variant>(str_hash, str_equal);

        while (hintsIter.next("{sv}", out key, out val))
            hints.insert(key, val);

        NotifyCall call = {
            AppName: VariantUtils.GetChildString(variant, 0),
            ReplacesId: VariantUtils.GetChildUint32(variant, 1),
            AppIcon: VariantUtils.GetChildString(variant, 2),
            Summary: VariantUtils.GetChildString(variant, 3),
            Body: VariantUtils.GetChildString(variant, 4),
            Actions: VariantUtils.GetChildStrv(variant, 5),
            Hints: hints,
            ExpireTimeout: VariantUtils.GetChildInt32(variant, 7)
        };
        return call;
    }
}
