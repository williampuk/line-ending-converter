# Line Ending Converter package

This is a very simple package that converts the line endings (or EOL's) to Unix/Windows/Old Mac format.

## How to use

In Menu,
> Packages => Convert Line Endings To =>
>
> Unix Format / Windows Format / Old Mac Format

Or, in Context Menu (inside an active editor),
> `Line Endings: To Unix` / `Line Endings: To Windows` /
> `Line Endings: To Old Mac`

Or, in Command Palette (`cmd-shift-p` or `ctrl-shift-p`), type
> Convert To Unix Format, or Convert To Windows Format, or Convert to Old Mac Format
>
> (Note: This will convert the line endings of the text in the active editor, regardless of where the command is triggered.)

## Notes
The conversion works only when the file has at least one EOL. If the file does not have any EOL's, the conversion would not persist, as the current implementation of Atom uses a default EOL (which appears to be the UNIX format) if there is no EOL found in the file.
