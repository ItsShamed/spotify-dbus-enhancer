using GLib;
using SpotifyHook.Domain;

namespace SpotifyHook.Listeners
{
    public abstract class NotificationListener : MessageListener
    {
        private string m_appName;

        protected NotificationListener(string appName)
        {
            base("eavesdrop=true,interface='org.freedesktop.Notifications',member='Notify'");
            m_appName = appName;
        }

        protected abstract async void OnNotification(
            DBusConnection connection, NotifyCall parameters,
            owned DBusMessage rawMessage);

        protected override DBusMessage? OnMessage(DBusConnection connection,
            owned DBusMessage message, bool incoming)
        {
            if (!incoming)
            {
                debug("Discarding outgoing message");
                return message;
            }
            if (message.get_interface() != "org.freedesktop.Notifications" ||
                message.get_member() != "Notify")
            {
                debug("Received message for member '%s' of interface '%s'",
                    message.get_member(),
                    message.get_interface());
                switch (message.get_message_type())
                {
                case DBusMessageType.ERROR:
                    warning("Received error:\n%s", message.print(2));
                    return null;
                default:
                    return message;
                }
            }

            NotifyCall? call = VariantToNotifyCall(message.get_body());

            if (call == null)
                return message;

            if (call.AppName != m_appName)
            {
                debug(@"App name '%s' does not match '$m_appName', discarding.",
                    call.AppName);
                return null;
            }

            OnNotification.begin(connection, call, message);
            return null;
        }
    }
}
