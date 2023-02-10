# shellChatGPT

Shell wrapper for OpenAI API for ChatGPT and DALL-E.

## Features

- GPT chat from the command line
- Follow up conversations
- Generate images from text input
- Generate variations of images
- Set the model to interact with
- Converts base64 JSON data to PNG image at `$HOME/Downloads`
- Convert and upload images for variations
- Set temperature, number of results and any available model


```
% chatgpt.sh  What are the best Linux distros\?
Prompt: 6 words; Max tokens: 1024
######################################## 100.0%
Object: text_completion
Model_: text-davinci-003
Usage_: 8 + 52 = 60 tokens


1. Ubuntu
2. Linux Mint
3. Debian
4. Fedora
5. openSUSE
6. Arch Linux
7. Manjaro
8. elementary OS
9. Zorin OS
10. Solus
```

## Getting Started

### Required packages

- Free [OpenAI GPTChat key](https://beta.openai.com/account/api-keys)
- Ksh or Bash
- cURL
- JQ (optional)
- Imagemagick (optional)

### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.

## Usage

- Set your OpenAI API key with option `-k [KEY]` or environment variable `$OPENAI_KEY`
- Just write your prompt after the script name `chatgpt.sh`
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set option `-m [MODEL_NAME]`
- Some models require a \`prompt' while others \`instructions' and \`input'
- To generate images, set option -i and write your prompt
- Make a variation of an image, set -i and an image path for upload

