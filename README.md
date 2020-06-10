I'd like to apologize in advance for the quite frankly crappy code. I had no prior experience in writing server code prior to this project.

# ScribbleasyServer
Buggy unoptimized garbage that barely works and throws an exception every other startup.
Used for hosting servers for Scribbleasy clients to connect to.

## Disclaimers
- This thing is really buggy, don't be surprised if it crashes every 30 minutes
- It's also very unoptimized. It takes an entire Ryzen CPU core and about 300MB of RAM to run one board session at full load.
- There is no DDOS protection or spam filtering. A user may crash the server by repeatedly sending board refresh requests.

## How to use
**Make sure you fill every single input box correctly. The application does not handle missing or incorrect input well (or at all)**
1. IP: Fill with your current LAN IP (Windows users: see ipconfig, Android users: look at Wi-Fi settings, Linux users: you know what you're doing)
2. Port: Use any port that is not already used by something else. Don't forget to port forward in your router settings.
3. Click Start Server
4. When done hosting, click Stop and exit. If the app refuses to close, don't hesitate to force close it using pkill -9 or the task manager or whatever.
