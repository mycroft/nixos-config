{ pkgs, ... }:
{
  programs.tmux = {
    enable = true;
    shortcut = "a";
    baseIndex = 1;
    historyLimit = 100000;

    extraConfig = ''
      # Reload configuration: ctrl+a :source-file ~/.tmux.conf or tmux source-file ~/.tmux.conf
      #
      # See
      # http://mutelight.org/articles/practical-tmux
      # http://www.openbsd.org/faq/faq7.html#tmux
      # http://blog.hawkhost.com/2010/06/28/tmux-the-terminal-multiplexer/

      # Personal configuration
      set -g status-bg white
      set -g status-left-length 32
      set -g status-left "[#[fg=red]#(whoami)@#(hostname)#[default]] ~ "
      set -g status-right "[#(cut -d' ' -f 1,2 /proc/loadavg|sed -e 's/ /~/')%#(who|awk '{print $1}'|sort|uniq|wc -l) usr][#[fg=green]%H:%M#[default]]"

      set -g default-terminal "tmux-256color"
      set -ga terminal-overrides ",alacritty:Tc"

      set -g set-titles on
      set -g set-titles-string "#T"

      set-option -g update-environment "DISPLAY WAYLAND_DISPLAY"

      # End of personal configuration
    '';
  };
}

