using GLib;

namespace SpotifyHook
{
    public abstract class NotificationListener : MessageListener
    {
        private string m_appName;

        protected NotificationListener(string appName)
        {
            base("eavesdrop=true, interface='org.freedesktop.Notifications', member='Notify'");
            m_appName = appName;
        }

        protected abstract void OnNotification(
            DBusConnection connection, NotifyCall parameters,
            owned DBusMessage rawMessage);

        protected override DBusMessage? OnMessage(DBusConnection connection,
            owned DBusMessage message, bool incoming)
        {
            if (message.get_message_type() != DBusMessageType.METHOD_CALL)
            {
                if (message.get_message_type() == DBusMessageType.ERROR)
                {
                    warning("Received error:\n%s", message.print(2));
                }
                else
                {
                    debug("Received message of type '%s' instead of '%s', discarding.",
                            message.get_message_type().to_string(),
                            DBusMessageType.METHOD_CALL.to_string());
                }
                return null;
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

            OnNotification(connection, call, message);
            return null;
        }
    }
}
