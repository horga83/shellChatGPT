# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E and Whisper.


## Features

- GPT chat from the command line
- Follow up conversations
- Generate images from text input
- Generate variations of images
- Edit images, easily generate an alpha mask
- Transcribe audio from various languages
- Translate audio into English text
- Record prompt voice, hear the answer back from the AI
- Choose amongst available models
- Lots of command line options
- Converts base64 JSON data to PNG image
- Should™ work on Linux, FreeBSD, MacOS, and Termux.


![Showing off Chat Completions](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/chat_cpls.gif)


## ✨ Getting Started

### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.

### Required packages

- Free [OpenAI GPTChat key](https://platform.openai.com/account/api-keys)
- Ksh93, Bash or Zsh
- cURL
- JQ (optional)
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
- Set `$CHATGPTRC` with path to the configuration file. Defaults = `~/.chatgptsh.conf`.


## Examples

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

Outpaint - edit image, make a mask from the black colour:

![Showing off Image Edits - Outpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits.gif)


Inpaint - add a bat in the night sky:

![Showing off Image Edits - Inpaint](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits2.gif)

![Inpaint, steps](https://gitlab.com/mountaineerbr/etc/-/raw/main/gfx/img_edits_steps.png)


### Audio Transcriptions / Translations

Generate transcription from audio file:

    chatgpt.sh -w path/to/audio.mp3
    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."

Generate transcription from voice recording, set Portuguese as input language:

    chatgpt.sh -w pt

Translate audio file or voice recording in any language to English.

    chatgpt.sh -W [audio_file]
    chatgpt.sh -W

### Voice + Chat Completions

Chat completion with voice as input:

    chatgpt.sh -ccw

Chat in Portuguese with voice in and voice out (pipe output to voice synthesiser):

    chatgpt.sh -ccw pt | espeakng -v pt-br
    chatgpt.sh -ccw pt | termux-tts-speak -l pt -n br


### Code Completions (Codex)

Choose a `code` model to use this endpoint. Start with a commented out
code or instruction for the model, or ask it in comments
to optimise the following code, for example.


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

The script can be run with either Ksh93, Zsh nd Bash. If the defaults
interpreter is not available in your system, run the script
such as `bash ./chatgpt.sh` (consider adding an alias in your rc file).

There should be equivalency of features under Ksh, Zsh, and Bash.

However,
Zsh cannot read a history file unless started in interactive mode,
so only commands of the running session are available for retrieval in
new prompts (with an up-arrow key stroke).

## Termux Users

Users of Termux may have some difficulty compiling the oficial Ksh93 under Termux.
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


<!--
In Zsh, and Bash, the preview mode (preview completions without writing to history file)
can be triggered with double `CTRL-D` instead of appending a slash `/` at the end of
the prompt before pressing `ENTER`.
-->

## Distinct Features

- In chat mode, run command with operator `!` or `/`
- On chat mode, edit history entries with command `!hist`, delete or comment them out with `#`
- Code completions work with chat mode option `-c`
- Hopefully, default colours are colour-blind friendly

<!--
- Mini-edit with `::`, append text to previous completion from history
- Double `CTRL-D` to preview a completion before commiting to history (Zsh and Bash)
-

-->

## Help page

An updated help page can be printed with `chatgpt.sh -h`.
Alternatively, check the script head source code for the help page.

---

### NAME

    chatgpt.sh -- ChatGPT / DALL-E / Whisper  Shell Wrapper


### SYNOPSIS

    chatgpt.sh [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
    chatgpt.sh [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTION] [INPUT]
    chatgpt.sh -e [opt] [INSTRUCTION] [INPUT]
    chatgpt.sh -i [opt] [S|M|L] [PROMPT]
    chatgpt.sh -i [opt] [S|M|L] [PNG_FILE]
    chatgpt.sh -i [opt] [S|M|L] [PNG_FILE] [MASK_FILE] [PROPMT]
    chatgpt.sh -w [opt] [AUDIO_FILE] [LANG] [PROMPT-LANG]
    chatgpt.sh -W [opt] [AUDIO_FILE] [PROMPT-EN]
    chatgpt.sh -ccw [opt] [LANG]
    chatgpt.sh -ccW [opt]
    chatgpt.sh -l [MODEL_NAME]



#### 3. Chat Commands

While in chat mode the following commands (and a value), can be
typed in the new prompt (e.g. `!temp0.7`, `!mod1`):

	!NUM |  !max 	  Set maximum tokens.
	-a   |  !pre 	  Set presence.
	-A   |  !freq 	  Set frequency.
	-c   |  !new 	  Start new session.
	-H   |  !hist 	  Edit history.
	-L   |  !log 	  Save to log file.
	-m   |  !mod 	  Set model by index number.
	-p   |  !top 	  Set top_p.
	-t   |  !temp 	  Set temperature.
	-v   |  !ver	  Set/unset verbose.
	-x   |  !ed 	  Set/unset text editor.
	!q   |  !quit	  Exit.

To change the chat context at run time, the history file must be
edited with `!hist`. Delete entries or comment them out with `#`.



### ENVIRONMENT

    CHATGPTRC 	Path to user chatgpt.sh configuration.
    	Defaults=~/.chatgpt.conf
    
    INSTRUCTION 	Initial instruction set for the chatbot.
    
    OPENAI_API_KEY
    OPENAI_KEY 	Set your personal (free) OpenAI API key.
    
    REC_CMD 	Audio recording command.
    
    VISUAL
    EDITOR 		Text editor for external prompt editing.
		Defaults=vim



### OPTIONS

    -@ [[VAL%]COLOUR]
    	 Set transparent colour of image mask. Defaults=black.
    	 Fuzz intensity can be set with [VAL%]. Defaults=0%.
    -NUM 	 Set maximum tokens. Defaults=1024. Max=4096.
    -a [VAL] Set presence penalty  (cmpls/chat, unset, -2.0 - 2.0).
    -A [VAL] Set frequency penalty (cmpls/chat, unset, -2.0 - 2.0).
    -b 	 Print log probabilities (cmpls, unset, 0 - 5).
    -c 	 Chat mode in text completions, new session.
    -cc 	 Chat mode in chat completions, new session.
    -C 	 Continue from last session (with -cc, compls/chat).
    -e [INSTRUCT] [INPUT]
    	 Set Edit mode. Model Defaults=text-davinci-edit-001.
    -f 	 Skip sourcing user configuration file.
    -h 	 Print this help page.
    -H 	 Edit history file with text editor.
    -i [PROMPT]
    	 Generate images given a prompt.
    -i [PNG_PATH]
    	 Create variations of a given image.
    -i [PNG_PATH] [MASK_PATH] [PROMPT]
    	 Edit image according to mask and prompt.
    -j 	 Print raw JSON response (debug with -jVV).
    -k 	 Disable colour output, otherwise auto.
    -K [KEY] Set API key (free).
    -l [MODEL]
    	 List models or print details of a MODEL.
    -L [FILEPATH]
    	 Set a logfile. Filepath is required.
    -m [MODEL]
    	 Set a model name, check with -l. Model name is optional.
    -m [NUM] Set model by index NUM:
    	  # Completions           # Moderation
    	  0.  text-davinci-003    6.  text-moderation-latest
    	  1.  text-curie-001      7.  text-moderation-stable
    	  2.  text-babbage-001    # Edits                  
    	  3.  text-ada-001        8.  text-davinci-edit-001
    	  # Codex                 9.  code-davinci-edit-001
    	  4.  code-davinci-002    # Chat
    	  5.  code-cushman-001    10. gpt-3.5-turbo
    -n [NUM] Set number of results. Defaults=1.
    -p [VAL] Set top_p value, nucleus sampling (cmpls/chat),
    	 (unset, 0.0 - 1.0).
    -S [INSTRUCTION|FILE]
    	 Set an instruction prompt.
    -t [VAL] Set temperature value (cmpls/chat/edits/audio),
    	 (0.0 - 2.0, whisper 0.0 - 1.0). Defaults=0.
    -vv 	 Less verbose.
    -VV 	 Pretty-print request body. Set twice to dump raw.
    -x 	 Edit prompt in text editor.
    -w [AUD] [LANG]
    	 Transcribe audio file into text.
    -W [AUD]	 
    	 Translate audio file into English text.
    -z 	 Print last response JSON data.

