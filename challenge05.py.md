# Challenge 5 - Implement repeating-key XOR

## Problem

Here is the opening stanza of an important work of the English language:

<pre>
Burning 'em, if you ain't quick and nimble
I go crazy when I hear a cymbal
</pre>

Encrypt it, under the key "ICE", using repeating-key XOR.

In repeating-key XOR, you'll sequentially apply each byte of the key; the first byte of plaintext will be XOR'd against I, the next C, the next E, then I again for the 4th byte, and so on.

It should come out to:

`0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f`

Encrypt a bunch of stuff using your repeating-key XOR function. Encrypt your mail. Encrypt your password file. Your .sig file. Get a feel for it. I promise, we aren't wasting your time with this.

[link](https://cryptopals.com/sets/1/challenges/5)

## Solution

This must be another Vanilla Ice lyric, right? Hold on, let me Google it and check.

Update: yes.

OK then.

First a helper function to convert text to bytes.

```python
def ascii_to_bytes(text):
  """Convert ASCII text to bytes."""
  return bytearray.fromhex(text.encode('utf-8').hex())
```

The actual encryption is surprisingly short. The most important part is the line with the `^`, which is the operator that actually performs the XOR. What it is XORing *against* gets rotated on each iteration by the modulus operator `%`, which is cycling through the available key bytes.

```python
def encrypt(text, key):
  """Encrypt text with a rotating key cipher."""
  bytes_key = ascii_to_bytes(key)
  bytes_text = ascii_to_bytes(text)
  encrypted = [byte_text ^ bytes_key[index % len(bytes_key)] for index, byte_text in enumerate(bytes_text)]
  hexadecimal = ["%02x" % ord(chr(x)) for x in encrypted]
  hex_string = ''.join(hexadecimal)
  return hex_string
```

Now the test to see if we have done this properly.

```python
def test():
  """Test challenge 5."""
  print('Challenge 5')
  key = 'ICE'
  input = "Burning 'em, if you ain't quick and nimble\nI go crazy when I hear a cymbal"
  expected="0b3637272a2b2e63622c2e69692a23693a2a3c6324202d623d63343c2a26226324272765272a282b2f20430a652e2c652a3124333a653e2b2027630c692b20283165286326302e27282f"
  encrypted = encrypt(input, key)
  result = encrypted == expected
  assert result, 'encrypted text does not match expected string'
  print('success' if result else 'fail')
  return result
```

Run the test function. If everything here worked, the console should print a message saying so. The expected string of the encrypted text is unwieldy and gibberish so it doesn't really make sense to log it as part of a confirmation message.

```python
if __name__ == "__main__":
  test()
```

