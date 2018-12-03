# Challenge 8 - Detect AES in ECB mode

## Problem

In [this file](https://cryptopals.com/static/challenge-data/8.txt) are a bunch of hex-encoded ciphertexts.

One of them has been encrypted with ECB.

Detect it.

Remember that the problem with ECB is that it is stateless and deterministic; the same 16 byte plaintext block will always produce the same 16 byte ciphertext.

[link](https://cryptopals.com/sets/1/challenges/8)

## Solution

The instructions tell us the input content is hex encoded, so we'll need a way to decode it.

```python
import codecs
```

I know I said I'd stop using this `curl` trick, but I still don't feel like tinkering with the `requests` module just yet. Maybe in the next problem set!

```python
from subprocess import check_output as run

def remote():
  """Retrieve possible ciphertexts from the Cryptopals site."""
  url = 'https://cryptopals.com/static/challenge-data/8.txt'
  command = ['curl', '--silent', url]
  return run(command).decode('ascii')
```

A quick comprehension to convert the hexadecimal to raw bytes.

```python
def parse(ciphertexts):
  """Convert hexadecimal to a list of raw bytes."""
  hexadecimal = [codecs.decode(item, 'hex') for item in ciphertexts.splitlines()]
  return hexadecimal
```

A given sequence of bytes is likely to be encoded with a block cipher if it contains identical blocks. This means that for any given input item, we can just loop through blocks of a specified size and compare them to the previous blocks. If a block is repeated verbatim, that probably mean these bytes contain something that was block encrypted. If there's no repetition, then it's just random gibberish and can be discarded.

It feels a little more coherent to store the block size in an outer scope variable that *closes over* the detection function, because that way it functions more like a configuration value.

```python
block_size = 16
```

Loop through an item looking for repetition.

```python
def has_duplicate_blocks(item):
  """Determine whether an item has duplicate blocks."""
  index = 0
  previous_blocks = []
  while index < len(item):
    block = item[index:index + block_size]
    # if there's a match, return early
    if (block in previous_blocks):
      return True
    else:
      previous_blocks.append(block)
    index = index + block_size
  return False
```

Apply the duplicate detection to each item in the input set:

```python
def identify(candidates):
  """Detect duplicate blocks in the input."""
  duplicates = [x for x in candidates if has_duplicate_blocks(x)]
  return duplicates
```

Now the test to see if we have done this properly.

```python
def test():
  """Test challenge 8."""
  print('Challenge 8')
  target = identify(parse(remote()))
  # if the identification function finds
  # one match, then it probably succeeded
  assert len(target) == 1, 'could not detect block encryption'
  print('block encrypted content:')
  # convert back to hexadecimal for the sake of readability
  result = codecs.encode(target[0], 'hex')
  print(result)
  return result
```

Run the test function.

```python
if __name__ == "__main__":
  test()
```
