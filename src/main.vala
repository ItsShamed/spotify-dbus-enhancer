using SpotifyHook;
using SpotifyHook.Foreign;
using SpotifyHook.Listeners;

static LogWriterOutput logWriter(LogLevelFlags logLevel, LogField[] fields)
{
    if (logLevel > LogLevelFlags.LEVEL_INFO)
        return LogWriterOutput.HANDLED;

    if (Log.writer_is_journald(stdout.fileno()) ||
        Log.writer_is_journald(stderr.fileno()))
        Log.writer_journald(logLevel, fields);
    else
        Log.writer_standard_streams(logLevel, fields);

    return LogWriterOutput.HANDLED;
}

static void main()
{
    info("Setting up logging");
    Log.set_writer_func(logWriter);
    info("Test. This should now be visible without arguments.");
    MainLoop loop = new MainLoop();
    var listener = new SpotifyNotificationListener();
    listener.start.begin(null, (obj, res) => {
        try
        {
            listener.start.end(res);
            info("Listener started");
        }
        catch (IOError e)
        {
            loop.quit();
            error(@"Failed to start listener: %e.message");
        }
    });
    info("Running main loop");
    loop.run();
}
