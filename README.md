# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E and Whisper.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)


## Features

- Text and chat completions.
- _Insert mode_ of text completions.
- _Follow up_ conversations, _preview/regenerate_ responses
- Manage _sessions_, _continue_ from last session, print last session.
- Integration with [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts)
- _Generate images_ from text input
- _Generate variations_ of images
- _Edit images_, easily generate an alpha mask
- _Transcribe audio_ from various languages
- _Translate audio_ into English text
- Record prompt voice, hear the answer back from the AI (pipe to voice synthesiser)
- Choose amongst available models
- Lots of command line options
- Converts base64 JSON data to PNG image
- Should™ work on Linux, FreeBSD, MacOS, and [Termux](#termux-users).


## ✨ Getting Started

### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.


### Required packages

- Free [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
- Bash or Zsh <!-- [Ksh93u+](https://github.com/ksh93/ksh), Bash or Zsh -->
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
- Optionally, set `$CHATGPTRC` with path to the configuration file. Defaults = `~/.chatgpt.conf`.


## Examples

![Chat cmpls with prompt confirmation](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls_verb.gif)


### Text Completions

One-shot text completion:

    chatgpt.sh "Hello there! What is your name?"

Text completion with Curie model:

    chatgpt.sh -m'text-curie-001' "Hello there! What is your name?"
    chatgpt.sh -m1 "List biggest cities in the world."

_For better results,_ ***set an instruction/system prompt***:
    
    chatgpt.sh -S'You are an AI assistant.'  "List biggest cities in the world."


### Insert Mode of Text Completions


Set options `-q` to enable insert mode and add the
string `[insert]` where the model should insert text:

    chatgpt.sh -q 'It was raining when [insert] tomorrow.'

[Insert mode](https://openai.com/blog/gpt-3-edit-insert)
works with `davinci`, `text-davinci-002`, and `text-davinci-003`.


## Chat Mode of Text Completions

With `option -c`, some options are set automatically to create a chat bot with text completions.

    chatgpt.sh -c "Hello there! What is your name?"


Create the **Marv, the sarcastic bot** manually:

    chatgpt.sh -CCu -60 --frequency-penalty=0.5 --temp=0.5 --top_p=0.3 --restart-seq='\nYou: ' --start-seq='\nMarv:' --stop='You:' --stop='Marv:' -S'Marv is a chatbot that reluctantly answers questions with sarcastic responses:'

_Tip:_ set `-VV` to see the actual request body and how options are set!


Complete text in multi-turn:

    chatgpt.sh -CC -S'The following is a newspaper article.' "It all starts when FBI agents arrived at the governor house and  "


## Native Chat Completions

Start a new session in chat mode, and set a different temperature:

    chatgpt.sh -cc -t0.7

Chat mode in text editor (visual) mode. Edit initial input:

    chatgpt.sh -ccx "Complete the story: Alice visits Bob. John arrives .."


### Awesome Prompts

Set a prompt from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts):

    chatgpt.sh -cc -S /linux_terminal



Some other good prompts to start a chat with include:


    chatgpt.sh -cc -S'You are a professional psicologist.' 

    chatgpt.sh -cc -S'You are a professional software programmer.'

    chatgpt.sh -cc -S'You are a post-graduation teacher and will do various activities related to preparing and elaborating a Philosophy course.'


*Obs: in this case, instructions (or system prompt) may refer to both
**user** and **assistant** roles, so behave like one.


<!--
_TIP:_ When using Ksh, press the up arrow key once to edit the _full prompt_
(see note on [shell interpreters](#shell-interpreters)).
-->


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

The script can be run with either Bash, or Zsh.

There should be equivalency of features under Bash, and Zsh.

Zsh is much faster than Bash in respect to some features.

<!--
Although it should be noted that I test the script under Ksh and Zsh,
and it is almost never tested under Bash, but so far, Bash seems to be
a little more polised than the other shells [AFAIK](https://github.com/mountaineerbr/shellChatGPT/discussions/13),
specially with interactive features.

Ksh truncates input at 80 chars when re-editing a prompt. A workaround
with this script is to press the up-arrow key once to edit the full prompt.

Ksh will mangle multibyte characters when re-editing input. A workaround
is to move the cursor and press the up-arrow key once to unmangle the input text.

Zsh cannot read/load a history file in non-interactive mode,
so only commands of the running session are available for retrieval in
new prompts (with the up-arrow key).

See [BUGS](https://github.com/mountaineerbr/shellChatGPT/tree/main/man#bugs)
in the man page.
-->
<!-- [Ksh93u+](https://github.com/ksh93/ksh) (~~_avoid_ Ksh2020~~), -->


<!--
## Arch Linux Users

There is a [*PKGBUILD*](PKGBUILD) file available to install the package
in Arch Linux and derivative distros (I am still perfecting the PKGBUILD
but it should work fine).
-->


## Termux Users

To run `tiktoken` with `option -T`, be sure to have your system
updated and installed with `python`, `rust`, and `rustc-dev` packages
for building python `tiktoken`.

```
$ pkg update
$ pkg upgrade
$ pkg install python rust rustc-dev
$ pip install tiktoken
```

<!--
Users of Termux may have some difficulty compiling the original Ksh93 under Termux.
As a workaround, use Ksh emulation from Zsh. To make Zsh emulate Ksh, simply
add a symlink to `zsh` under your path with the name `ksh`.

After installing Zsh in Termux, create a symlink with:

````
ln -s /data/data/com.termux/files/usr/bin/zsh /data/data/com.termux/files/usr/bin/ksh
````
-->


## Project Objectives

- Implement most features available from OpenAI API
- Provide the closest API defaults
- Let the user customise defaults (homework)


## Distinct Features

- Run as **single** or **multi-turn**.
- **Text editor** *interface*, and **single** and **multiline** *prompters*. 
- Manage **sessions** and history files.
- Run chat commands with _operator_ `!` or `/`.
- In chat mode, edit live history entries with command `!hist`.
- Add operator forward slash `/` to the end of prompt to trigger completions **preview mode**.
- One can regenerate a response typing in a new prompt a single slash `/`.
- Set or search prompts from [awesome-chatgpt-prompts](https://github.com/f/awesome-chatgpt-prompts) with `-S /prompt_name`
- Set clipboard with the latest response with `option -o`.
- Hopefully, default colours are colour-blind friendly.

_For a simple python wrapper for_ tiktoken, _see_ [tkn-cnt.py](https://github.com/mountaineerbr/scripts/blob/main/tkn-cnt.py).

## Limitations

OpenAI **API v1** is the focus of the present project implementation.
New versions of the API may not be implemented. I would rather fix bugs
of existing features than incorporate new ones.

See also BUGS section in the script [help page](man/README.md).


## HELP PAGE 

Read the markdown [**help page here**](man/README.md).

Alternatively, an updated help page can be printed with `chatgpt.sh -h`.

