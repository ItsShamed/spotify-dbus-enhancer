using GLib;

namespace SpotifyHook
{
    public abstract class SessionBusAdapter : Object
    {
        private const int max_retries = 10;
        private Cancellable? m_cancellable;
        private DBusConnection m_connection;

        protected abstract void SetupConnection(DBusConnection connection);
        protected virtual void TeardownConnection(DBusConnection connection)
        {
            try
            {
                debug("Closing connection to session bus...");
                m_connection.close_sync(m_cancellable);
            }
            catch (Error e)
            {
                warning("Failed to close connection: (%s) %s",
                    e.domain.to_string(),
                    e.message);
            }
        }

        public async bool start(Cancellable? cancellable = null) throws IOError
        {
            info("Starting `%s' listener", this.get_type().name());
            this.m_cancellable = cancellable;
            DBusConnection? connection = null;
            IOError? lastError = null;

            for (int i = 0; i < max_retries; i++)
            {
                if (cancellable != null && cancellable.is_cancelled())
                    throw new IOError.CANCELLED("Operation is cancelled.");

                try
                {
                    debug("Trying to get DBus session bus connection...");
                    connection = yield Bus.get(BusType.SESSION, cancellable);
                }
                catch (IOError e)
                {
                    lastError = e;
                    warning("Failed to get DBus session bus (try %d): %s\n", i,
                        e.message);
                    continue;
                }
            }

            if (connection == null)
            {
                error("Failed to get DBus session bus (retried %d times)",
                    max_retries);
                if (lastError != null)
                    throw lastError;
            }

            debug("Got a session bus!");
            debug("GUID: %s", connection.guid);
            debug("Unique name: %s", connection.unique_name);

            debug("Setting up DBus session bus connection");
            SetupConnection(connection);
            debug("Finished setting up DBus session bus connection");

            this.m_connection = connection;
            return true;
        }

        public override void dispose()
        {
            this.TeardownConnection(m_connection);
            m_connection.dispose();
            base.dispose();
        }
    }
}
