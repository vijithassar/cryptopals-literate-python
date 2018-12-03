# Challenge 3 - Single-byte XOR cipher

## Problem

The hex encoded string:

`1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736`

...has been XOR'd against a single character. Find the key, decrypt the message.

You can do this by hand. But don't: write code to do it for you.

How? Devise some method for "scoring" a piece of English plaintext. Character frequency is a good metric. Evaluate each output and choose the one with the best score.

[link](https://cryptopals.com/sets/1/challenges/3)

## Solution

Return the list of possible characters from a function so it's easier to extend programmatically if necessary.

```python
def ascii(): 
  """Generate a list of all ASCII characters."""
  return [chr(x) for x in range(128)]
```

Decode a message that has been XOR'd with a given character as the key. Somehow this is dramatically shorter than the single XOR from the preceding challenge!

```python
def decode_message(hex, key):
  """XOR a hexadecimal string with a key."""
  binary = bytearray.fromhex(hex)
  # convert key letter to ASCII
  key_byte = ord(key)
  xor_bytes = [byte ^ key_byte for byte in binary]
  # convert XOR characters back to text
  xor_characters = [chr(i) for i in xor_bytes]
  decoded = ''.join(xor_characters)
  return {'key': key, 'message': decoded}
```

This function decodes a single instance of the message with the chosen key, and there is really no reason to worry about creating a multiple-message wrapper version (`decode_messages()` or similar) because that can be so easily handled with a list comprehension; this is how it is eventually written below. Still, one interesting note about the multiple message version:

Printing the decoded messages results in a wall of text, because there isn't yet a way to automatically detect the match which actually resembles real text; that's coming up next. But simply manually scanning the output reveals the match! The key is `x`, and the output text is `Cooking MC's like a pound of bacon`, which is, regrettably, a line from ["Ice Ice Baby"](https://www.youtube.com/watch?v=rog8ou-ZepE) by Vanilla Ice.

During my final year of college, some friends and I embarked on what we hoped would be a scandalous spring break trip to Florida. Daytona Beach, I think it was? I don't actually remember the details because I only signed on at the last minute and hadn't been involved in planning at all, but we ended up staying at a hotel that aggressively marketed itself to college students, and booked musical performances for the stage in the courtyard accordingly. During our brief stay, the entertainment included Vanilla Ice, who was by this point very conscious of his fading career and trying to explicitly play to it. He performed "Ice Ice Baby" very early in his set, clearly as sort of a power move daring the audience to leave afterward. Some of them did, but to my surprise, most of them stuck around, joining in when the guy standing directly to my left started immediately shouting out his further request for ["Ninja Rap"](https://www.youtube.com/watch?v=Vx7dt0Wscpc), the song written solely for Vanilla Ice's brief cameo in the 1989 film [*Teenage Mutant Ninja Turtles II: The Secret of the Ooze*](https://en.wikipedia.org/wiki/Teenage_Mutant_Ninja_Turtles_II:_The_Secret_of_the_Ooze).

Wait, sorry, where were we? Oh yeah, "Ice Ice Baby." The decoded message can be found in the wall of text, but an interesting artifact that is easy to miss is that the message resulting from using a *lowercase* x as the key is `'cOOKING\x00mc\x07S\x00LIKE\x00A\x00POUND\x00OF\x00BACON`. The rest are all gibberish, so it should be easy to disambiguate using frequency analysis. Let's do that now.

First we'll need a list of the most common characters to aid in scoring the output text. There's really no reason why this needs to be wrapped in a function at this point except that it parallels the `ascii()` function above. It sure feels clean though.

```python
def common():
  """Return a list of the most common characters in English text."""
  return list('etaoin shrdlu')
```
One mistake I made here in an earlier version was that I checked the letters *but not the space*. That screwed up the frequency analysis and resulted in one of the gibberish strings coming out on top. Spaces are an important part of language. 

Now, given a string, count the number of letters -- er, characters, rather, since we are including the space -- which are in the common set.

```python
def count_common_characters(str):
  """Count common characters in a string."""
  count = 0
  for character in common():
    if str.find(character) != -1:
      count = count + str.count(character)
  return count
```

Count the common characters in all decoded strings and pick the version that has the most common characters.

Dictionary comprehensions are so slick! Python is full of uniquely delightful constructs.

```python
def select_message(results):
  """Identify the most likely candidate from a list of decoded strings."""
  # dictionary comprehensions!
  counts = {item.get('key'): count_common_characters(item.get('message').lower()) for item in results}
  key = max(counts.items(), key=lambda k: k[1])
  matches = [item for item in results if item.get('key') == key[0]]
  return matches[0]
```

Now the test to see if we have done this properly. Since at this point I've successfully decoded the hidden message while tinkering around in search of a solution, and in fact actually spotted it *visually* even before I'd written the `select_message()` function, I am actually *hard coding* the message in the `test()` function. The reason for this is that it gives us something to `test` against; short of a *second* language heuristic, this is the only way to know for certain that we've successfully decoded the message and it allows the `test()` function to be, well, test-like, with an assertion that could fail.

But it won't fail, because this implementation is sound. Watch:  

```python
def test():
  """Test challenge 3."""
  print('Challenge 3 - Single-byte XOR cipher')
  encoded = '1b37373331363f78151b7f2b783431333d78397828372d363c78373e783a393b3736'
  messages = [decode_message(encoded, key) for key in ascii()]
  result = select_message(messages)
  assert result.get('message') == "Cooking MC's like a pound of bacon", 'decoded message does not match expected string'
  print('key ' + result.get('key') + ' produces "' + result.get('message') + '"')
  return result
```

Run the test function. If everything here worked, the console should print the key and the resulting decoded message.

```python
if __name__ == "__main__":
  test()
```
