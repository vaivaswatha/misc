# A quick guide to building LLVM

## Project directory
  - `export LLVM_PROJECT=/path/where/you/want/to/have/LLVM`.
  - `export LD_LIBRARY_PATH=${LLVM_PROJECT}/install/lib:$LD_LIBRARY_PATH`
  - `export LIBRARY_PATH=${LLVM_PROJECT}/install/lib:$LIBRARY_PATH`

 Also add the exports to `~/.bashrc`

## Shallow Clone
The LLVM monorepo is quite huge, and for most purposes, a shallow clone is good enough.
  - `git clone --depth 1 https://github.com/llvm/llvm-project.git $LLVM_PROJECT`
  - Provide additional argument `--branch llvmorg-9.0.1` to the previous command
    if you want to checkout the tagged release `llvmorg-9.0.1`.

## Configure and build
  - `cd $LLVM_PROJECT`
  - `mkdir build install` Create directories for the build and install.
  - `cd build`
  - `cmake -G "Ninja" -DCMAKE_INSTALL_PREFIX=../install -DCMAKE_BUILD_TYPE="Debug" -DLLVM_TARGETS_TO_BUILD="host" ../llvm`
  - `ninja install`. This will build and install LLVM to `${LLVM_PROJECT}/install`.

Useful additional flags when configuring (`cmake`)
  - `-DCMAKE_BUILD_TYPE=[Release|Debug|RelWithDebInfo]`
  - `-DLLVM_USE_LINKER=gold` to use the `gold` linker which is faster and requires lesser memory.
   I suggest using this (requires the `gold` linker to be installed on your system).
  - `-DBUILD_SHARED_LIBS=1` Builds LLVM as a shared library. This can potentially bring
  down the memory requirements for your build. It may in turn add a delay when starting
  your debugger.
  - `-DLLVM_ENABLE_BINDINGS=OFF` If you get warnings or errors related to missing OCaml
  bindings.
  - `-DLLVM_BUILD_TOOLS=OFF` If you want to build just the libraries and not the
  executable tools (`opt`, `llvm-as` etc).
  - `-DLLVM_ENABLE_PROJECTS="clang;mlir"` For example, to also build `clang` and `mlir`.
  - `-DCMAKE_CXX_FLAGS=" -ggdb3 -gdwarf-4 "` for better debugging experience with gdb.
  - A full list of config flags can be found on the [LLVM build page](https://llvm.org/docs/CMake.html).
