# envtpl

A tiny binary for templating plain text with environment variables. Like [`envsubst`](https://linux.die.net/man/1/envsubst) but simpler.

# Installation

Until a stable release is tagged you can download binaries for all supported platforms from the [latest successful build on the main branch](https://github.com/matt-allan/envtpl/actions).

# Usage

The `envtpl` binary expects input on STDIN and writes to STDIN. Any template strings of the format `${NAME}` will be replaced with the value of the environment variable matching `NAME`.

```sh
$ echo 'Hello ${USER}!' | envtpl
Hello matt!
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
