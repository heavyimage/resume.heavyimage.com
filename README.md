Resume Build system
===================

This repo contains my [markdown resume](https://github.com/heavyimage/resume.heavyimage.com/blob/master/markdown/template.md) and the system that build it into <https://resume.heavyimage.com> and a [pdf](https://resume.heavyimage.com/resume.pdf).

The setup is heavily based on [Pandoc Resume](https://github.com/mszep/pandoc_resume).

### Build Instructions

```bash
$ git clone https://github.com/heavyimage/resume.heavyimage.com
$ cd pandoc_resume
$ vim markdown/template.md   # insert your own resume info
$ make # Make everything
```

#### Deploy Changes:

```bash
$ git remote add deploy ssh://$USER@$HOST:$PORT$PATH
$ git push deploy
```

For the deployment repo, you'll probably want to setup a `post-recieve` hook something like this:

```bash
#!/bin/bash
GIT_REPO=$HOME/projects/resume-DEPLOY.git
TMP_GIT_CLONE=$HOME/tmp/resume-DEPLOY
PUBLIC_WWW=/var/www/SUBDOMAIN.DOMAIN.com

git clone $GIT_REPO $TMP_GIT_CLONE
cd $TMP_GIT_CLONE

# Make html version
make html
rm $PUBLIC_WWW/index.html
cp output/template.html $PUBLIC_WWW/index.html

# Make pdf version
make pdf
rm $PUBLIC_WWW/resume.pdf
cp output/template.pdf $PUBLIC_WWW/resume.pdf

rm -Rf $TMP_GIT_CLONE
exit
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

```bash
$ sudo apt install pandoc context                       # Debian / Ubuntu
$ sudo dnf install pandoc texlive-collection-context    # Fedora
$ sudo pacman -S pandoc texlive-core                    # Arch
$ brew install pandoc mactex && mtxrun --generate       # MacOS
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
