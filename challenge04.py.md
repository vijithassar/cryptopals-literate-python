# Challenge 4 - Detect single-character XOR

## Problem

One of the 60-character strings in [this file](https://cryptopals.com/static/challenge-data/4.txt) has been encrypted by single-character XOR.

Find it.

(Your code from #3 should help.)

[link](https://cryptopals.com/sets/1/challenges/4)

## Solution

Obviously there must be a way to ingest the raw strings in order to decode them, but it seems a little clunky to add them to the repository, and they are quite long and visually imposing so pasting them into the script also seems like a bad idea. The code for this solution will probably ultimately be clearer if we retrieve them remotely at runtime and avoid storing them as an artifact. The first cost of this approach is that you'll need to be online to run this solution; more abstractly, if the [Cryptopals web site](https://cryptopals.com/) crashes or is taken offline permanently at some point in the future then this solution will no longer work. Those strings are replicated in plenty of solutions, though, and if you're able to follow along with this code at all then you probably won't have trouble substituting in another copy of the original strings later in the unlikely event that it becomes necessary. I think this tradeoff is worth it.

But reading the input strings from a remote server also presents a second problem: at least so far, the solutions I have been writing do not really have any dependencies. So how would we fetch them without adding one?

We're definitely going to have to import *something* in order to make remote network requests, but the [`urllib2`](https://docs.python.org/2/library/urllib2.html) module is kind of gross syntatically; the [`requests`](http://docs.python-requests.org/en/master/) module is much more pleasant to work with, but it is not part of the Python standard library as of this writing, so it would need to be *installed* with [`pip`](https://pypi.org/project/pip/) or similar before it could be *imported* and used as part of a solution. That's an extra installation step that I'd prefer to avoid for now.

Especially because there's an even cleaner minimal solution! What we'll do instead is import the `subprocess` module, which lets us jump out of Python and into other command line programs:

```python
import subprocess
```

We'll use `subprocess` to run [`curl`](https://en.wikipedia.org/wiki/CURL) and build our remote reading function around that, basically deferring to the system tools for this problem. Fetching from a remote server is a pretty simple operation; we really do not need a fancy module that handles difficult extra scenarios like edge cases and authentication.

And look, the code is still quite clean! 

```python
def remote():
  """Retrieve strings to test from the Cryptopals site."""
  url = 'https://cryptopals.com/static/challenge-data/4.txt'
  command = ['curl', '--silent', url]
  response = subprocess.check_output(command)
  return response.decode('ascii')
```

That just gives us a raw text dump, so let's parse the strings into a list and clean up the extra newlines:

```python
def strings():
  """Parse remote text into individual strings."""
  lines = [str(line)[:-2] for line in remote().split('\n') if line]
  return lines
```

A helper to generate ASCII characters, just as with the last challenge:

```python
def ascii():
  """Generate all ASCII characters."""
  characters = [chr(x) for x in range(128)]
  return characters
```

In order to figure out what to test the decoder against, we need to compute the [cartesian product](https://en.wikipedia.org/wiki/Cartesian_product) of all strings against all ASCII characters. This should give us a single long list of all possible permutations that need to be tested. For this step, simple nested loops are probably clearer than comprehensions or generators or other forms of magic.

```python
def combinations(strings, characters):
  """Find all permutations of strings and possible key characters."""
  pairs = []
  # loop through strings
  for string in strings:
    # loop through characters
    for character in characters:
      # pair current string to current character
      pair = {'key': character, 'string': string}
      pairs.append(pair)
  return pairs
```

There are 327 strings provided and 128 ASCII characters as possible keys. That gives us 41856 combinations to test, which is way too many to manually scan as with the last exercise, so the detection function had better work.

It's not yet clear to me to what extent these challenges are going to be decoupled. The instructions here do make it clear that the work from the preceding challenge will be relevant, and yes, if we could just iterate over the list of pairs with the decoding function then we'd have a solution pretty quickly. I may come to regret this, but for now I think pursuing standalone solutions to each challenge will be very clean, so instead of trying to import the previous function I'm instead going to make this solution non-[DRY](https://en.wikipedia.org/wiki/Don%27t_repeat_yourself) and instead *re-implement* the necessary functions from the last problem. Redundant, yes, but this is extra practice, and is also an opportunity to rewrite with terse, concise, confusing syntax that will make me feel smart.

First, XOR a string against a character, and let's see how small we can make the function this time around:

```python
def decode(hex, key):
  """XOR a hexadecimal string with a specified key."""
  xor = [byte ^ ord(key) for byte in bytearray.fromhex(hex)]
  decoded = ''.join([chr(i) for i in xor])
  return {'key': key, 'string': hex, 'message': decoded}
```

Similarly, the function to select the proper decoding needs to be likewise recreated. Alas, even this attempt at a denser version requires a little external helper function that can be called inside the list comprehension:

```python
# common letters
common = 'etaoin shrdlu'

def count_common_characters(string):
  """Count common letters in a message."""
  return sum([string.count(c) for c in common])

def select(messages):
  """Determine which decoded string contains a readable message."""
  counts = [count_common_characters(m.get('message')) for m in messages]
  index = counts.index(max(counts))
  result = messages[index]
  return result
```

Now the test to see if we have done this properly.

```python
def test():
  """Test challenge 4."""
  print('Challenge 4 - Detect single-character XOR')
  pairs = combinations(strings(), ascii())
  decoded = [decode(x['string'], x['key']) for x in pairs]
  result = select(decoded)
  assert result.get('message') == 'Now that the party is jumping', 'converted text does not match expected string'
  print('Input string ' + result.get('string') + ' can be converted into "' + result.get('message') + '" using key ' + result.get('key'))
  return result
```

Run the test function. If everything here worked, the console should print the string, the message, and the key that was used to decrypt it.

```python
if __name__ == "__main__":
  test()
```

Oh no, it looks like the message is *yet another* Vanilla Ice lyric! I am a little out of my element here, because back when he was at his peak I was too young to pay attention to music and didn't have cable TV at home so I kind of just missed the whole thing.
