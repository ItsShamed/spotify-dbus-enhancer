using GLib;

namespace SpotifyHook
{
    public abstract class MessageListener : SessionBusAdapter
    {
        private uint m_filterId = 0;
        private string m_matchRule = "";

        protected MessageListener(string matchRule)
        {
            m_matchRule = matchRule;
        }

        protected abstract DBusMessage? OnMessage(DBusConnection connection,
            owned DBusMessage message, bool incoming);

        private void addMatch(DBusConnection connection) throws Error
        {
            debug(@"Registering match rule '$m_matchRule'");
            connection.call_sync("org.freedesktop.DBus",
                "/org/freedesktop/DBus",
                "org.freedesktop.DBus",
                "AddMatch",
                new Variant.tuple({ new Variant.string(m_matchRule) }),
                null,
                DBusCallFlags.NONE,
                -1,
                null);
        }

        protected override void SetupConnection(DBusConnection connection)
        {
            try
            {
                addMatch(connection);
            }
            catch (Error e)
            {
                warning("Couldn't add match rule: (%s) %s",
                    e.domain.to_string(), e.message);
            }
            debug("Registering filter for connection %s",
                connection.unique_name);
            m_filterId = connection.add_filter(OnMessage);
            debug(@"Registered filter with id $m_filterId");
        }

        protected override void TeardownConnection(DBusConnection connection)
        {
            debug(@"Removing filter $m_filterId for connection %s",
                connection.unique_name);
            connection.remove_filter(m_filterId);
            base.TeardownConnection(connection);
        }
    }
}
