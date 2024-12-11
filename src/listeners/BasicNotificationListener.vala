using GLib;
using SpotifyHook.Domain;

namespace SpotifyHook.Listeners
{
    public class BasicNotificationListener : NotificationListener
    {
        public BasicNotificationListener(string appName)
        {
            base(appName);
        }

        protected override async void OnNotification(
            DBusConnection connection, NotifyCall parameters,
            owned DBusMessage rawMessage)
        {
            info("Hello notification!");
        }
    }
}
