# Remote Control (Unreal)

- Default ports: HTTP 30010, WebSocket 30020.
- Start server: console command `WebControl.StartServer`.
- Stop server: `WebControl.StopServer`.
- Enable on startup: `WebControl.EnableServerOnStartup` if needed.
- Packaged builds require `-RCWebControlEnable -RCWebInterfaceEnable`.
- Do not expose Remote Control to the public internet.
- Key endpoint: `PUT /remote/object/call` for BlueprintCallable functions.
- Health endpoint: `GET /remote/info`.
