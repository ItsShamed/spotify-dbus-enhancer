using GLib;

namespace SpotifyHook
{
    public class BasicNotificationListener : NotificationListener
    {
        public BasicNotificationListener(string appName)
        {
            base(appName);
        }

        protected override void OnNotification(
            DBusConnection connection, NotifyCall parameters,
            owned DBusMessage rawMessage)
        {
            info("Hello notification!");
        }
    }
}
