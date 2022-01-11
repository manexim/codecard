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

public class MainWindow : Hdy.Window {
    private Services.Settings settings;
    private Hdy.HeaderBar headerbar;
    private Controllers.CodecardController codecard;
    private Gtk.ComboBoxText languages_combo;

    private bool saving = false;

    public Application app { get; construct; }

    public SimpleActionGroup actions { get; construct; }

    public const string ACTION_PREFIX = "win.";
    public const string ACTION_SAVE = "action-save";
    public const string ACTION_QUIT = "action-quit";
    public const string ACTION_FULLSCREEN = "action-fullscreen";
    public const string ACTION_ZOOM_OUT_FONT = "action-zoom-out-font";
    public const string ACTION_ZOOM_DEFAULT_FONT = "action-zoom-default-font";
    public const string ACTION_ZOOM_IN_FONT = "action-zoom-in-font";

    private static Gee.MultiMap<string, string> action_accelerators = new Gee.HashMultiMap<string, string> ();

    private const ActionEntry[] ACTION_ENTRIES = {
        { ACTION_SAVE, action_save },
        { ACTION_QUIT, action_quit },
        { ACTION_FULLSCREEN, action_fullscreen },
        { ACTION_ZOOM_OUT_FONT, action_zoom_out_font },
        { ACTION_ZOOM_DEFAULT_FONT, action_zoom_default_font },
        { ACTION_ZOOM_IN_FONT, action_zoom_in_font }
    };

    public MainWindow (Application app) {
        Object (
            app: app
        );
    }

    static construct {
        action_accelerators[ACTION_SAVE] = "<Control>s";
        action_accelerators[ACTION_QUIT] = "<Control>q";
        action_accelerators[ACTION_QUIT] = "<Control>w";
        action_accelerators[ACTION_FULLSCREEN] = "F11";
        action_accelerators[ACTION_ZOOM_OUT_FONT] = "<Control>minus";
        action_accelerators[ACTION_ZOOM_OUT_FONT] = "<Control>KP_Subtract";
        action_accelerators[ACTION_ZOOM_DEFAULT_FONT] = "<Control>0";
        action_accelerators[ACTION_ZOOM_DEFAULT_FONT] = "<Control>KP_0";
        action_accelerators[ACTION_ZOOM_IN_FONT] = "<Control>plus";
        action_accelerators[ACTION_ZOOM_IN_FONT] = "<Control>equal";
        action_accelerators[ACTION_ZOOM_IN_FONT] = "<Control>KP_Add";
    }

    construct {
        Hdy.init ();

        actions = new SimpleActionGroup ();
        actions.add_action_entries (ACTION_ENTRIES, this);
        insert_action_group ("win", actions);

        set_application (app);
        set_title (Constants.APP_NAME);

        foreach (var action in action_accelerators.get_keys ()) {
            var accels_array = action_accelerators[action].to_array ();
            accels_array += null;

            app.set_accels_for_action (ACTION_PREFIX + action, accels_array);
        }

        settings = Services.Settings.get_default ();
        load_settings ();

        codecard = new Controllers.CodecardController ();

        headerbar = new Hdy.HeaderBar () {
            decoration_layout = "close:",
            show_close_button = true,
            title = Constants.APP_NAME
        };

        var save_button = new Gtk.Button.from_icon_name ("document-save", Gtk.IconSize.LARGE_TOOLBAR) {
            action_name = ACTION_PREFIX + ACTION_SAVE,
            tooltip_markup = Granite.markup_accel_tooltip (
                application.get_accels_for_action (ACTION_PREFIX + ACTION_SAVE),
                _("Save")
            )
        };

        headerbar.pack_start (save_button);

        languages_combo = new Gtk.ComboBoxText () {
            tooltip_text = _("Language")
        };
        languages_combo.changed.connect (() => {
            var source_language_manager = Gtk.SourceLanguageManager.get_default ();
            var language = source_language_manager.get_language (languages_combo.active_id);
            codecard.model.buffer.set_language (language);
        });

        languages_combo.append ("sh", "Bash");
        languages_combo.append ("c", "C");
        languages_combo.append ("cpp", "C++");
        languages_combo.append ("js", "JavaScript");
        languages_combo.append ("python3", "Python");
        languages_combo.append ("vala", "Vala");
        languages_combo.active_id = settings.language;

        var zoom_out_button = new Gtk.Button.from_icon_name ("zoom-out-symbolic", Gtk.IconSize.MENU) {
            action_name = ACTION_PREFIX + ACTION_ZOOM_OUT_FONT,
            tooltip_markup = Granite.markup_accel_tooltip (
                application.get_accels_for_action (ACTION_PREFIX + ACTION_ZOOM_OUT_FONT),
                _("Zoom out")
            )
        };

        var zoom_default_button = new Gtk.Button.with_label ("%d%%".printf (settings.zoom)) {
            action_name = ACTION_PREFIX + ACTION_ZOOM_DEFAULT_FONT,
            tooltip_markup = Granite.markup_accel_tooltip (
                application.get_accels_for_action (ACTION_PREFIX + ACTION_ZOOM_DEFAULT_FONT),
                _("Default zoom level")
            )
        };

        settings.notify["zoom"].connect (() => {
            zoom_default_button.label = "%d%%".printf (settings.zoom);
        });

        var zoom_in_button = new Gtk.Button.from_icon_name ("zoom-in-symbolic", Gtk.IconSize.MENU) {
            action_name = ACTION_PREFIX + ACTION_ZOOM_IN_FONT,
            tooltip_markup = Granite.markup_accel_tooltip (
                application.get_accels_for_action (ACTION_PREFIX + ACTION_ZOOM_IN_FONT),
                _("Zoom in")
            )
        };

        var font_size_grid = new Gtk.Grid () {
            column_homogeneous = true,
            hexpand = true,
            margin = 12
        };
        font_size_grid.get_style_context ().add_class (Gtk.STYLE_CLASS_LINKED);
        font_size_grid.add (zoom_out_button);
        font_size_grid.add (zoom_default_button);
        font_size_grid.add (zoom_in_button);

        var menu_grid = new Gtk.Grid () {
            margin_bottom = 3,
            orientation = Gtk.Orientation.VERTICAL,
            width_request = 200
        };
        menu_grid.attach (font_size_grid, 0, 0, 3, 1);
        menu_grid.show_all ();

        var menu = new Gtk.Popover (null);
        menu.add (menu_grid);

        var app_menu = new Gtk.MenuButton () {
            image = new Gtk.Image.from_icon_name ("open-menu", Gtk.IconSize.LARGE_TOOLBAR),
            tooltip_text = _("Menu"),
            popover = menu
        };

        headerbar.pack_end (app_menu);
        headerbar.pack_end (languages_combo);

        var main_layout = new Gtk.Grid ();
        main_layout.attach (headerbar, 0, 0);
        main_layout.attach (codecard.view, 0, 1);

        add (main_layout);

        delete_event.connect (() => {
            save_settings ();
            codecard.save ();

            return false;
        });
    }

    private void load_settings () {
        if (settings.window_fullscreen) {
            fullscreen ();
        }

        if (settings.window_maximized) {
            maximize ();
            set_default_size (settings.window_width, settings.window_height);
        } else {
            set_default_size (settings.window_width, settings.window_height);
        }

        if (settings.window_x < 0 || settings.window_y < 0 ) {
            window_position = Gtk.WindowPosition.CENTER;
        } else {
            move (settings.window_x, settings.window_y);
        }
    }

    private void save_settings () {
        settings.language = languages_combo.active_id;
        settings.window_maximized = is_maximized;

        if (!(settings.window_maximized || settings.window_fullscreen)) {
            int x, y;
            get_position (out x, out y);
            settings.window_x = x;
            settings.window_y = y;

            int width, height;
            get_size (out width, out height);
            settings.window_width = width;
            settings.window_height = height;
        }
    }

    private bool is_fullscreen {
        get {
            return settings.window_fullscreen;
        }
        set {
            settings.window_fullscreen = value;

            if (settings.window_fullscreen) {
                fullscreen ();
            } else {
                unfullscreen ();
            }
        }
    }

    private void action_save () {
        if (saving) {
            return;
        }

        saving = true;

        codecard.view.editor.cursor_visible = false;
        codecard.view.editor.editable = false;

        Timeout.add_seconds (1, () => {
            var window = codecard.view.editor.get_window (Gtk.TextWindowType.WIDGET);
            int width = window.get_width ();
            int height = window.get_height ();

            try {
                var pixbuf = Gdk.pixbuf_get_from_window (window, 0, 0, width, height);

                if (pixbuf != null) {
                    double margin = codecard.view.editor_margin;
                    const double BORDER_RADIUS = 8.0;

                    var surface = new Cairo.ImageSurface (Cairo.Format.ARGB32, (int) (width + margin * 4), (int) (height + margin * 4));
                    var context = new Cairo.Context (surface);
                    var view_surface = Gdk.cairo_surface_create_from_pixbuf (pixbuf, 1, null);

                    var background_color = Gdk.RGBA ();
                    background_color.parse (codecard.view.background_color);

                    context.set_source_rgba (background_color.red, background_color.green, background_color.blue, 1);

                    double w = width + margin * 2;
                    double h = height + margin * 2;
                    double x = margin;
                    double y = margin;

                    double degrees = Math.PI / 180.0;

                    context.new_sub_path ();
                    context.arc (x + w - BORDER_RADIUS, y + BORDER_RADIUS, BORDER_RADIUS, -90 * degrees, 0 * degrees);
                    context.arc (x + w - BORDER_RADIUS, y + h - BORDER_RADIUS, BORDER_RADIUS, 0 * degrees, 90 * degrees);
                    context.arc (x + BORDER_RADIUS, y + h - BORDER_RADIUS, BORDER_RADIUS, 90 * degrees, 180 * degrees);
                    context.arc (x + BORDER_RADIUS, y + BORDER_RADIUS, BORDER_RADIUS, 180 * degrees, 270 * degrees);
                    context.close_path ();

                    context.fill ();

                    context.set_operator (Cairo.Operator.OVER);
                    context.set_source_surface (view_surface, margin * 2, margin * 2);
                    context.paint ();

                    var date_time = new GLib.DateTime.now_local ().format ("%Y-%m-%d %H.%M.%S");
                    string file_name = "Codecard from %s.png".printf (date_time);
                    var path = Utils.get_codecard_folder ();
                    if (DirUtils.create_with_parents (path, 0755) != 0) {
                        throw new FileError.FAILED ("");
                    }

                    path = Path.build_filename (path, file_name);

                    if (surface.write_to_png (path) != Cairo.Status.SUCCESS) {
                        throw new FileError.FAILED ("");
                    }

                    var exported_pixbuf = new Gdk.Pixbuf.from_file (path);
                    Gtk.Clipboard.get_default (get_display ()).set_image (exported_pixbuf);

                    var notification = new Notification (title);
                    notification.set_body (_("Saved to %s and copied to clipboard").printf (Utils.replace_home_with_tilde (path)));
                    notification.set_default_action ("app.show-codecard-folder");
                    app.send_notification (Constants.APP_ID, notification);
                } else {
                    throw new FileError.FAILED ("");
                }
            } catch (Error e) {
                show_error_dialog ("Could not save Codecard");
            }

            codecard.view.editor.cursor_visible = true;
            codecard.view.editor.editable = true;

            saving = false;

            return Source.REMOVE;
        });
    }

    private void action_quit () {
        destroy ();
    }

    private void action_fullscreen () {
        is_fullscreen = !is_fullscreen;
    }

    private void action_zoom_out_font () {
        if (settings.zoom >= 30) {
            settings.zoom -= 10;
        } else {
            Gdk.beep ();
        }
    }

    private void action_zoom_default_font () {
        if (settings.zoom != 100) {
            settings.zoom = 100;
        } else {
            Gdk.beep ();
        }
    }

    private void action_zoom_in_font () {
        if (settings.zoom < 400) {
            settings.zoom += 10;
        } else {
            Gdk.beep ();
        }
    }

    private void show_error_dialog (string error_message) {
        var dialog = new Granite.MessageDialog.with_image_from_icon_name (
             _("Could not capture screenshot"),
             _("Codecard not saved"),
             "dialog-error",
             Gtk.ButtonsType.CLOSE
        );
        dialog.show_error_details (error_message);

        dialog.run ();
        dialog.destroy ();
    }
}
