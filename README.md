### Notice
This package is no longer maintained since there is an official package (preinstalled with Atom) that enables line endings operations. You should uninstall this package to avoid any conflicts.

##### Line Ending Converter package [![Build Status](https://travis-ci.org/williampuk/line-ending-converter.svg)](https://travis-ci.org/williampuk/line-ending-converter)

##### Features
- Show the line ending (EOL) format of the current file in the status bar (see the note below for details)
- Convert the line endings to Unix/Windows/Old Mac format.

##### How to use
##### Status View Display:
It is enabled by default. You can disable it in the package setting.

**Notes:** The EOL format being shown is the EOL format of the first row of the file. It cannot detect if the file is having inconsistent EOL formats.

##### Perform conversion:
Status View,
> Click the status view to open the list for conversion

Or, in Menu,
> `Packages` -> `Convert Line Endings To` -> `Unix Format` / `Windows Format` / `Old Mac Format`

Or, in Context Menu (inside an active editor),
> `Convert Line Endings To` ->
> `Unix Format` / `Windows Format` / `Old Mac Format`

Or, in Command Palette (`cmd-shift-p` or `ctrl-shift-p`), type
> `Convert To Unix Format`, or `Convert To Windows Format`, or `Convert to Old Mac Format`

(Note: This will convert the line endings of the text in the active editor.)

**Notes:** The conversion works only when the file has at least one EOL symbol. If the file does not have any EOL symbols, the conversion would not persist, as the current implementation of Atom uses a default EOL (which appears to be the UNIX format) if there is no EOL symbol found in the file.

You can try to use the **experimental** feature "Normalize On Save" if you really need to have a consistent line ending across all files.
