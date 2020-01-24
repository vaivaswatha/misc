## A list of useful Emacs shortcuts

On PCs <kbd>M</kbd> maps to the <kbd>alt</kbd> key and 
<kbd>C</kbd> to the <kbd>ctrl</kbd> key.

- <kbd>M-x</kbd> For entering commands (gdb, shell, compile etc)
- <kbd>C-g</kbd> abort a command
- <kbd>C-x C-s</kbd> Save buffer
- <kbd>C-x C-w</kbd> Save as
- <kbd>C-x C-c</kbd> Exit emacs
- <kbd>C-x 1</kbd> Show only single buffer, (full window)
- <kbd>C-x 2</kbd> Split window to show two buffers (horizontal)
- <kbd>C-x 3</kbd> Split window into two vertical buffers
- <kbd>C-x k</kbd> Kill current buffer
- <kbd>C-x 0</kbd> Kill window (not buffer)
- <kbd>C-x o</kbd> Activate other window
- <kbd>C-x -></kbd> Next window (or buffer)
- <kbd>C-x <-</kbd> Previous window (or buffer). (<kbd>-></kbd> and <kbd><-</kbd> are the arrow keys)
- <kbd>C-Shift-_</kbd> Undo
- <kbd>C-space</kbd> Start selection. (use arrow keys to go to end of selection)
- <kbd>C-space-space</kbd> Start selection (shows the selection also - Transient Selection).
- <kbd>C-w</kbd> Cut (delete) selected text
- <kbd>M-w</kbd> Copy selection
- <kbd>C-y</kbd> Paste
- <kbd>M-;</kbd> Start a comment or comment the selected text
- <kbd>M-$</kbd> Check current word (on which cursor is present) with iSpell
- <kbd>C-x d</kbd> Open directory
- <kbd>C-x C-f</kbd> Open or create file
- <kbd>C-q tab</kbd> Force tab
- <kbd>M-!</kbd> Execute shell command
- <kbd>M-/</kbd> Complete word
- <kbd>F10</kbd> Menu.
- <kbd>M-g M-g</kbd> Goto specific line
- <kbd>M-<</kbd> Goto beginning of file
- <kbd>M-></kbd> Goto end of file
- <kbd>C-x s</kbd> Save all buffers
- <kbd>C-k</kbd> Delete current line
- <kbd>C-l</kbd> Reposition screen for current line
- <kbd>C-s</kbd> Search for a pattern. Can you repeatedly to continue search.
- <kbd>C-r</kbd> Search for a pattern in the backward direction. Can you repeatedly to continue search
- <kbd>M-.</kbd> Find symbol in [TAGS](https://github.com/vaivaswatha/misc/blob/master/CCppCLIDev.md).
- <kbd>C-M-,</kbd> Go to previous marked position. Useful when you want to go back after 
    following up a symbol definition with <kbd>M-.</kbd>
- <kbd>C-x C-x</kbd> Goto previous cursor position (that was marked with a C^space or other means)
- <kbd>C-c C-z</kbd> Open interactive python interpreter
- <kbd>M-n</kbd> When viewing a .diff file, go to the next diff
- <kbd>M-p</kbd> When viewing a .diff file, go to the previous diff
- <kbd>C-c ! l</kbd> List all flycheck errors
- <kbd>C-c ! n</kbd> Next flycheck error
- <kbd>C-c C-t</kbd> Show type of variable (in OCaml merlin mode)
- Replace string: Hit <kbd>M-x</kbd> and type command "replace-string" hit ENTER. Can also do "query-replace" to do an interactive replace.
- Find matching braces:	Hit M-x and type "forward-sexp" or "backward-sexp". Cursor should be at the right braces.
- ediff-buffers: Hit <kbd>M-x</kbd> and type "ediff-buffers". Its a visual diff tool.

- `emacs -nw` Opens emacs in non-X mode. (can be done by unsetting `$DISPLAY` also).

