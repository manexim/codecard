namespace org.freedesktop.portal {
    [DBus(name = "org.freedesktop.portal.Request", timeout = 120000)]
    public interface Request : Object {  
        [DBus(name = "Close")]
        public abstract void close() throws DBusError, IOError;

        [DBus(name = "Response")]
        public signal void response(uint response, HashTable<string, Variant> results);
    }
}
