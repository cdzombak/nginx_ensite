# `nginx_ensite` / `nginx_dissite`

Quickly enable/disable nginx sites.

## Description

This is a shell (Bash) script that replicates for
[nginx](http://wiki.nginx.org) the [Debian](http://debian.org)
`a2ensite` and `a2dissite` for enabling and disabling sites as virtual
hosts in Apache 2.2/2.4.

The original `a2ensite` and `a2dissite` is written in
Perl. `a2dissite` is a symbolic link to `a2ensite`. Here I followed
the same approach, i.e., `nginx_dissite` is a symbolic link to
`nginx_ensite`.

The script allows for arbitrary paths for the nginx configuration
directories. This is particularly useful not only to those on Mac, but
also in a microservice approach where each service has it's own vhost
configuration, for example.

The default startup program is `systemctl`. Feel free to pass another
program. For example, using nginx to send a `SIGHUP` to reload the
configuration you just pass the option `-s nginx` to the script.

## Installation

### Debian via apt repository

[Install my Debian repository](https://www.dzombak.com/blog/2025/06/updated-instructions-for-installing-my-debian-package-repositories/) if you haven't already:

```shell
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://dist.cdzombak.net/keys/dist-cdzombak-net.gpg -o /etc/apt/keyrings/dist-cdzombak-net.gpg
sudo chmod 644 /etc/apt/keyrings/dist-cdzombak-net.gpg
sudo mkdir -p /etc/apt/sources.list.d
sudo curl -fsSL https://dist.cdzombak.net/cdzombak-oss.sources -o /etc/apt/sources.list.d/cdzombak-oss.sources
sudo chmod 644 /etc/apt/sources.list.d/cdzombak-oss.sources
sudo apt update
```

Then install `nginx-ensite` via `apt`:

```shell
sudo apt install nginx-ensite
```

### Automatic

```
git clone https://github.com/cdzombak/nginx_ensite.git
cd nginx_ensite
sudo make install
```

### Manual

Just drop the script and the symbolic link in `/usr/sbin` or other
location appropriate for your system. Meaning: `cp nginx_* /usr/sbin`.

#### Manpages

Two UNIX manual pages are included in the man directory. They should
be copied to a proper directory in your system. Something along the
lines of `/usr/share/man/man8` or `/usr/local/share/man/man8`.

## Usage

Note that the script assumes a specific file system topology for your
`nginx` configuration. Here's the rundown:

 1. All virtual hosts configuration files are by default under
    `/etc/nginx/sites-available`. For example the virtual host `foobar`
    is configured through a file in `/etc/nginx/sites-available`.

 2. After running the script with `foobar` as argument: `nginx_ensite
    foobar`. A symbolic link `/etc/nginx/sites-enabled/foobar ->
    /etc/nginx/sites-available/foobar` is created. Note that if the
    `/etc/nginx/sites-enabled` directory doesn't exist the script
    creates it.

 3. The script invokes `nginx -t` to test if the configuration is
    correct. If the test fails no symbolic link is created and an error
    is signaled.

 4. If everything is correct now just reload nginx, in Debian based
    systems that means invoking `service nginx reload` (default
    startup program name is `service`).

 5. Now point the browser to the newly configured host and everything
    should work properly assuming your configuration is sensible.

 6. To disable the site just run `nginx_dissite foobar`. Reload nginx
    to update the running environment.

## Requirements

The script is written in Bash and uses what I believe to be some Bash
specific idioms. I never tested it in other shells. You're welcomed to
try it in any other shell. Please do tell me how it went.

It requires also [awk](http://en.wikipedia.org/wiki/AWK). The original
`awk` (usually called BWK awk) from Bell Labs will do if you don't
have [gawk](http://www.gnu.org/software/gawk) (Gnu awk).  IN OS X and
*BSD the former is the default `awk`. The script should work in *BSD,
OS X and GNU/Linux.

## Command Completion

There's a Bash script for automatic completion of sites to be
enabled and disabled located in the `bash_completion.d` directory.

To make use of it you should:

 1. Source the script to Bash by issuing either `source
    nginx-ensite` or `. nginx-ensite`.

 2. Now when you invoke `nginx_ensite` the sites under
    `/etc/nginx/sites-available` will appear as hypothesis for
    completion. For `nginx_dissite` you get all the sites listed in
    `/etc/nginx/sites-enabled` as possible completions.

 3. To get the completion script to be sourced upon login please
    copy it to `/etc/bash_completion.d/` or whatever location your
    shell environment uses to place all the completion
    scripts. `/etc/bash_completion.d/` is the location in Debian
    (hence also in Ubuntu) of Bash completion scripts.

## Acknowledgments

Thanks to the many people that have contributed to this script. You're
the stuff Free Software is made of.

## License

MIT; see the [LICENSE](LICENSE) file for details.
