/*
 * Copyright (c) 2013 Mario Guerriero <mefrio.g@gmail.com>
 *               2017 elementary LLC. <https://elementary.io>
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public
 * License as published by the Free Software Foundation; either
 * version 3 of the License, or (at your option) any later version.
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
 */

namespace Utils {
    public string replace_home_with_tilde (string path) {
        var home_dir = Environment.get_home_dir ();
        if (path.has_prefix (home_dir)) {
            return "~" + path[home_dir.length:];
        } else {
            return path;
        }
    }

    public string get_codecard_folder () {
        return Path.build_filename (
            Environment.get_user_special_dir (UserDirectory.PICTURES),
            Constants.APP_NAME
        );
    }
}
