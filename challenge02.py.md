# Challenge 2 - Fixed XOR

## Problem

Write a function that takes two equal-length buffers and produces their XOR combination.

If your function works properly, then when you feed it the string:

`1c0111001f010100061a024b53535009181c`

...after hex decoding, and when XOR'd against:

`686974207468652062756c6c277320657965`

...should produce:

`746865206b696420646f6e277420706c6179`

[link](https://cryptopals.com/sets/1/challenges/2)

## Solution

First, a function to convert hexadecimal strings into the equivalent binary. There are certainly more concise ways of doing this and built in functions that would probably get us there faster, but for a problem set like this one a more verbose form of the conversion is illustrative. 

```python
def hex_to_bits(hex):
  """Convert hexadecimal to binary."""
  integers = int(hex, 16)
  binary = bin(integers)
  # strip the leading 0b
  strip = binary[2:]
  return strip
```

Since the solution is presented in hexadecimal, we'll also need the reverse. With string formatting:

```python
def binary_to_hex(binary):
  """Convert binary to hexadecimal."""
  hex = '{:0{}X}'.format(int(binary, 2), len(binary) // 4)
  # return lowercase hexadecimal to match the test case
  return hex.lower()
```

The input strings are different lengths, so we should take a moment to explicitly correct this before trying to XOR to make iterating easier.

```python
def pad(strings):
  """Pad an array of strings to the length of the longest string."""
  target = max([len(string) for string in strings])
  # pad string from the left
  padded = [string.rjust(target, '0') for string in strings]
  return padded
```

A couple quick helper functions will improve readability when writing the actual XOR logic. The first takes a string, splits it into a list of text characters, casts each text character to an integer, and then returns the new list of integers. The second function does the opposite operation: it takes a list of integers and returns them as a string.

```python
def split_integers(string):
  """Convert a string into a list of integers."""
  characters = list(string)
  integers = [int(i) for i in characters]
  return integers

def join_string(integers):
  """Convert a list of integers into a string."""
  characters = [str(i) for i in integers]
  string = ''.join(characters)
  return string
```

Now to actually perform the XOR comparison. This function takes strings in a tuple or list as the input; this allows for cleaner list comprehension syntax without as many placeholder variables along the way, but it's actually a little misleading because we don't ever actually iterate over the list. (This is an extremely pedantic nitpick, yes.)

```python
def xor(strings):
  """XOR two strings against each other."""
  binary_string = [hex_to_bits(string) for string in strings]
  padded = pad(binary_string)
  integers = [split_integers(string) for string in padded]
  pairs = list(zip(integers[0], integers[1]))
  diff = [pair[0] ^ pair[1] for pair in pairs]
  return diff
```

Now the test to see if we have done this properly.

```python
def test():
  """Test challenge 2."""
  print('Challenge 2 - Fixed XOR')
  a = "1c0111001f010100061a024b53535009181c"
  b = "686974207468652062756c6c277320657965"
  binary = join_string(xor([a, b]))
  converted = binary_to_hex(binary)
  expected = "746865206b696420646f6e277420706c6179"
  result = converted == expected
  assert result, "converted string does not match expected value"
  print(a + ' (first)')
  print(b + ' (second)')
  print(converted + ' (XOR)')
  return result
```

Run the test function. If everything worked correctly, the script will print the strings.

```python
if __name__ == "__main__":
  test()
```
