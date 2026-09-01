my: {
  Preferences = {
    hister."config.yml" = ''
      server:
        address: 127.0.0.1:4433
        base_url: https://macbook-air.snakebird-roach.ts.net
    '';
  };

  LaunchAgents =
    # These have to be loaded and unloaded manually for the current session.
    # E.g. via `launchctl load ~/Library/LaunchAgents/[...]`.
    with (
      let
        make = type: name: script: {
          "${name}.plist" = ''
            <?xml version="1.0" encoding="utf-8"?>
            <plist version="1.0">
              <dict>
                <key>Label</key>
                <string>${my.lib.escapeXML name}</string>

                ${
                  {
                    service = ''
                      <key>KeepAlive</key><true/>
                    '';
                    oneshot = ''
                      <key>RunAtLoad</key><true/>
                    '';
                  }.${type}
                }

                <key>ProgramArguments</key>
                <array>
                  <string>/usr/local/bin/fish</string>
                  <string>-l</string>
                  <string>-c</string>
                  <string>
                    ${my.lib.escapeXML script}
                  </string>
                </array>
              </dict>
            </plist>
          '';
        };
      in my.lib.genAttrs [ "service" "oneshot" ] make
    );
    {}
    // service "alurm.hister" ''
      exec ${my.pkgs.hister}/bin/hister listen
    ''
    
    # # "Remapping Keys in macOS 10.12 Sierra".
    # # https://developer.apple.com/library/archive/technotes/tn2450/_index.html
    # # `hidutil` accepts hexadecimal integers.
    # # Map the right command key to the left control key.
    # // oneshot "alurm.keyboard.mappings" ''
    #   /usr/bin/hidutil property --set '{
    #     "UserKeyMapping": [
    #       {
    #         "HIDKeyboardModifierMappingSrc": 0x7000000E7,
    #         "HIDKeyboardModifierMappingDst": 0x7000000E0
    #       }
    #     ]
    #   }'
    # ''
   
    # Legacy code.
    #
    # // make-service {
    #   name = "alurm.webdav";
    #   script = ''
    #     cd ~/Desktop/Syncthing &&
    #     exec rclone serve webdav .
    #   '';
    # }
    # // make-service {
    #   name = "alurm.tiddlywiki.main";
    #   script = ''
    #     cd ~/Desktop/Syncthing/TiddlyWikis/Main &&
    #     exec \
    #     ${pkgs.tiddlywiki}/bin/tiddlywiki \
    #     --listen port=8080 host=127.0.0.1
    #   '';
    # }
    ;
}
