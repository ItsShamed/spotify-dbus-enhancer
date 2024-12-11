using SpotifyHook;
using SpotifyHook.Foreign;
using SpotifyHook.Listeners;

static void main()
{
    MainLoop loop = new MainLoop();
    var listener = new SpotifyNotificationListener();
    info("Hello world!");
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
