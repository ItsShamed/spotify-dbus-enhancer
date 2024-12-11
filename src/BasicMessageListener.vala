using GLib;

namespace SpotifyHook
{
    public class BasicMessageListener : MessageListener
    {
        public BasicMessageListener(string matchRule)
        {
            base(matchRule);
        }

        protected override DBusMessage? OnMessage(DBusConnection connection,
            owned DBusMessage message, bool incoming)
        {
            info("Received message on %s", connection.unique_name);
            message.print();

            try
            {
                return message.copy();
            }
            catch (Error e)
            {
                warning("Failed to copy message: (%s) %s",
                    e.domain.to_string(), e.message);
                return null;
            }
        }
    }
}
