My Markdown Resume
==================

Based on [Pandoc Resume](https://github.com/mszep/pandoc_resume).

### Instructions

```bash
$ git clone https://github.com/mszep/pandoc_resume
$ cd pandoc_resume
$ vim markdown/resume.md   # insert your own resume info
$ make # Make everything
```

#### Dockerized

Make everything

```bash
$ docker-compose up -d
```

### Requirements

If not using `docker` then you will need the following dependencies.

* ConTeXt 0.6x
* pandoc 2.x
    * 1.x is deprecated

Last tested on the above versions and that's not to say the later versions won't work. Please try to use the latest versions when possible.

#### Debian / Ubuntu

```bash
$ sudo apt install pandoc context
```

#### Fedora
```bash
$ sudo dnf install pandoc texlive-collection-context
```

#### Arch
```bash
$ sudo pacman -S pandoc texlive-core
```

#### OSX
```bash
$ brew install pandoc mactex
$ mtxrun --generate
```

### Troubleshooting

#### Get versions

Check if the dependencies are up to date.

```
context --version
pandoc --version
```

#### Context executable cannot be found
Some users have reported problems where their system does not properly find the ConTeXt
executable, leading to errors like `Cannot find context.lua` or similar. It has been found
that running `mtxrun --generate`, ([suggested on texlive-2011-context-problem](
https://tex.stackexchange.com/questions/53892/texlive-2011-context-problem)), can fix the
issue.
