# shellrcd

This is a setup that will allow easy/easier management of you (zsh and bash)
configuration.

<!-- START doctoc -->
<!-- END doctoc -->

## Quick Installation

If you're happy to run the installation script directly as your normal
(non-root) user:

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

## Example Installation

```
monster-mash:~ testuser$ sh -c "$(curl -fsSL https://raw.githubusercontent.com/chiselwright/shellrcd/master/tools/install.sh)"
[zsh] Looking for an existing zsh config...
[zsh] Creating /Users/testuser/.zshrc and adding shellrcd block...
[bash] Looking for an existing bash config...
[bash] MacOS detected. Using .bash_profile.
[bash] Creating /Users/testuser/.bash_profile and adding shellrcd block...
[shellrcd] /Users/testuser/.shellrc.d is not found. Downloading...
[shellrcd] ...done
           _             _    _                    _
          ( )           (_ ) (_ )                 ( )
      ___ | |__     __   | |  | |  _ __   ___    _| |
    /',__)|  _ `\ /'__`\ | |  | | ( '__)/'___) /'_` |
    \__, \| | | |(  ___/ | |  | | | |  ( (___ ( (_| |
    (____/(_) (_)`\____)(___)(___)(_)  `\____)`\__,_)
                                ....is now installed!

    Please look over /Users/testuser/.bash_profile for any glaring errors.

    Check which scripts are active with:
        sh /Users/testuser/.shellrc.d/tools/list-active.sh

    Once happy, open a new shell or:
        source /Users/testuser/.bash_profile

monster-mash:~ testuser$
```
