namespace org.freedesktop.portal {
    [DBus(name = "org.freedesktop.portal.Screenshot", timeout = 120000)]
    public interface Screenshot : Object { 
        [DBus(name = "Screenshot")]
        public abstract ObjectPath screenshot(string parent_window, HashTable<string, Variant> options) throws DBusError, IOError;
    }
}
