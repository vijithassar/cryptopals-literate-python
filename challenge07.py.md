# Challenge 7 - AES in ECB mode

## Problem

The Base64-encoded content in [this file](https://cryptopals.com/static/challenge-data/7.txt) has been encrypted via AES-128 in ECB mode under the key

`"YELLOW SUBMARINE".`

(case-sensitive, without the quotes; exactly 16 characters; I like "YELLOW SUBMARINE" because it's exactly 16 bytes long, and now you do too).

Decrypt it. You know the key, after all.

Easiest way: use OpenSSL::Cipher and give it AES-128-ECB as the cipher.

**Do this with code.**

You can obviously decrypt this using the OpenSSL command-line tool, but we're having you get ECB working in code for a reason. You'll need it a lot later on, and not just for attacking ECB.

[link](https://cryptopals.com/sets/1/challenges/7)

## Solution

Can we start with a gripe? Of course we can, because this is my solution, so I get to make the rules.

What's going on with these kooky instructions?

I complained at length in the last exercise about how the language used to describe step 3 was ambiguous. This one is even worse! The `formatted code` used to present the decryption key is *incorrect*. Why does it have a period inside the code block? Why is that then *explained* in the subsequent text? Why not just format the code block accurately? 

OK, moving on.

AES encryption is not currently included in the Python 3 standard library so it's time to start using external modules.

When you do so, you'll need to make sure you are installing them *inside* the virtual environment for this project. If you haven't already done so, run the setup script and then switch into the virtual environment it installs. 

<pre>
# set up
$ ./setup.sh

# switch to virtual environment
$ source ./env/bin/activate
</pre>

This will install the dependencies necessary for *all* Cryptopals problems, but for now we only care about one of them. For a long time the canonical module for cryptography was [PyCrypto](https://www.dlitz.net/software/pycrypto/), but it has been abandoned since 2014. Instead, a replacement called [PyCryptodome](https://www.pycryptodome.org/) emerged, with two configurations available: you can install `pycryptodome` and then `import PyCrypto` if you want a drop-in replacement for the PyCrypto API, or you can install `pycryptodomex` and then `import PyCryptodome` if you don't care about compatibility. I went with the latter.

```python
from Cryptodome.Cipher import AES
```

There's also the [`cryptography` module](https://cryptography.io/). Maybe we'll get around to that later, I don't know.

The instructions also tell us the source is Base 64 encoded, thus:

```python
from base64 import b64decode
```

Once again, remotely fetch the [encrypted input](https://cryptopals.com/static/challenge-data/7.txt) from the [Cryptopals server](https://cryptopals.com) to keep this repository clean. Using the [requests module](http://python-requests.org) would make sense now that third-party modules are finally in use, but I'm still pleased by the simplicity and elegance of my previous solution to this problem of deferring [curl](https://en.wikipedia.org/wiki/CURL) via Python's built-in [subprocess](https://docs.python.org/3/library/subprocess.html) module, so let's have one last hurrah with that approach before I eventually capitulate.

```python
from subprocess import check_output as run

def remote():
    """Retrieve ciphertext from the Cryptopals site."""
    url = 'https://cryptopals.com/static/challenge-data/7.txt'
    command = ['curl', '--silent', url]
    return run(command).decode('ascii')
```

The key has already been supplied:

```python
key = b'YELLOW SUBMARINE'
```

Decryption is as simple as spinning up an instance of PyCryptodome, specifying AES and the provided key.

```python
def decrypt(ciphertext):
    """Decrypt ciphertext with AES and key 'YELLOW SUBMARINE'."""
    cipher = AES.new(key, AES.MODE_ECB)
    decrypted = cipher.decrypt(ciphertext)
    return decrypted
```

Now the test to see if we have done this properly.

```python
def test():
    """Test challenge 7."""
    print('Challenge 7')
    encrypted = b64decode(remote())
    result = decrypt(encrypted)
    assert 'Play that funky music' in str(result), 'decryption failed'
    print('success' if result else 'fail')
    return result
```

Run the test function.

```python
if __name__ == "__main__":
    test()
```
