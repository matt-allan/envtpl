# envtpl

A tiny binary for templating plain text with environment variables. Like [`envsubst`](https://linux.die.net/man/1/envsubst) but simpler.

# Installation

Binaries for all supported platforms are available for download on the [releases page](https://github.com/matt-allan/envtpl/releases).

If you're looking for a one liner to download the binary, you can use this:

```
curl -L https://github.com/matt-allan/envtpl/releases/download/0.2.0/aarch64-macos.tar.xz | tar -xJ --strip-components=1 -C .
```

Replace the filename with the architecture you want (listed on the releases page). The binary will be available in your current directory as `envtpl`.

You can also download binaries for unreleased versions from the [latest successful build on the main branch](https://github.com/matt-allan/envtpl/actions).

# Usage

The `envtpl` binary expects input on STDIN and writes to STDOUT. Any template strings of the format `${NAME}` will be replaced with the value of the environment variable matching `NAME`. For example:

```sh
$ echo 'Hello ${USER}!' | envtpl
Hello matt!
```

For the typical use case of templating a source file, you can use [redirection](https://wiki.bash-hackers.org/howto/redirection_tutorial):

```
envtpl < nginx.tpl.conf > nginx.conf
```

## Differences from envsubst

- Doesn't replace environment variables that aren't wrapped in curly braces. Avoids issues with variables that aren't meant to be replaced in the same file
- Doesn't replace environment variables when the case does not match
- No `--variables` option. Use [`env -i`](https://linux.die.net/man/1/env) if you need that functionality
- No dynamic memory allocations
- Available as a standalone, cross platform binary that's easy to install without a package manager
- Written in Zig instead of C
- Much smaller downloads: ~100K instead of the ~19MB you will have to download to get `envsubst` (the binary itself is about the same size though)
- Native binaries for ARM Macs and Alpine containers (links [musl](https://musl.libc.org/) instead of gcc)

# Why?

When you're building a [Twelve-Factor App](https://12factor.net/) you store config in environment variables. But some config file formats don't support environment variables (i.e. Nginx). You can use `envsubst` but then you have to install the entirety of [`gettext`](https://www.gnu.org/software/gettext/) in every environment, which pulls in about 2MB of binaries and isn't the easiest to install on all platforms. This tool is small enough you can usually afford to bundle it as a dependency.
