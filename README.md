# shellrcd

This is a setup that will allow easy/easier management of you (zsh and bash)
configuration.

## Quick Installation

If you're happy to run the installation script directly:

```
sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
```

or

```
sh -c "$(wget -qO- https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
```

## Cautious Installation

If you prefer to download, examine, and run the script yourself:

```
curl -fsSL -o ~/install-shellrcd.sh \
    https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh

$EDITOR ~/install-shellrcd.sh

sh -c ~/install-shellrcd.sh
```
