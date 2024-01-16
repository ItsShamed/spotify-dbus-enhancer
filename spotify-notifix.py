#!/usr/bin/env python3

import gi.repository.GLib
import dbus
from dbus.mainloop.glib import DBusGMainLoop

notifier = None

def get_arg(message, n):
    arg_list = message.get_args_list()
    if len(arg_list) >= n + 1:
        return arg_list[n];
    else:
        return None

def create_notifier(bus):
    return dbus.Interface(bus.get_object("org.freedesktop.Notifications",
                                         "/org/freedesktop/Notifications"),
                                         "org.freedesktop.Notifications")

def get_mpris_object(bus):
    return bus.get_object('org.mpris.MediaPlayer2.spotify',
                          '/org/mpris/MediaPlayer2')

def get_player(obj):
    return dbus.Interface(obj, 'org.freedesktop.DBus.Properties')

def get_metadata(player):
    return player.Get("org.mpris.MediaPlayer2.Player", "Metadata")

def edit_notify(bus, message):
    appname = get_arg(message, 0)
    if appname != "Spotify":
        print("Notification is not related to spotify")
        return
    replace_id = get_arg(message, 1)
    icon = get_arg(message, 2)
    hints = get_arg(message, 6)
    if "tsrk_was_here" in hints:
        print("Notification already edited.")
        return
    else:
        hints["tsrk_was_here"] = dbus.Boolean(True)

    summary = "Now Playing"
    body = ""

    try:
        mpris = get_mpris_object(bus)
        player = get_player(mpris)
        meta = get_metadata(player)
        body = f"{', '.join(meta['xesam:artist'])} - {meta['xesam:title']}\n"
        body += f"<i>from {meta['xesam:album']} by <u>{', '.join(meta['xesam:albumArtist'])}</u></i>"
    except Exception as e:
        print("Failed to fetch spotify MPris player, probably not running.")
        print(e)
        return

    notifier.Notify(appname, replace_id, icon, summary, body, [], hints, 5000)
    print("Edited notification")

def notifications(bus, message):
    print("Notification received")
    try:
        edit_notify(bus, message)
    except Exception as e:
        print("uh oh:", e)


DBusGMainLoop(set_as_default=True)
bus = dbus.SessionBus()
bus.add_match_string_non_blocking("eavesdrop=true, interface='org.freedesktop.Notifications', member='Notify'")
bus.add_message_filter(notifications)
notifier = create_notifier(bus)

mainloop = gi.repository.GLib.MainLoop()
print("Running...")
mainloop.run()
