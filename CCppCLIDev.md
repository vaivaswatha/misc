# C / C++ Development on the Command Line

With modern IDEs like Visual Studio Code, you seldom need to develop applications on the
command line. Nevertheless it is a usefull skill to have and this article provides a
fast setup for development on a command line only interface.

The article focuses on using Emacs (for which I have a keyboard shortcuts reference
[here](https://github.com/vaivaswatha/misc/blob/master/EmacsReference.md)).
Many parts of the article should work well for Vim too.

## Preparation
You will need the following OS packages:
  - `sudo apt-get install emacs cscope exuberant-ctags libclang-dev build-essentials cmake`

### Emacs packages
Add the following lines to your `~/.emacs` file to have the MELPA repository
accessible and to install packages from it.
```lisp
;; MELPA
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
;; Run package-refresh-contents to fetch latest list of packages.
;; Run package-install to install a package
```

Open emacs and install the following MELPA packages by running 
  - <kbd>M-x</kbd> `package-referesh-contents`
  - <kbd>M-x</kbd> `package-install irony`
  - <kbd>M-x</kbd> `package-install flycheck-irony`
  - <kbd>M-x</kbd> `package-install company-irony`

## Code browsing with Cscope and TAGS
You can run the following set of commands (to be put in a script for easy invocation) to build symbol databases for Cscope and TAGS. Two files `cscope.out` and `TAGS` are produced.

  * `$ctags -eR`
  * `$cscope -bR`

The `-e` option to `ctags` specifies producing `TAGS` for Emacs. It can be
skipped if you want to build `TAGS` for Vim. I suggest adding `TAGS` and
`cscope.out` to the `.gitignore` file of your project (or `~/.gitignore`).
You may also add these commands to your `Makefile` to keep the tags updated.

### Code browsing with Cscope
Once you have a Cscope database (`cscope.out`) in your project directory, you
can run `$cscope -d` to start the Cscope program. You can do plenty of queries
there such as find definitions, references, includes etc. You can also pipe
the output of your queries to command such as `grep` to filter, by hitting `|`
once you get an output and typing the command.

### Emacs and TAGS
By default, Emacs knows to look for the TAGS file only in the directory of the
open file. Most often this is not good enough as your project may have a hierarchy
of directories with the TAGS file generated at the project root. To enable Emacs
to search in the parent directories of a file for the TAGS file, you must use
the code in [etags-search.el](https://www.emacswiki.org/emacs/EtagsSelect#toc2).
Similarly, when a symbol has multiple definitions, to enable Emacs to provide
you a user-friendly menu to select the right one, I suggest using
[etags-select.el](https://www.emacswiki.org/emacs/etags-select.el).

  * Download `etags-select.el` to `~/.emacs.d/`
  * Copy the above `etags-search.el` code and place it in a file 
    `etags-search.el` in `~/.emacs.d/`
  * Edit `~/.emacs.d/etags-search.el` to fix the path to `etags-select.el`.
  * Add the following line into your `~/.emacs`. Use absolute path if it
    doesn't work with `~/`. 
    ``` lisp
    (load-file "~/emacs.d/etags-search.el")
    ```

You can now type <kbd>M-?</kbd> on any symbol in your program (or alternatively specify
it by typing <kbd>M-.</kbd> and typing in the symbol) and hit enter. If there is only
a single definition, you will be taken there directly. Otherwise, you'll get
a menu of possible targets. By typing in the number, you'll be taken there.

## Debugging with Emacs
One of the most useful features of Emacs is its integration with GDB. Even with
most of my development happening today on vscode, I fall back to Emacs for debugging.
It gives you control over GDB by allowing you to natively type GDB commands, but
at the same time providing all the other visual UI features that a modern IDE provides.

Just type <kbd>M-x</kbd> (the shortcut for entering Emacs commands) and type `gdb`. Edit
the default arguments (if necessary) and press enter. You'll automatically start GDB
with all the fancy UI on.

## Error checking
As you type in code, Emacs can check syntax and semantic errors (that would be thrown
when you compile the file) automatically and mark them (error squiggles) in the buffer.

For this feature to work, you will need the `irony` and `flycheck-irony` Emacs packages
(already installed if you followed the preparation instructions above). `irony` requires
that the `irony-server` be built locally. This is a one-time task and can be done as
follows (inside Emacs).

  - <kbd>M-x</kbd> `irony-install-server`

Add the following lines to your `~/.emacs` file to automatically enable `flycheck-irony`
on any C/C++ files that you open.

```lisp
;; irony-mode. requires irony and flycheck-irony emacs packages and libclang-dev ubuntu package.
(add-hook 'c++-mode-hook 'irony-mode)
(add-hook 'c-mode-hook 'irony-mode)
(add-hook 'objc-mode-hook 'irony-mode)
;; For figuring out compile commands from compile_commands.json or .clang_complete databases.
;; If doesn't work (can't find the databases), use irony-cdb-json-add-compile-commands-path.
(add-hook 'irony-mode-hook 'irony-cdb-autosetup-compile-options)
(add-hook 'c++-mode-hook 'flycheck-mode)
(add-hook 'c-mode-hook 'flycheck-mode)
(add-hook 'irony-mode-hook (lambda () (local-set-key (kbd "C-c C-t") 'irony-get-type)))
(eval-after-load 'flycheck
  '(add-hook 'flycheck-mode-hook #'flycheck-irony-setup))
```

While errors are marked on the fly, the following keyboard shortcuts are useful:
  - <kbd>C-C C-t</kbd> Display the type of the symbol on which the cursor currently is
  - <kbd>C-c ! l</kbd> Display list of errors and warnings
  - <kbd>C-c ! n</kbd> Next error / warnings
  - <kbd>C-c ! p</kbd> Previous error / warning

### Compilation database
Except for trivial programs, C/C++ files often have a complex compiler invocation command
line (such as specifying include directories, language version etc). Without the
knowledge of this, `flycheck` may end up marking false errors. `irony-flycheck` supports
two ways to specify the compilation command that can be used for running the error checker.

  - `compile_commands.json`: This is a [compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) 
  specifying the command line to be used to compile each file in your project. It can
  be generated in multiple ways, couple of which I convey here.
    * If you're using `CMake` in your project 
      * Add this line to your project's `CMakeLists.txt`.
        ```cmake
        set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
        ```
      * Alternatively, you can specify `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON` when you invoke `cmake` to setup your project.
    * If you don't use `CMake` in your program but use a simple `Makefile`, you can use
    [compiledb](https://github.com/nickdiego/compiledb). Install `compiledb` using
    `pip` as `pip install compiledb`. You can then run `compiledb make` instead of `make`. Any arguments you provid to `make` can still be given. `compiledb` will
    intercept every compilation done by `make` and add it to the compilation database.
    * You can also try https://github.com/rizsotto/Bear
  - `.clang_complete` or `compile_flags.txt`. For small projects where all of your source
  files use the same compilation command, they can all be specified once in a file
  `.clang_complete` or `compile_flags.txt` in the root of your project. Add each
  compilation flag in a separate line. Here's an example.
    ```
    -std=c++1
    -Ipath/to/include
    -DSOME_DEFINE
    ```
      * <b>Note</b>: `compile_flags.txt` has the same format as `.clang_complete` but
       is not yet supported. There's an open [PR](https://github.com/Sarcasm/irony-mode/pull/505) for it.

## Code completion
Assuming that you performed <kbd>M-x</kbd> `irony-install-server` from the previous
section, for intelligent code complete you will need to install the Emacs package
`company-irony`. This must already be done if you followed the preparation insructions
in the beginning.

Add the following lines to your `~/.emacs` to automatically enable `irony-complete`
when you have C/C++ files open.
```lisp
;; To setup company mode (code completion) with irony. Requires company-irony package.
(eval-after-load 'company
  '(add-to-list 'company-backends 'company-irony))
(add-hook 'c++-mode-hook 'company-mode)
(add-hook 'c-mode-hook 'company-mode)

```

With this, you must automatically get code completion suggestions as you type. You can
type <kbd>TAG</kbd> to complete common parts and <kbd>ret</kbd> to complete. Use the
arrow keys to select the completion you want <kbd>M-(digit)</kbd> to select one from
the first 10 suggestions. More details on the [company-mode webpage](http://company-mode.github.io/).

## Misc configuration
I list out a few configuration settings I have in my `~/.emacs`, hoping it'll be useful
to you as well.

  * A basic Linux code style setting
    ```lisp
    ;;;; Basic style for C/C++ programs
    (setq c-default-style "linux"
          c-basic-offset 2)
    (setq-default indent-tabs-mode nil)
    ```
  * Display line numbers, column numbers and matching parenthesis.
    ```lisp
    (global-linum-mode)
    (setq linum-format "%4d\u2502")
    ;; In non-GUI, display unicode characters.
    (set-terminal-coding-system 'utf-8-unix)
    ;; column numbers
    (column-number-mode)
    ;; matching parenthesis
    (show-paren-mode 1)
    ```
  * A better [buffer selector](https://www.emacswiki.org/emacs/BufferSelection) (when you type <kbd>C-c C-b</kbd>).
    ```lisp
    ;;;; For a better buffer selector
    (global-set-key (kbd "C-x C-b") 'bs-show)
    ```
