# Overview

This is a partial set of solutions to the [Cryptopals](https://cryptopals.com) challenges, a set of programming problems about cryptography.

The challenges can be solved in any programming language. These solutions use [Python 3](https://www.python.org) code. More interestingly, however, they are written in an unusual style called [literate programming](https://en.wikipedia.org/wiki/Literate_programming). Each solution is implemented as a *written document* with *occasional* bits of code; the latter can be identified, extracted and run using the [`lit.sh`](https://github.com/vijithassar/lit) helper script, almost like *executing the documentation*. It is kind of weird! That is the point.

# Setup

Before you can run these solutions, you will first need to run the [setup script](./setup.sh).

```bash
# set up project and install dependencies
$ ./setup.sh
```

This script will do the following:

1. create and activate a [virtual environment](https://docs.python-guide.org/dev/virtualenvs/), an isolated corner dedicated to a particular project in which Python can install dependencies without affecting anything else on your computer
2. install [dependencies](./requirements.txt) with [pip](https://pypi.org/project/pip/)
3. download [lit.sh](https://github.com/vijithassar/lit), a tool which helps with literate programming

This script is the only thing that is *not* written in literate programming style, because you will need to run it before you have installed `lit.sh`.

# Executing

The `lit.sh` script provides several different workflows for literate programming; you can read more about each in the [documentation](https://github.com/vijithassar/lit/blob/master/README.md) and select whichever mode of operation fits your fancy. For the purposes of this quick start guide, however, I will recommend the following syntax:

```bash
# execute code for challenge 1
$ python3 <(cat challenge01.py.md | lit.sh --stdio --before "#")
```

Change `challenge01.py.md` to the filename of whichever solution you'd like to run.

# Index

## Set 1

- [Challenge 1](./challenge01.py.md)
- [Challenge 2](./challenge02.py.md)
- [Challenge 3](./challenge03.py.md)
- [Challenge 4](./challenge04.py.md)
- [Challenge 5](./challenge05.py.md)
- [Challenge 6](./challenge06.py.md)
- [Challenge 7](./challenge07.py.md)
- [Challenge 8](./challenge08.py.md)
