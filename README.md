# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT and DALL-E.


## Features

- GPT chat from the command line
- Follow up conversations
- Set any of multiple models available.
- Generate images from text input
- Generate variations of images
- Choose amongst available models
- Lots of command line options
- Converts base64 JSON data to PNG image


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
- Ksh, Bash or Zsh
- cURL
- JQ (optional)
- Imagemagick (optional)
- Base64 (optional)

### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.


## Usage

- Set your OpenAI API key with option `-k [KEY]` or environment variable `$OPENAI_KEY`
- Just write your prompt after the script name `chatgpt.sh`
- Chat mode may be configured with Instructions or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set option `-m [MODEL_NAME]`
- Some models require a \`prompt' while others \`instructions' and \`input'
- To generate images, set option -i and write your prompt
- Make a variation of an image, set -i and an image path for upload


## Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.
- Set `$CHATGPTRC` with path to the configuration file. Defaults = `~/.chatgptsh.conf`.

