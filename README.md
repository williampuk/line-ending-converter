# line-ending-converter package

This is a very simple package that converts the line endings (or EOL's) to Unix/Windows/Old Mac format.

Tested with small text files on Windows 8 x64 platform.

## How to use

In Menu,
> Packages -> Line Ending Converter ->
>
> Convert To Unix Format, or Convert To Windows Format, or Convert to Old Mac Format

Or, in Command Palette (`cmd-shift-p` or `ctrl-shift-p`), type
> Convert To Unix Format, or Convert To Windows Format, or Convert to Old Mac Format

## Notes
The conversion works only when the file has at least one EOL. If the file does not have any EOL's, it would seem the conversion does not persist, as the current implementation of Atom would use a default EOL if there is no EOL found in the file.
