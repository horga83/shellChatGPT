# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E and Whisper.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)


## Features

- GPT chat from the command line
- Follow up conversations, preview/regenerate responses
- Integration with [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
- Generate images from text input
- Generate variations of images
- Edit images, easily generate an alpha mask
- Transcribe audio from various languages
- Translate audio into English text
- Record prompt voice, hear the answer back from the AI
- Choose amongst available models
- Lots of command line options
- Converts base64 JSON data to PNG image
- Should™ work on Linux, FreeBSD, MacOS, and [Termux](#termux-users).


## ✨ Getting Started

### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.


### Required packages

- Free [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
- [Ksh93u+](https://github.com/ksh93/ksh), Bash or Zsh
- cURL, and JQ
- Imagemagick (optional)
- Base64 (optional)
- Sox/Arecord/FFmpeg (optional)


### Usage

- Set your OpenAI API key with option `-K [KEY]` or environment variable `$OPENAI_API_KEY`
- Just write your prompt after the script name `chatgpt.sh`
- Chat mode may be configured with Instruction or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set option `-m [MODEL_NAME]`
- Some models require a single `prompt` while others `instruction` and `input` prompts
- To generate images, set `option -i` and write your prompt
- Make a variation of an image, set -i and an image path for upload


## Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.
- Optionally, set `$CHATGPTRC` with path to the configuration file. Defaults = `~/.chatgptsh.conf`.


## Examples

![Chat cmpls with prompt confirmation](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_verb.gif)

### Text and Chat Completions

One-shot text completion:

    chatgpt.sh "Hello there! What is your name?"

Text completion with Curie model:

    chatgpt.sh -mtext-curie-001 "Hello there! What is your name?"
    chatgpt.sh -m1 "List biggest cities in the world."

_For better results,_ ***set an instruction/system prompt***:
    
    chatgpt.sh -m1 -S"You are an AI assistant."  "List biggest cities in the world."

Chat completion, _less verbose,_ and set temperature:

    chatgpt.sh -ccv -t0.7 "Hello there! What is your name?"

Text/chat completion, use visual editor instead of shell `read` or `vared` (reuse initial text from positional arguments):

    chatgpt.sh -cx "Alice was visiting Bob when John arrived  and"

### Awesome

Set a prompt from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts):

    chatgpt.sh -cc -S /linux_terminal


_TIP:_ When using Ksh, press the up arrow key once to edit the _full prompt_.

_OBS:_ See note on [shell interpreters](#shell-interpreters).


### Text Edits

Choose an `edit` model or set `option -e` to use this endpoint.
Two prompts are accepted, an instruction prompt and
an input prompt (optional):

    chatgpt.sh -e "Fix spelling mistakes" "This promptr has spilling mistakes."
    chatgpt.sh -e "Shell code to move files to trash bin." ""

Edits works great with INSTRUCTION and an empty prompt (e.g. to create
some code based on instruction only).


### Image Generations

Generate image according to prompt:

    chatgpt.sh -i "Dark tower in the middle of a field of red roses."
    chatgpt.sh -i "512x512" "A tower."


### Image Variations

Generate image variation:

    chatgpt.sh -i path/to/image.png


### Image Edits

    chatgpt.sh -i path/to/image.png path/to/mask.png "A pink flamingo."


#### Outpaint - make a mask from the black colour:

![Showing off Image Edits - Outpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits.gif)


#### Inpaint - add a bat in the night sky:

![Showing off Image Edits - Inpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits2.gif)

![Inpaint, steps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits_steps.png)


### Audio Transcriptions / Translations

Generate transcription from audio file:

    chatgpt.sh -w path/to/audio.mp3
    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."

Generate transcription from voice recording, set Portuguese as input language:

    chatgpt.sh -w pt

Translate audio file or voice recording in any language to English:

    chatgpt.sh -W [audio_file]
    chatgpt.sh -W

Transcribe audio and print timestamps option `-ww`:

    chatgpt.sh -ww pt audio_in.mp3
    
![Transcribe audio with timestamps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_trans.jpg)


### Voice + Chat Completions

Chat completion with voice as input:

    chatgpt.sh -ccw

Chat in Portuguese with voice in and voice out (pipe output to voice synthesiser):

    chatgpt.sh -ccw pt | espeakng -v pt-br
    chatgpt.sh -ccw pt | termux-tts-speak -l pt -n br


### Code Completions (Codex)

Codex models are discontinued. Use davinci models or gpt-3.5+.

Start with a commented out code or instruction for the model,
or ask it in comments to optimise the following code, for example.


## Prompts

Unless the chat `option -c` or `-cc` are set, _no_ instruction is
given to the language model. On chat mode, if no instruction is set,
a short one is given, and some options set, such as increasing temp and presence
penalty, in order to un-lobotomise the bot.

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat completions models.

Note that the model's steering and capabilities require prompt engineering
to even know that it should answer the questions.


## Shell Interpreters

The script can be run with either [Ksh93u+](https://github.com/ksh93/ksh) (~~_not_ Ksh2020~~),
Zsh and Bash. If the defaults
interpreter is not available in your system, run the script
such as `bash ./chatgpt.sh` (consider adding an alias in your rc file).

There should be equivalency of features under Bash, Ksh and Zsh.

The _reccomended interpreter_ is _Bash_, followed by Ksh and then Zsh.
Although it should be noted that I test the script under Ksh and Zsh,
and it is almost never tested under Bash, but so far, Bash seems to be
a little more polised than the other shells AFAIK,
specially with interactive features.

Ksh truncates input at 80 chars when re-editing a prompt. A workaround
with this script is to press the up-arrow key once to edit the full prompt.

Ksh will mangle multibyte characters when re-editing input. A workaround
is to move the cursor and press the up-arrow key once to unmangle the input text.

Zsh cannot read a history file unless started in interactive mode,
so only commands of the running session are available for retrieval in
new prompts (with the up-arrow key).


<!--
## Arch Linux Users

There is a [*PKGBUILD*](PKGBUILD) file available to install the package
in Arch Linux and derivative distros (I am still perfecting the PKGBUILD
but it should work fine).
-->

## Termux Users

Users of Termux may have some difficulty compiling the original Ksh93 under Termux.
As a workaround, use Ksh emulation from Zsh. To make Zsh emulate Ksh, simply
add a symlink to `zsh` under your path with the name `ksh`.

After installing Zsh in Termux, create a symlink with:

````
ln -s /data/data/com.termux/files/usr/bin/zsh /data/data/com.termux/files/usr/bin/ksh
````


## Project Objectives

- Implement most features available from OpenAI API
- Provide the closest API defaults
- Let the user customise defaults (homework)


## Distinct Features

- In chat mode, chat commands run with *operator* `!` or `/`,
such as `!new` to start new session, `!temp 0.9` to set temperature,
`!max 2048` to set max tokens, `!log ~/chat.log` to set a readable chat log, and so on.
- In chat mode, edit history entries with command `!hist`,
delete or comment them out with `#` to update context on the run.
- In chat mode, end a line with a backslash to type in a new line.
- Add operator forward slash `/` to the end of prompt (as last character) to trigger completions *preview mode*.
- One can regenerate a response typing in a new prompt a single slash `/`.
- Set or search prompts from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts) with `-S /prompt_name`
- Hopefully, default colours are colour-blind friendly.


## Limitations

OpenAI **API v1** is the focus of the present project implementation.
New versions of the API may not be implemented. I would rather fix bugs
of existing features than incorporate new ones.

See also BUGS section in the script [help page](man/README.md).


## HELP PAGE 

Read the markdown [**help page here**](man/README.md).

Alternatively, an updated help page can be printed with `chatgpt.sh -h`.

