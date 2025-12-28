# Installing behind a proxy {#sec-installing-behind-proxy}

To install awos behind a proxy, do the following before running
`awos-install`.

1.  Update proxy configuration in `/mnt/etc/awos/configuration.nix` to
    keep the internet accessible after reboot.

    ```nix
    {
      networking.proxy.default = "http://user:password@proxy:port/";
      networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";
    }
    ```

1.  Setup the proxy environment variables in the shell where you are
    running `awos-install`.

    ```ShellSession
    # proxy_url="http://user:password@proxy:port/"
    # export http_proxy="$proxy_url"
    # export HTTP_PROXY="$proxy_url"
    # export https_proxy="$proxy_url"
    # export HTTPS_PROXY="$proxy_url"
    ```

::: {.note}
If you are switching networks with different proxy configurations, use
the `specialisation` option in `configuration.nix` to switch proxies at
runtime. Refer to [](#ch-options) for more information.
:::
