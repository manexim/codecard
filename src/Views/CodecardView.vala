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

    public Gtk.SourceView editor;

    public CodecardView (Models.Codecard model) {
        this.model = model;
        font = Application.instance.font;

        expand = true;

        get_style_context ().add_class (Gtk.STYLE_CLASS_VIEW);

        editor = new Gtk.SourceView.with_buffer (model.buffer) {
            wrap_mode = Gtk.WrapMode.WORD,
            margin = 40
        };
        add (editor);

        editor.map.connect (() => {
            editor.grab_focus ();
        });

        editor.override_font (Pango.FontDescription.from_string (font.font));
        font.notify.connect (() => {
            editor.override_font (Pango.FontDescription.from_string (font.font));
        });
    }
}
