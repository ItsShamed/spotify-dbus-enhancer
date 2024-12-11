using GLib;

namespace SpotifyHook.Foreign.Mpris
{
    [DBus(name = "org.mpris.MediaPlayer2.Player")]
    public interface IPlayer : Object
    {
        // Methods
        /**
        * Skips to the next track in the tracklist.
        *
        * If there is no next track (and endless playback and track repeat are
        * both off), stop playback.
        * If playback is paused or stopped, it remains that way.
        * If ``CanGoNext`` is ``false``, attempting to call this method should
        * have no effect.
        *
        * @see CanGoNext
        */
        public abstract void Next() throws IOError, DBusError;

        /**
        * Skips to the previous track in the tracklist.
        *
        * If there is no previous track (and endless playback and track repeat
        * are both off), stop playback.
        * If playback is paused or stopped, it remains that way.
        * If ``CanGoPrevious`` is ``false``, attempting to call this method
        * should have no effect.
        *
        * @see CanGoPrevious
        */
        public abstract void Previous() throws IOError, DBusError;

        /**
        * Pauses playback.
        *
        * If playback is already paused, this has no effect.
        * Calling Play after this should cause playback to start again from the
        * same position.
        * If ``CanPause`` is ``false``, attempting to call this method should
        * have no effect.
        *
        * @see CanPause
        */
        public abstract void Pause() throws IOError, DBusError;

        /**
        * Pauses playback.
        *
        * If playback is already paused, resumes playback.
        * If playback is stopped, starts playback.
        * If ``CanPause`` is ``false``, attempting to call this method should
        * have no effect.
        *
        * @see CanPause
        */
        public abstract void PlayPause() throws IOError, DBusError;

        /**
        * Stops playback.
        *
        * If playback is already stopped, this has no effect.
        * Calling Play after this should cause playback to start again from the
        * beginning of the track.
        * If ``CanControl`` is ``false``, attempting to call this method should
        * have no effect and raise an error.
        *
        * @see CanControl
        */
        public abstract void Stop() throws IOError, DBusError;

        /**
        * Starts or resumes playback.
        *
        * If already playing, this has no effect.
        * If paused, playback resumes from the current position.
        * If there is no track to play, this has no effect.
        * If ``CanPlay`` is ``false``, attempting to call this method should
        * have no effect.
        *
        * @see CanPlay
        */
        public abstract void Play() throws IOError, DBusError;

        /**
        * Seeks forward in the current track by the specified number of microseconds.
        *
        * A negative value seeks back. If this would mean seeking back further
        * than the start of the track, the position is set to 0.
        * If the value passed in would mean seeking beyond the end of the track,
        * acts like a call to Next.
        * If the ``CanSeek`` property is ``false``, this has no effect.
        *
        * @param offset The number of microseconds to seek forward.
        *
        * @see CanSeek
        */
        public abstract void Seek(int64 offset) throws IOError, DBusError;

        /**
        * Sets the current track position in microseconds.
        *
        * If the Position argument is less than 0, do nothing.
        * If the Position argument is greater than the track length, do nothing.
        * If the ``CanSeek`` property is ``false``, this has no effect. 
        *
        * @param trackId  The currently playing track's identifier.
        *                 If this does not match the id of the
        *                 currently-playing track, the call is ignored as
        *                 "stale".
        *                 ``/org/mpris/MediaPlayer2/TrackList/NoTrack`` is not
        *                 a valid value for this argument.
        * @param position Track position in microseconds.
        *                 This must be between 0 and ``<track_length>``.
        * @see CanSeek
        */
        public abstract void SetPosition(ObjectPath trackId, int64 position)
            throws IOError, DBusError;

        /**
        * Opens the Uri given as an argument
        *
        * If the playback is stopped, starts playing
        * If the uri scheme or the mime-type of the uri to open is not
        * supported, this method does nothing and may raise an error. In
        * particular, if the list of available uri schemes is empty, this
        * method may not be implemented.
        * Clients should not assume that the Uri has been opened as soon as
        * this method returns. They should wait until the ``mpris:trackid`` 
        * field in the ``Metadata`` property changes.
        * If the media player implements the ``TrackList`` interface, then the
        * opened track should be made part of the tracklist,
        * the ``org.mpris.MediaPlayer2.TrackList.TrackAdded`` or 
        * ``org.mpris.MediaPlayer2.TrackList.TrackListReplaced`` signal should
        * be fired, as well as the 
        * ``org.freedesktop.DBus.Properties.PropertiesChanged`` signal on the
        * tracklist interface.
        *
        * @param uri Uri of the track to load. Its uri scheme should be an
        *            element of the 
        *            ``org.mpris.MediaPlayer2.SupportedUriSchemes`` property
        *            and the mime-type should match one of the elements of the
        *            ``org.mpris.MediaPlayer2.SupportedMimeTypes``.
        * @see Metadata
        */
        public abstract void OpenUri(string uri) throws IOError, DBusError;

        // Signals
        /**
        * Indicates that the track position has changed in a way that is
        * inconsistent with the current playing state.
        *
        * When this signal is not received, clients should assume that:
        *   * When playing, the position progresses according to the rate
        *     property.
        *   * When paused, it remains constant.
        * This signal does not need to be emitted when playback starts or when
        * the track changes, unless the track is starting at an unexpected
        * position. An expected position would be the last known one when going
        * from //Paused// to //Playing//, and 0 when going from //Stopped// to
        * //Playing//.
        *
        * @param position The new position, in microseconds.
        */
        public signal void Seeked(int64 position);

        // Properties
        /**
        * The current playback status.
        *
        * May be "Playing", "Paused" or "Stopped".
        */
        public abstract string PlaybackStatus { owned get; }

        /**
        * The current loop / repeat status
        * 
        * May be:
        *   * "None" if the playback will stop when there are no more tracks to
        *     play
        *   * "Track" if the current track will start again from the begining
        *     once it has finished playing
        *   * "Playlist" if the playback loops through a list of tracks
        * If ``CanControl`` is ``false``, attempting to set this property should
        * have no effect and raise an error.
        *
        * @see CanControl
        */
        public abstract string LoopStatus { owned get; set; }

        /**
        * The current playback rate.
        *
        * The value must fall in the range described by ``MinimumRate`` and
        * ``MaximumRate``, and must not be 0.0. If playback is paused, the
        * ``PlaybackStatus`` property should be used to indicate this. A value
        * of 0.0 should not be set by the client. If it is, the media player
        * should act as though ``Pause`` was called.
        * If the media player has no ability to play at speeds other than the
        * normal playback rate, this must still be implemented, and must return
        * 1.0. The ``MinimumRate`` and ``MaximumRate`` properties must also be
        * set to 1.0.
        * Not all values may be accepted by the media player. It is left to
        * media player implementations to decide how to deal with values they
        * cannot use; they may either ignore them or pick a "best fit" value.
        * Clients are recommended to only use sensible fractions or multiples of
        * 1 (eg: 0.5, 0.25, 1.5, 2.0, etc).
        *
        * @see MinimumRate
        * @see MaximumRate
        * @see Pause
        * @see PlaybackStatus
        */
        public abstract double Rate { get; set; }

        /**
        * Whether shuffle is enabled.
        * 
        * A value of ``false`` indicates that playback is progressing linearly
        * through a playlist, while ``true`` means playback is progressing
        * through a playlist in some other order.
        * If ``CanControl`` is ``false``, attempting to set this property
        * should have no effect and raise an error.
        *
        * @see CanControl
        */
        public abstract bool Shuffle { get; set; }

        /**
        * The metadata of the current element.
        * 
        * If there is a current track, this must have a "mpris:trackid" entry
        * (of type ``ObjectPath``) at the very least, which contains a D-Bus
        * path that uniquely identifies this track.
        *
        * @see GLib.ObjectPath
        */
        public abstract HashTable<string, Variant> Metadata { owned get; }

        /**
        * The volume level.
        * 
        * When setting, if a negative value is passed, the volume should be set
        * to 0.0.
        * If ``CanControl`` is ``false``, attempting to set this property should
        * have no effect and raise an error.
        *
        * @see CanControl
        */
        public abstract double Volume { get; set; }

        /**
        * The current track position in microseconds, between 0 and the
        * 'mpris:length' metadata entry.
        * 
        * Note: If the media player allows it, the current playback position can
        * be changed either the ``SetPosition`` method or the ``Seek`` method on
        * this interface. If this is not the case, the ``CanSeek`` property is
        * ``false``, and setting this property has no effect and can raise an
        * error.
        * If the playback progresses in a way that is inconstistant with the
        * ``Rate`` property, the ``Seeked`` signal is emited.
        * 
        * @see CanSeek
        * @see Metadata
        * @see Seek
        * @see Seeked
        * @see SetPosition
        */
        public abstract int64 Position { get; set; }

        /**
        * The minimum value which the ``Rate`` property can take.
        * 
        * Clients should not attempt to set the ``Rate`` property below this
        * value.
        * Note that even if this value is 0.0 or negative, clients should not
        * attempt to set the ``Rate`` property to 0.0
        * This value should be always be 1.0 or less.
        * 
        * @see Rate
        */
        public abstract double MinimumRate { get; }

        /**
        * The maximum value which the ``Rate`` property can take.
        * 
        * Clients should not attempt to set the ``Rate`` property above this
        * value.
        * This value should be always be 1.0 or greater.
        * 
        * @see Rate
        */
        public abstract double MaximumRate { get; }
        public abstract bool CanGoNext { get; }
        public abstract bool CanGoPrevious { get; }
        public abstract bool CanPlay { get; }
        public abstract bool CanSeek { get; }
        public abstract bool CanControl { get; }
    }
}
