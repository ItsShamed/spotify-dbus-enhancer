using SpotifyHook;

static void main()
{
    MainLoop loop = new MainLoop();
    var listener = new BasicMessageListener("eavesdrop=true");
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
