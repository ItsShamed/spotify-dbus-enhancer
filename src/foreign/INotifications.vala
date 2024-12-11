using GLib;

namespace SpotifyHook.Foreign
{
    [DBus(name = "org.freedesktop.Notifications")]
    public interface INotifications : Object
    {
        // Methods

        /**
        * Gets capabilites implemented by the server.
        *
        * Each string describes an optional capability implemented by the
        * server.
        *
        * @return array of capabilites implemented by the server.
        */
        public abstract string[] GetCapabilities() throws IOError, DBusError;

        /**
        * Sends a notification to the notification server.
        *
        *
        *
        * @param appName        The optional namne of the application sending
        *                       the notification. Can be blank.
        *
        * @param replacesId     The optional notification ID that this
        *                       notification replaces.
        *                       The server must atomically (ie with no flicker
        *                       or other visual cues) replace the given
        *                       notification with this one. This allows clients
        *                       to effectively modify the notification while
        *                       it's active. A value of 0 means that this
        *                       notification won't replace any existing
        *                       notifications.
        *
        * @param appIcon        The optional program icon of the calling
        *                       application. See [[https://specifications.freedesktop.org/notification-spec/1.2/icons-and-images.html|Icons and Images]].
        *                       Can be an empty string, indicating no icon.
        *
        * @param summary        The summary text briefly describing the
        *                       notification.
        *
        * @param body           The optional detailed body text. Can be empty.
        *
        * @param actions        Actions are sent over as a list of pairs. Each
        *                       even element in the list (starting at index 0)
        *                       represents the identifier for the action. Each
        *                       odd element in the list is the localized string
        *                       that will be displayed to the user.
        *
        * @param hints          Optional hints that can be passed to the server
        *                       from the client program. Although clients and
        *                       servers should never assume each other supports
        *                       any specific hints, they can be used to pass
        *                       along information, such as the process PID or
        *                       window ID, that the server may be able to make
        *                       use of. See [[https://specifications.freedesktop.org/notification-spec/1.2/hints.html|Hints]].
        *                       Can be empty.
        *
        * @param expireTimeout  The timeout time in milliseconds since the
        *                       display of the notification at which the
        *                       notification should automatically close.
        *                       If -1, the notification's expiration time is
        *                       dependent on the notification server's settings,
        *                       and may vary for the type of notification. If 0,
        *                       never expire.
        *
        * @return if ``replacesId`` is 0, then an ID that represents the
        *         notification. The returned ID is always greater that zero.
        *         If ``replacesId`` is not 0, then the value of ``replacesId``.
        */
        public abstract uint Notify(string appName, uint replacesId,
            string appIcon, string summary, string body, string[] actions,
            HashTable<string, Variant> hints, int expireTimeout)
            throws IOError, DBusError;

        /**
        * Forcefully close a notification.
        *
        * Causes a notification to be forcefully closed and removed from the
        * user's view. It can be used, for example, in the event that what the
        * notification pertains to is no longer relevant, or to cancel a
        * notification with no expiration time.
        * The ``NotificationClosed`` signal is emitted by this method.
        * If the notification no longer exists, an empty D-BUS Error message
        * is sent back.
        */
        public abstract void CloseNotification(uint id)
            throws IOError, DBusError;

        /**
        * Get information on the server.
        *
        * Specifically, the server name, vendor, and version number.
        *
        * @param name        The product name of the server.
        * @param vendor      The vendor name. For example, "KDE," "GNOME,"
        *                    "freedesktop.org," or "Microsoft."
        * @param version     The server's version number.
        * @param specVersion The specification version the server is compliant
        *                    with.
        */
        public abstract void GetServerInformation(out string name,
            out string vendor, out string version, out string specVersion)
            throws IOError, DBusError;

        // Signals

        /**
        * A completed notification is one that has timed out, or has been
        * dismissed by the user.
        *
        *
        * @param id     The ID of the notification that was closed.
        * @param reason The reason the notification was closed.
        */
        public signal void NotificationClosed(uint id, uint reason);

        /**
        * This signal is emitted on two situations.
        *
        *   * The user performs some global "invoking" action upon a
        *     notification. For instance, clicking somewhere on the notification
        *     itself.
        *   * The user invokes a specific action as specified in the original
        *     Notify request. For example, clicking on an action button.
        * NOTE: Clients should not assume the server will generate this signal.
        * Some servers may not support user interaction at all, or may not
        * support the concept of being able to "invoke" a notification.
        *
        * @param id         The ID of the notification emitting the
                            ActionInvoked signal.
        * @param actionKey 	The key of the action invoked. These match the keys
        *                   sent over in the list of actions. 
        */
        public signal void ActionInvoked(uint id, string actionKey);

        /**
        * This signal can be emitted before a ``ActionInvoked`` signal.
        *
        * It carries an activation token that can be used to activate a
        * toplevel.
        *
        * @param id
        * @param activationToken An activation token. This can be either an
        *                        X11-style startup ID (see [[https://specifications.freedesktop.org/startup-notification-spec/startup-notification-latest.txt|Startup notification protocol]])
        *                        or a [[https://gitlab.freedesktop.org/wayland/wayland-protocols/-/tree/main/staging/xdg-activation|Wayland xdg-activation]]
        *                        token
        */
        public signal void ActivationToken(uint id, string activationToken);
    }
}
