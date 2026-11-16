pkgs: (pkgs.writeShellApplication {
  name = "be-awake-until-lid-opens";
  text = ''
    [ "$(id -u)" = 0 ] || exec sudo "$0" "$@"

    trap 'pmset -a disablesleep 0' 0
    trap exit hup int term quit

    pmset -a disablesleep 1

    lid_is_closed() {
      ioreg -r -k AppleClamshellState -d 4 |
      grep -q '"AppleClamshellState" = Yes'
    }

    while ! lid_is_closed; do sleep 1; done
    while lid_is_closed; do sleep 1; done
  '';
  bashOptions = [ "errexit" "nounset" ];
})
