# C / C++ Development on the Command Line

With modern IDEs like Visual Studio Code, you seldom need to develop applications on the
command line. Nevertheless it is a usefull skill to have and this article provides a
fast setup for development on a command line only interface.

The article focuses on using Emacs (for which I have a keyboard shortcuts reference
[here](https://github.com/vaivaswatha/misc/blob/master/EmacsReference.md)).
Many parts of the article should work well for Vim too.

## Preparation
You will need the following OS packages:
  - `sudo apt-get install emacs cscope exuberant-ctags global libclang-dev build-essential cmake`

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
  - <kbd>M-x</kbd> `package-install ggtags`
  - <kbd>M-x</kbd> `package-install irony`
  - <kbd>M-x</kbd> `package-install flycheck-irony`
  - <kbd>M-x</kbd> `package-install company-irony`

## Code browsing with Cscope and GNU Global
You can run the following set of commands (to be put in a script for easy invocation)
to build symbol databases for Cscope and gnu-global tags. The files `cscope.out` and
`GPATH`, `GRTAGS` and `GTAGS` are produced.

  * `$gtags .`
  * `$cscope -bR`

I suggest adding these filenames to the `.gitignore` file of your project (or `~/.gitignore`).
You may also add these commands to your `Makefile` to keep the tags updated.

### Code browsing with Cscope
Once you have a Cscope database (`cscope.out`) in your project directory, you
can run `$cscope -d` to start the Cscope program. You can do plenty of queries
there such as find definitions, references, includes etc. You can also pipe
the output of your queries to command such as `grep` to filter, by hitting `|`
once you get an output and typing the command.

### Emacs and ggtags

Insert the following piece of code in your `~/.emacs` file to enable the Emacs plugin
`ggtags` for GNU Global for all C/C++ files.

```lisp
(add-hook 'c-mode-common-hook
          (lambda ()
            (when (derived-mode-p 'c-mode 'c++-mode 'java-mode)
              (ggtags-mode 1))))

```

You can now type <kbd>M-.</kbd> to go to the definition of the current symbol.
You can go back to where you started the search using <kbd>M-,</kbd>. Use
<kbd>M-?</kbd> to find all references to a symbol. For more navigation tips,
see the [ggtags page](https://github.com/leoliu/ggtags#usage).

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
;; For figuring out compile commands from compile_commands.json or compile_flags.txt databases.
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
      * Alternatively, you can specify `-DCMAKE_EXPORT_COMPILE_COMMANDS=ON`
        when you invoke `cmake` to setup your project.
    * If you don't use `CMake` in your program but use a simple `Makefile`, you can use
    [compiledb](https://github.com/nickdiego/compiledb). Install `compiledb` using
    `pip` as `pip install compiledb`. You can then run `compiledb make` instead of `make`.
    Any arguments you provide to `make` can still be given. `compiledb` will
    intercept every compilation done by `make` and add it to the compilation database.
    * You can also try https://github.com/rizsotto/Bear
  - `compile_flags.txt` or `.clang_complete`. For small projects where all of your source
  files use the same compilation command, they can all be specified once in a file
  named [compile_flags.txt](https://releases.llvm.org/8.0.0/tools/clang/tools/extra/docs/clangd/Installation.html#compile-flags-txt)
  or [.clang_complete](https://github.com/xavierd/clang_complete/blob/master/README.md#minimum-configuration)
   in the root of your project. Add each compilation flag in a separate line. Both files
   use the same format. Here's an example.
    ```
    -std=c++11
    -Ipath/to/include
    -DSOME_DEFINE
    ```

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
  * A better [buffer selector](https://www.emacswiki.org/emacs/BufferSelection)
    (when you type <kbd>C-c C-b</kbd>).
    ```lisp
    ;;;; For a better buffer selector
    (global-set-key (kbd "C-x C-b") 'bs-show)
    ```
## Useful references
  - https://tuhdo.github.io/c-ide.html
  - http://martinsosic.com/development/emacs/2017/12/09/emacs-cpp-ide.html
  - https://gist.github.com/soonhokong/7c2bf6e8b72dbc71c93b
