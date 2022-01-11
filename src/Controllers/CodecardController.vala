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

public class Controllers.CodecardController {
    private Services.Settings settings;

    public Models.Codecard model;
    public Views.CodecardView view;

    public CodecardController () {
        settings = Services.Settings.get_default ();

        model = new Models.Codecard ();
        load ();

        view = new Views.CodecardView (model);

        model.notify.connect (save);
    }

    public void save () {
        if (settings.autosave) {
            try {
                if (!model.directory.query_exists ()) {
                    model.directory.make_directory_with_parents ();
                }

                FileUtils.set_contents (model.file.get_path (), model.buffer.text);
            } catch (Error e) {
                stderr.printf ("Could not autosave: %s\n", e.message);
            }
        }
    }

    public void load () {
        var file = new Gtk.SourceFile () {
            location = model.file
        };

        if (file != null) {
            var file_saver = new Gtk.SourceFileLoader (model.buffer as Gtk.SourceBuffer, file);
            file_saver.load_async.begin (Priority.DEFAULT, null, null);
        }
    }
}
