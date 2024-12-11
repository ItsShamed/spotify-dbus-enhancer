using GLib;
using SpotifyHook.Domain;
using SpotifyHook.Foreign;
using SpotifyHook.Foreign.Mpris;

namespace SpotifyHook.Listeners
{
    public class SpotifyNotificationListener : NotificationListener
    {
        private const uint c_max_retries = 10;
        private INotifications? m_notifications = null;
        private IPlayer? m_spotify = null;
        private Thread<void> m_spotifyThread;
        private Thread<void> m_dequeueThread;
        private Cancellable m_threadCancellable = new Cancellable();
        private AsyncQueue<NotifyCall?> m_notifyQueue =
            new AsyncQueue<NotifyCall?>();

        public SpotifyNotificationListener()
        {
            base("Spotify");
            initForeignInterfaces.begin();
            m_dequeueThread =
                new Thread<void>("notify-dequeue", waitForNotifyQueue);
        }

        protected override async void OnNotification(
            DBusConnection connection, NotifyCall parameters,
            owned DBusMessage rawMessage)
        {
            info("Received Spotify notification");
            if (parameters.Hints.contains("tsrk_was_here"))
            {
                info("Notification is already modified, not touching it");
                return;
            }

            debug(@"Spotify metadata has $(m_spotify.Metadata.size()) entries");
            HashTable<string, Variant> metadata = m_spotify.Metadata;
            string artist = string.joinv(", ",
                metadata["xesam:artist"].get_strv());
            string albumArtist = string.joinv(", ",
                metadata["xesam:artist"].get_strv());
            string album = metadata["xesam:album"].get_string();
            string title = metadata["xesam:title"].get_string();

            parameters.Hints.insert("tsrk_was_here", new Variant.boolean(true));
            parameters.Summary = "Now Playing";
            parameters.Body =
                @"$artist - $title\nfrom <i>$album</i>\nby <u><i>$albumArtist</i></u>";
            parameters.ExpireTimeout = 5000;

            queueNotify(parameters);

            debug("ok");
        }

        private void queueNotify(NotifyCall notify)
        {
            debug("Pushing notify call");
            m_notifyQueue.push(notify);
        }

        private async void sendNotify(NotifyCall notify)
        {
            info("Sending 'Notify' call: [%s] '%s' '%s'", notify.AppName,
                notify.Summary, notify.Body);
            try
            {
                m_notifications.Notify(notify.AppName, notify.ReplacesId,
                    notify.AppIcon, notify.Summary, notify.Body, notify.Actions,
                    notify.Hints, notify.ExpireTimeout);
            }
            catch (IOError e)
            {
                warning("IOError when sending notification: (%s) %s",
                    e.domain.to_string(), e.message);
            }
            catch (DBusError e)
            {
                warning("DBusError when sending notification: (%s) %s",
                    e.domain.to_string(), e.message);
            }
        }

        private void waitForNotifyQueue()
        {
            while (!m_threadCancellable.is_cancelled())
            {
                Thread.yield();
                debug("Popping notify queue (will block)");
                NotifyCall notify = m_notifyQueue.pop();
                debug("Sending queued notification with replace id %u",
                    notify.ReplacesId);
                sendNotify.begin(notify);
                Thread.yield();
                Thread.usleep(1000);
            }
        }

        private void listenForSpotify()
        {
            while (!m_threadCancellable.is_cancelled())
            {
                if (m_spotify != null)
                    continue;
                debug("Trying to get player proxy bus object");
                try
                {
                    Thread.yield();
                    m_spotify = Bus.get_proxy_sync(BusType.SESSION,
                            "org.mpris.MediaPlayer2.spotify",
                            "/org/mpris/MediaPlayer2",
                            DBusProxyFlags.DO_NOT_AUTO_START);
                }
                catch (IOError e)
                {
                    warning(@"Is Spotify running? Failed to get Spotify player proxy: (%s) %s",
                        e.domain.to_string(), e.message);
                }
                if (m_spotify != null)
                    info("Acquired Spotify player proxy bus object");
                Thread.yield();
                Thread.usleep(1000);
            }
        }

        private async void initForeignInterfaces()
        {
            info("Initialising Notification proxy bus object");

            for (int i = 0; m_notifications == null && i < c_max_retries; i++)
            {
                debug(@"Trying to get proxy bus object (try $i)");
                try
                {
                    m_notifications = yield Bus.get_proxy(BusType.SESSION,
                            "org.freedesktop.Notifications",
                            "/org/freedesktop/Notifications");
                }
                catch(IOError e)
                {
                    debug(@"Failed to get Notification proxy: (%s) %s",
                        e.domain.to_string(), e.message);
                }
            }

            if (m_notifications == null)
                warning("Failed to get Notification proxy bus object");
            else
                info("Acquired Notification proxy bus object");

            info("Listening for Spotify player proxy bus object");

            m_spotifyThread = new Thread<void>("spotify-listener",
                listenForSpotify);
        }

        public override void dispose()
        {
            m_threadCancellable.cancel();
            m_spotifyThread.join();
            m_dequeueThread.join();
            base.dispose();
        }
    }
}
