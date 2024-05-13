{ pkgs, ... }:
{
  programs.alacritty = {
    enable = true;

    settings = {
      colors = {
        bright = {
          black = "0x7f7f7f";
          blue = "0x5c5cff";
          cyan = "0x00ffff";
          green = "0x00ff00";
          magenta = "0xff00ff";
          red = "0xff0000";
          white = "0xffffff";
          yellow = "0xffff00";
        };
        normal = {
          black = "0x000000";
          blue = "0x0d73cc";
          cyan = "0x00cdcd";
          green = "0x00cd00";
          magenta = "0xcd00cd";
          red = "0xcd0000";
          white = "0xe5e5e5";
          yellow = "0xcdcd00";
        };
        primary = {
          background = "0x000000";
          foreground = "0xffffff";
        };
      };
      font = {
        size = 11;
        bold = { style = "Bold"; };
        glyph_offset = {
          x = 0;
          y = 0;
        };
        italic = { style = "Italic"; };
        normal = {
          family = "monospace";
          style = "Regular";
        };
        offset = {
          x = 0;
          y = 0;
        };
      };
      selection = {
        # save_to_clipboard = true;
        semantic_escape_chars = '',│`|:"' ()[]{}<>\t^'';
      };
      window = {
        decorations = "full";
        opacity = 0.9;
      };
    };
  };
}
