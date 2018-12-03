# Overview

This is a partial set of solutions to the [Cryptopals](https://cryptopals.com) problems, a set of programming challenges about cryptography.

The problems can be solved in any programming language. These solutions use [Python 3](https://www.python.org) code. More interestingly, however, they are written in an unusual style called [literate programming](https://en.wikipedia.org/wiki/Literate_programming). Each solution is implemented as a *written document* with *occasional* bits of code; the latter can be extracted and executed using the [`lit.sh`](https://github.com/vijithassar/lit) helper script.

# Setup

To run these solutions, you first need to run the [setup script](./setup.sh).

```bash
# install dependencies
$ ./setup.sh
```

This script will do the following:

1. create and activate a [virtual environment](https://docs.python-guide.org/dev/virtualenvs/), an isolated corner dedicated to a particular project in which Python can install dependencies without affecting anything else on your computer
2. download [dependencies](./requirements.txt) with [pip](https://pypi.org/project/pip/), the standard installation tool for Python
3. download [lit.sh](https://github.com/vijithassar/lit), a tool I wrote to help with literate programming 

# Executing

The `lit.sh` script provides several different workflows for literate programming; you can read more about each in the [documentation](https://github.com/vijithassar/lit/blob/master/README.md) and select whichever mode of operation fits your fancy. For the purposes of this quick start guide, however, I will recommend the following syntax:

```bash
$ python <(cat challenge01.py.md | lit.sh --stdio --before "#")
```

Change `challenge01.py.md` to the filename of whichever solution you'd like to run.

# Index

## Set 1

- [challenge 1](./challenge01.py.md)
- [challenge 2](./challenge02.py.md)
- [challenge 3](./challenge03.py.md)
- [challenge 4](./challenge04.py.md)
- [challenge 5](./challenge05.py.md)
- [challenge 6](./challenge06.py.md)
- [challenge 7](./challenge07.py.md)
- [challenge 8](./challenge08.py.md)
