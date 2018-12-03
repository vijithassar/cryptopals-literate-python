# Challenge 6 - Break repeating-key XOR

## Problem

**It is officially on, now.**

This challenge isn't conceptually hard, but it involves actual error-prone coding. The other challenges in this set are there to bring you up to speed. This one is there to qualify you. If you can do this one, you're probably just fine up to Set 6.

[There's a file here.](https://cryptopals.com/static/challenge-data/6.txt) It's been base64'd after being encrypted with repeating-key XOR.

Decrypt it.

Here's how:

1. Let KEYSIZE be the guessed length of the key; try values from 2 to (say) 40.
1. Write a function to compute the edit distance/Hamming distance between two strings. The Hamming distance is just the number of differing bits. The distance between:  
`this is a test`  
and  
`wokka wokka!!!`  
is 37. Make sure your code agrees before you proceed.
1. For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second KEYSIZE worth of bytes, and find the edit distance between them. Normalize this result by dividing by KEYSIZE.
1. The KEYSIZE with the smallest normalized edit distance is probably the key. You could proceed perhaps with the smallest 2-3 KEYSIZE values. Or take 4 KEYSIZE blocks instead of 2 and average the distances.
1. Now that you probably know the KEYSIZE: break the ciphertext into blocks of KEYSIZE length.
1. Now transpose the blocks: make a block that is the first byte of every block, and a block that is the second byte of every block, and so on.
1. Solve each block as if it was single-character XOR. You already have code to do this.
1. For each block, the single-byte XOR key that produces the best looking histogram is the repeating-key XOR key byte for that block. Put them together and you have the key.

This code is going to turn out to be surprisingly useful later on. Breaking repeating-key XOR ("Vigenere") statistically is obviously an academic exercise, a "Crypto 101" thing. But more people "know how" to break it than can actually break it, and a similar technique breaks something much more important.

**No, that's not a mistake.**

We get more tech support questions for this challenge than any of the other ones. We promise, there aren't any blatant errors in this text. In particular: the "wokka wokka!!!" edit distance really is 37.

[link](https://cryptopals.com/sets/1/challenges/6)

## Solution

Start by importing some functions we'll need later. I actually have half a mind to do these imports *inside* the functions where they are needed, because so far I am still striving to do this with minimal dependencies or imports. (Famous last words!)

```python
from subprocess import check_output as run
from base64 import b64decode
```

Since the instructions were pretty explicit about the exact range of key sizes to test, start by creating a list of all possible key lengths across which we can iterate. The syntax for this lil guy is needlessly verbose, but in a way this also makes it clearer that we need to offset the ending value by 1 in order to get all key lengths as specified in the instructions.

```python
def key_sizes():
  """Generate a list of possible key sizes."""
  start = 2
  end = 40
  return list(range(start, end + 1))
```

The Hamming distance is the total of differing *bits*, which means we can start by XORing *bytes* just like in previous exercises, and then sum the 1 values.

First, a helper function to convert text to bytes:

```python
def ascii_to_bytes(text):
  """Convert ASCII text to bytes."""
  return bytearray.fromhex(text.encode('utf-8').hex())
```

XOR the bytes, assuming you have two inputs that *match* in length.

```python
def xor_matching(a, b):
  """XOR two sets of bytes with matching lengths."""
  assert len(a) == len(b), 'attempting to XOR with elements of different lengths'
  return [a[i] ^ b[i] for i, x in enumerate(a)]
```

Armed with the above, we should now be able to compute the Hamming distance for any two arbitrary inputs: it's just the sum of the 1 bits resulting from the XOR.

```python
def hamming_distance(a, b):
  """Compute the Hamming distance between two inputs."""
  xor_bytes = xor_matching(a, b)
  binary_bytes = [bin(i)[2:] for i in xor_bytes]
  binary_string = ''.join(binary_bytes)
  binary = list(map(int, list(binary_string)))
  count = sum(binary)
  return count
```

As the instructions suggest, we should **double check** the Hamming distance calculation before proceeding in order to ensure that everything else downstream does not go off the rails. It feels a bit weird to have this check happen outside all the function wrappers and in the script's global space, but I guess it's just an assertion. This is almost functionally equivalent to unit testing, the main difference being that it runs *every time* the script executes, which is unusual, but in the context of this literate programming style it actually feels more coherent than a separate decoupled test.

```python
assert hamming_distance(ascii_to_bytes('this is a test'), ascii_to_bytes('wokka wokka!!!')) == 37, "incorrect Hamming distance calculation"
```

If we've make it this far without an error, then the Hamming distance calculation works!

The challenge instructions are ambiguous for this next bit. Step 3 says:

> For each KEYSIZE, take the first KEYSIZE worth of bytes, and the second KEYSIZE worth of bytes, and find the edit distance between them. Normalize this result by dividing by KEYSIZE.

I struggled with this for a while and then started searching online for tips, and found both implementations and writeups clarifying that the first and second key size chunks must be tested **against the whole ciphertext** instead of simply against each other. Ack! This could be written more clearly.

Splitting an iterable into chunks of a specified length is implemented as a separate helper function because we'll also have to do this again later when solving for the cipher.

```python
def split_chunks(iterable, chunk_size):
  """Split an iterable into chunks of a specified size"""
  chunks = [
    iterable[i:i + chunk_size]
    for i
    in range(0, len(iterable), chunk_size)
    if i < len(iterable) - chunk_size
  ]
  return chunks
```

Now we can compute the normalized Hamming distance. This step is sort of tricky, which is why I've written it with both runtime assertions and inline code comments. Interesting how it is normalized by *both* averaging and then controlling for key size; this must be what allows the deviations to really shine through and identify the most likely candidates for key size.

```python
def normalized_hamming_distance(text, key_size):
  """Given a key size, compute the normalized hamming distance for two strings."""
  assert key_size < len(text) / 2, 'text is too short to provide two blocks at this key size'
  bytelist = b64decode(text)
  assert isinstance(bytelist, (bytes, bytearray)), 'hamming distance must be calculated with raw bytes'
  # break cipher text into chunks
  chunks = split_chunks(bytelist, key_size) 
  # select two leading blocks
  blocks = [
    bytelist[0:key_size],
    bytelist[key_size:key_size * 2]
  ]
  # quadratic nested comprehensions
  hamming_distances = [
    [hamming_distance(block, chunk) for chunk in chunks]
    for block
    in blocks
  ][0] # this results in a nested array, so pull out the meaningful element
  # average all Hamming distances
  mean = sum(hamming_distances) / len(hamming_distances)
  # normalize by key size to further constrain deviations in the mean
  normalized = mean / key_size
  return normalized
```

Mapping over the range of possibile key lengths with the normalized Hamming distance function will create a list of Hamming distance value paired with key sizes. Honing in on the smallest values requires a helper function with converts the value and index into a key/value pair, sorts according to the Hamming distance, and then returns the key corresponding to the smallest value.

```python
def smallest(values):
  """Find the key sizes corresponding to the smallest Hamming distances in a list."""
  sorted_values = sorted(values, key=lambda x: x.get('distance'))
  return sorted_values[0].get('key_size')
```

Once again, a function to retrieve the [ciphertext](https://cryptopals.com/static/challenge-data/6.txt) from a remote source.

```python
def remote():
  """Retrieve ciphertext from the Cryptopals site."""
  url = "https://cryptopals.com/static/challenge-data/6.txt"
  return run(['curl', '--silent', url]).decode('ascii')
```

Combine the normalized Hamming distance *calculation* function with the Hamming distance *selection* function to determine the most likely length of the cipher key.

```python
def find_key_size(text):
  """Find the most likely key size for a piece of encrypted text."""
  # compute hamming distance
  normalized_hamming_distances = [
    {
      'key_size': key_size,
      'distance': normalized_hamming_distance(text, key_size)
    } 
    for key_size
    in key_sizes()
  ]
  # choose the smallest key size
  keys = smallest(normalized_hamming_distances)
  return keys
```

Transpose the input text into blocks of a specified size. We'll use this in a moment to divide the input text into sections that can be decrypted by each piece of the rotating key.

```python
def transpose(text, size):
  """Transpose input text bytes by a specified size."""
  bytelist = b64decode(text)
  chunks = split_chunks(bytelist, size)
  transposed = list(zip(*chunks))
  # check that transposition worked as expected
  assert chunks[0][0] == transposed[0][0], 'matrix transposition failed'
  assert chunks[0][1] == transposed[1][0], 'matrix transposition failed'
  assert chunks[0][2] == transposed[2][0], 'matrix transposition failed'
  return transposed
```

Apply a single-byte XOR to an input. This differs from the function above because it uses a *single byte* for the XOR, instead of XOR-ing two byte *lists* of matching length.

```python
def xor_single(bytelist, key):
  """XOR a set of bytes against a single key."""
  return [b ^ key for b in bytelist]
```

Generate a list of all ASCII characters.

```python
def ascii():
  """Generate ASCII characters."""
  return [chr(x) for x in range(128)]
```

Given a list of strings, separately count the frequency of common letters in each string in order to determine which string is most likely to be real readable language instead of the useless gibberish that would be produced by a misfiring decryption attempt.

```python
def detect_key(strings):
  """Guess a likely key given a set of inputs."""
  common = list('etaoin shrdlu')
  counts = [
    sum([string.count(character) for character in common])
    for string in strings
  ]
  maximum = max(counts)
  index = counts.index(maximum)
  return chr(index)
```

Statistically determine the single ASCII character that is most likely to be the XOR key needed to decrypt a given set of bytes:

```python
def find_xor_key(bytelist):
  """For a set of XOR encrypted input bytes, statistically determine the single most likely key."""
  xor_bytes = [xor_single(bytelist, ord(character)) for character in ascii()]
  xor_strings = [''.join(list(map(chr, integer))) for integer in xor_bytes]
  key = detect_key(xor_strings)
  return key
```

Run the statistical determination for a *single* key across *several* transposed blocks of bytes; the result is a *sequence* of keys which together form the cipher key.

```python
def find_vignere_key(text):
  """Statistically determine the Vignere cipher key that was used to XOR encrypt an input text."""
  key_size = find_key_size(text)
  transposed_bytes = transpose(text, key_size)
  vignere_key = ''.join([find_xor_key(x) for x in transposed_bytes])
  return vignere_key
```

And there it is! When you run the above function on the input text, it outputs `Terminator X: Bring the noise`. With a little modulus, decrypting is trivial:

```python
def decrypt_vignere(ciphertext, key):
  """Given a ciphertext and a key as input, decrypt with a Vignere cipher."""
  bytes_text = b64decode(ciphertext)
  bytes_key = ascii_to_bytes(key)
  decrypted_bytes = [b ^ bytes_key[i % len(bytes_key)] for i, b in enumerate(bytes_text)]
  decrypted_characters = [chr(b) for b in decrypted_bytes]
  decrypted_text = ''.join(decrypted_characters)
  return decrypted_text
```

It works! If you print `decrypted_text` to the console, you'll see that it is the lyrics to ["Play That Funky Music"](https://www.youtube.com/watch?v=zNJ8_Dh3Onk) by Vanilla Ice. It is a much longer piece of text than the others we have decrypted in previous challenges, and it's very fulfilling to see the terminal fill up with so much content.

Now the test to see if we have done this properly; if it has, the terminal should print the key and the message. The test function has the expected key value hard coded into an assertion just to make sure it has a way to fail if something upstream changes, because I want a way to verify but running some kind of language detection *again* on these two strings seems like overkill.

```python
def test():
  """Test challenge 6."""
  print('Challenge 6')
  ciphertext = remote()
  key = find_vignere_key(ciphertext)
  assert key == 'Terminator X: Bring the noise', 'incorrect key'
  message = decrypt_vignere(ciphertext, key)
  print(key)
  print(message)
  return (key, message)
```

Run the test function.

```python
if __name__ == "__main__":
  test()
```

