#!/usr/bin/env python
# tkn-count.py - Count tokens of text string
# Usage: tkn-count.py [MODEL|ENCODING] [TEXT|-]
# v0.1.3  april/2023  by mountaineerbr
import sys
import tiktoken

mod = "gpt-3.5-turbo"
fallback = "cl100k_base"
#davinci: r50k_base

#input, pos args or stdin
if (len(sys.argv) > 2) and (sys.argv[2] == "-"):
    text = sys.stdin.read()
    mod = sys.argv[1]
elif (len(sys.argv) > 1) and (sys.argv[1] == "-"):
    text = sys.stdin.read()
elif (len(sys.argv) > 2):
    text = " ".join(sys.argv[2:])
    mod = sys.argv[1]
elif (len(sys.argv) > 1):
    text = sys.argv[1]
else:
    sys.stderr.write("Usage: %s [MODEL|ENCODING] \"STRING\"\nSet \"-\" to read from stdin.\n" % (sys.argv[0].split("/")[-1]) )
    sys.exit(2)

#choose model encoding
try:
    enc = tiktoken.encoding_for_model(mod)
    sys.stderr.write("Model: %s %s\n" % (mod , enc) )
except:
    try:
        enc = tiktoken.get_encoding(mod)
        sys.stderr.write("Encoding: %s\n" % mod )
    except:
        sys.stderr.write("Warning: Model/encoding not found. Using %s.\n" % fallback)
        enc = tiktoken.get_encoding(fallback)

#
encoded_text = enc.encode_ordinary(text)
#encoded_text = enc.encode(text, disallowed_special=())

#print(encoded_text)
print(len(encoded_text))

#https://github.com/openai/tiktoken/blob/main/tiktoken/core.py
#https://github.com/openai/tiktoken/blob/main/tiktoken/model.py
#https://github.com/openai/openai-cookbook/blob/main/examples/How_to_count_tokens_with_tiktoken.ipynb
