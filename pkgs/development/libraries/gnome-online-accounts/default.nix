{ stdenv
, fetchFromGitLab
, pkgconfig
, vala
, glib
, meson
, ninja
, python3
, libxslt
, gtk3
, webkitgtk
, json-glib
, librest
, libsecret
, gtk-doc
, gobject-introspection
, gettext
, icu
, glib-networking
, libsoup
, docbook_xsl
, docbook_xml_dtd_412
, gnome3
, gcr
, kerberos
, gvfs
, dbus
, wrapGAppsHook
}:

stdenv.mkDerivation rec {
  pname = "gnome-online-accounts";
  version = "3.35.90";

  # https://gitlab.gnome.org/GNOME/gnome-online-accounts/issues/87
  src = fetchFromGitLab {
    domain = "gitlab.gnome.org";
    owner = "GNOME";
    repo = "gnome-online-accounts";
    rev = version;
    sha256 = "0ls4k46gdnxw90gwmhz2a3i21vbf271fpj43j1kyyvjjdrb9yw4b";
  };

  outputs = [ "out" "man" "dev" "devdoc" ];

  mesonFlags = [
    "-Dfedora=false" # not useful in NixOS or for NixOS users.
    "-Dgtk_doc=true"
    "-Dlastfm=true"
    "-Dman=true"
    "-Dmedia_server=true"
  ];

  nativeBuildInputs = [
    dbus # used for checks and pkgconfig to install dbus service/s
    docbook_xml_dtd_412
    docbook_xsl
    gettext
    gobject-introspection
    gtk-doc
    libxslt
    meson
    ninja
    pkgconfig
    python3
    vala
    wrapGAppsHook
  ];

  buildInputs = [
    gcr
    glib
    glib-networking
    gtk3
    gvfs # OwnCloud, Google Drive
    icu
    json-glib
    kerberos
    librest
    libsecret
    libsoup
    webkitgtk
  ];

  NIX_CFLAGS_COMPILE = "-I${glib.dev}/include/gio-unix-2.0";

  postPatch = ''
    chmod +x meson_post_install.py
    patchShebangs meson_post_install.py
  '';

  passthru = {
    updateScript = gnome3.updateScript {
      packageName = pname;
      attrPath = "gnome3.${pname}";
    };
  };

  meta = with stdenv.lib; {
    homepage = "https://wiki.gnome.org/Projects/GnomeOnlineAccounts";
    description = "Single sign-on framework for GNOME";
    platforms = platforms.linux;
    license = licenses.lgpl2Plus;
    maintainers = gnome3.maintainers;
  };
}
