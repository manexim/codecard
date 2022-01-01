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

public class Widgets.Overlay : Gtk.Overlay {
    private static Overlay? _instance;
    public Granite.Widgets.Toast toast;

    public static Overlay instance {
        get {
            if (_instance == null) {
                _instance = new Overlay ();
            }

            return _instance;
        }
    }

    private Overlay () {
        toast = new Granite.Widgets.Toast ("");
        add_overlay (toast);
    }

    public void show_toast (string message) {
        toast.title = message;
        toast.send_notification ();
    }

    public void hide_toast () {
        toast.reveal_child = false;
    }
}
