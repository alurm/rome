tiddlypwa: {
  pkgs,
  lib,
  config,
  ...
}: {
  systemd.services.tiddlypwa = {
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "tiddlypwa";
      RuntimeDirectory = "tiddlypwa";
      WorkingDirectory = "/var/lib/tiddlypwa";
      Restart = "on-failure";
      RestartSec = "5s";
    };

    script = ''
      DENO_DIR=deno \
      exec ${pkgs.deno}/bin/deno run \
      --frozen \
      --allow-env \
      --allow-read=".,$RUNTIME_DIRECTORY" \
      --allow-write=".,$RUNTIME_DIRECTORY" \
      ${tiddlypwa}/server/run.ts \
      --db tiddly.db \
      --socket "$RUNTIME_DIRECTORY/http.sock" \
      ;
    '';
  };

  environment.etc."tiddlypwa.html".text = ''
    <!doctype html>
    <meta http-equiv="refresh" content="0; url=${lib.escapeXML config.tiddlypwa.url}">
  '';
}
