# zotero_linux_installer: Installer for Zotero standalone on Linux platforms.
**A simple tool to ease Zotero installation under Linux. Automating the strict minimum. Single script. Easy to maintain.**

## About
This is a modified fork from [smathot's script](https://github.com/smathot/zotero_installer) to
avoid automatic download from the official website.

Instead, the user can download and install the file he wants easily.
I found this solution a bit more stable along Zotero releases.

Also, this script does a better job a cleaning temporary data.

As previous work was released under the GPL v2 licence, I use the same
licence, while I am not really sure it makes really sense in my country…
So, make sure what this script does is right for you before running it.
And then do whatever you want with it.


## Licence
This script is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

## Usage
```shell
$ sudo /path/to/this/script /path/to/zotero-archive-from-official-website.tar.bz2
```

## Compatibility
Tested for:
- Zotero 4.0.x up to x = 20
- Zotero 5.0.x up to x = 66

## More details
- The default install location is under `/opt`. Just edit the script to change it.
- It removes the target directory automatically
- It creates a nice menu entry compatible with most desktop environments using [Freedesktop.org `.desktop` files](https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html).
