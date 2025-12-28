# Network Problems {#sec-nix-network-issues}

Nix uses a so-called *binary cache* to optimise building a package from
source into downloading it as a pre-built binary. That is, whenever a
command like `awos-rebuild` needs a path in the Nix store, Nix will try
to download that path from the Internet rather than build it from
source. The default binary cache is `https://cache.awos.org/`. If this
cache is unreachable, Nix operations may take a long time due to HTTP
connection timeouts. You can disable the use of the binary cache by
adding `--option use-binary-caches false`, e.g.

```ShellSession
# awos-rebuild switch --option use-binary-caches false
```

If you have an alternative binary cache at your disposal, you can use it
instead:

```ShellSession
# awos-rebuild switch --option binary-caches http://my-cache.example.org/
```
