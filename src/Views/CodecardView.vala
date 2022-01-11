/*
 * Copyright (c) 2019-2022 Manexim (https://github.com/manexim)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public
 * License along with this program; if not, write to the
 * Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
 * Boston, MA 02110-1301 USA
 *
 * Authored by: Marius Meisenzahl <mariusmeisenzahl@gmail.com>
 */

public class Views.CodecardView : Gtk.ScrolledWindow {
    private Models.Codecard model;
    private Models.Font font;

    public Gtk.SourceStyleSchemeManager style_scheme_manager;
    public Gtk.SourceView editor;

    private const string STYLE_SCHEME_LIGHT = "solarized-light";
    private const string STYLE_SCHEME_DARK = "solarized-dark";

    public string background_color { get; private set; }
    public int editor_margin { get; default = 16; }

    public CodecardView (Models.Codecard model) {
        this.model = model;
        font = Application.instance.font;

        expand = true;
        style_scheme_manager = new Gtk.SourceStyleSchemeManager ();

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        editor = new Gtk.SourceView.with_buffer (model.buffer) {
            wrap_mode = Gtk.WrapMode.WORD,
            margin = editor_margin
        };
        add (editor);

        editor.map.connect (() => {
            editor.grab_focus ();
        });

        editor.override_font (Pango.FontDescription.from_string (font.font));
        font.notify.connect (() => {
            editor.override_font (Pango.FontDescription.from_string (font.font));
        });

        Granite.Settings.get_default ().notify["prefers-color-scheme"].connect (() => {
            update_style_scheme ();
        });

        update_style_scheme ();
    }

    private void update_style_scheme () {
        var prefers_dark = Granite.Settings.get_default ().prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        var scheme_name = prefers_dark ? STYLE_SCHEME_DARK : STYLE_SCHEME_LIGHT;
        var scheme = style_scheme_manager.get_scheme (scheme_name);
        model.buffer.style_scheme = scheme;

        string background = "#FFF";
        var text_style = scheme.get_style ("text");

        if (text_style != null && text_style.background_set && !("rgba" in text_style.background)) {
            background = text_style.background;
            background_color = background;
        }

        var style_css = """
            scrolledwindow {
                background-color: %s;
            }
        """.printf (background);

        var css_provider = new Gtk.CssProvider ();

        try {
            css_provider.load_from_data (style_css);
        } catch (Error e) {
            critical ("Unable to style background: %s", e.message);
        }

        unowned var style_context = get_style_context ();
        style_context.add_provider (css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);
    }
}
