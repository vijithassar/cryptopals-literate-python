# Challenge 1 - Convert hex to base64

## Problem

The string:

`49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d`

Should produce:

`SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t`

So go ahead and make that happen. You'll need to use this code for the rest of the exercises.

**Cryptopals Rule**

Always operate on raw bytes, never on encoded strings. Only use hex and base64 for pretty-printing.

[link](https://cryptopals.com/sets/1/challenges/1)

## Solution

Simply pulling in the [codecs](https://docs.python.org/2/library/codecs.html) module will do a lot of the work.

```python
# import the codecs module
import codecs
```

First up is the obvious conversion function, which passes data through the available methods of the codecs module. It's probably entirely possible to further condense this down to a one-liner, but naming references along the way makes it clear what each step accomplishes, which seems like a good idea for both educational exercises and literate style code.

```python
# encoding conversion function
def encoding(input):
  """Convert hexadecimal to unicode."""
  hex = codecs.decode(input, 'hex')
  b64 = codecs.encode(hex, 'base64')
  unicode = codecs.decode(b64, 'utf-8')
  return unicode
```

That already handles most of it, but there's a little extra garbage at the end of the string; `\n`, an encoded newline. We'll need to strip this out, and for the sake of clarity, we might as well make that a separate function. This is actually just a single character, even though the escaped version is written with backslash notation.

```python
def cleanup(string):
  """Prepare a string for processing."""
  # omit the last character
  return string[:-1]
```

These two need to be wrapped together in order to be considered a complete solution to the problem, so here's one more function that just serves as a wrapper.

```python
def convert(input):
  """Clean up a string and convert it to hexadecimal."""
  return cleanup(encoding(input))
```

Maybe there is a cleaner way of doing this, such that the results of the `encoding()` function are in better shape to begin with? But whatever, this can still be considered complete, so now we need a test function to verify that the code above is all correct and behaves as desired.

```python
def test():
  """Test challenge 1."""
  hex = '49276d206b696c6c696e6720796f757220627261696e206c696b65206120706f69736f6e6f7573206d757368726f6f6d'
  b64 = 'SSdtIGtpbGxpbmcgeW91ciBicmFpbiBsaWtlIGEgcG9pc29ub3VzIG11c2hyb29t'
  # run the conversion function
  converted = convert(hex)
  # is the result what was expected?
  result = converted == b64
  assert result, "converted string does not match expected value"
  print(hex + ' (hexadecimal)')
  print(converted + ' (base64)')
  return result
```

Run the test function. If everything worked correctly, the script will print both versions of the string.

```python
if __name__ == "__main__":
  test()
```
