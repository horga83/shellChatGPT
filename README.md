# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E and Whisper.


## Features

- GPT chat from the command line
- Follow up conversations, preview/regenerate responses
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


## Distinct Features

- In chat mode, chat commands run with *operator* `!` or `/`,
such as `!new` to start new session, `!temp 0.9` to set temperature,
`!max 2048` to set max tokens,
`!log ~/chat.log` to set a readable chat log, and so on
- In chat mode, edit history entries with command `!hist`,
delete or comment them out with `#` to update context on the run
- Add operator slash `/` to the end of prompt (as last character) to trigger completions *preview mode*
- One can regenerate a response typing in a new prompt a single slash `/`.
- Hopefully, default colours are colour-blind friendly


## Help page

An updated help page can be printed with `chatgpt.sh -h`.
Alternatively, check the script head source code for the help page.

---

---

### NAME

    chatgpt.sh -- ChatGPT / DALL-E / Whisper  Shell Wrapper


### SYNOPSIS

    chatgpt.sh [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT|TXT_FILE]
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


### DESCRIPTION

All positional arguments are read as a single PROMPT. If the
chosen model requires an INSTRUCTION and INPUT prompts, first
positional argument is taken as INSTRUCTION and the following
ones as INPUT or PROMPT.

Set option -c to start the chat mode via the text completions
and record the conversation. This option accepts various
models, defaults to `text-davinci-003` if none set.

Set option -cc to start the chat mode via native chat completions
and use the turbo models. While in chat mode, some options are
automatically set to un-lobotomise the bot.

Set -C to resume from last history session. Setting -CC starts
new session and history, but does not set any extra options.

If a plain text file path is set as first positional argument,
it is loaded as text PROMPT (text cmpls, chat cmpls, and text/code
edits).

Option -S sets an INSTRUCTION prompt (the initial prompt) for
text cmpls, chat cmpls, and text/code edits. A text file path
may be supplied as the single argument.

Option -e sets the `text edits` endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. User may choose a model amongst
the `edit` model family.

Option -i generates images according to text PROMPT. If the first
positional argument is an image file, then generate variations of
it. If the first positional argument is an image file and the second
a mask file (with alpha channel and transparency), and a text prompt
(required), then edit the image according to mask and prompt.
If mask is not provided, image must have transparency.

Optionally, size of output image with may be set with [S]mall,
[M]edium or [L]arge as the first positional argument. See IMAGES
section below for more information on inpaint and outpaint.

Option -w transcribes audio from mp3, mp4, mpeg, mpga, m4a, wav,
and webm files. First positional argument must be an audio file.
Optionally, set a two letter input language (ISO-639-1) as second
argument. A prompt may also be set after language (must be in the
same language as the audio).

Option -W translates audio stream to English text. A prompt in
English may be set to guide the model as the second positional
argument.

Combine -wW with -cc to start chat with voice input (whisper)
support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

User configuration is kept at `~/.chatgpt.conf`.
Script cache is kept at `~/.cache/chatgptsh`.

A personal (free) OpenAI API is required, set it with -K. Also,
see ENVIRONMENT section.

Long option support, as `--chat`, `--temp=0.9`, `--max=1024+512`,
`--presence-penalty=0.6`, and `--log=~/log.txt` is experimental.

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.



### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable `<|endoftext|>`,
or other stop sequences (stops may be set with -s).

Language model SKILLS can activated, with specific prompts,
see <https://platform.openai.com/examples>.


#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set option -c to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models.

##### 2.2 Native Chat Completions

Set the double option -cc to start chat cmpls mode. Turbo models
are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is `Q & A`. So, the `restart text`
`Q: ` and the `start text` `A:` must be injected
for the chat bot to work well with text cmpls.

Typing only a colon `:` at the start of the prompt causes it to
be appended after a newline to the last prompt (answer) in text
cmpls. If this trick is used with the initial prompt in text cmpls,
it works as the INSTRUCTION. In chat cmpls, setting a prompt with
`:` always sets it as a `system` message.

##### 2.4 Chat Commands

While in chat mode, the following commands preceeded by the operator
`!` (or `/`), can be typed in the new prompt to set the new parameter:

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
	-w   |  !rec      Start audio record.
	!r   |  !regen    renegerate last response.
	!q   |  !quit	  Exit.

Examples: `!temp 0.7`, `!mod1`, and `!-p 0.2`.

To change the chat context at run time, the history file must be
edited with `!hist`. Delete entries or comment them out with `#`.


##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before commiting it to history,
append a slash `/` to the prompt as the last character. Regen-
erate it again or press ENTER to accept it.

After a response has been written to the history file, regenerate
it with command `!regen` or type in a single slash in the new
empty prompt.


#### 3. Prompt Engineering and Design

Unless the chat options -c or -cc are set, _no_ instruction is
given to the language model (as would, otherwise, be the initial
prompt).

On chat mode, if no instruction is set, a short one is given,
and some options set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of
text cmpls, such as Curie, the best_of option may even be worth
setting (to 2 or 3).

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat compls models.

Certain prompts may return empty responses. Maybe the model has
nothing to further complete input or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, resetting tem-
perature or adding more text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing
spaces in its dictionary of tokens.

Note that the model's steering and capabilities require prompt
engineering to even know that it should answer the questions.

For more on prompt design, see:
<https://platform.openai.com/docs/guides/completion/prompt-design>
<https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


#### 4. Settings (Abridged)


See <https://platform.openai.com/docs/>.


### CODE COMPLETIONS

Codex models are discontinued. Use turbo models for coding tasks.

Turn comments into code, complete the next line or function in
context, add code comments, and rewrite code for efficiency,
amongst other functions.

Start with a comment with instructions, data or code. To create
useful completions it's helpful to think about what information
a programmer would need to perform a task. 


### TEXT EDITS

This endpoint is set with models with `edit` in their name or
option -e. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 


### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text description
of the desired image(s) is required. The maximum length is 1000
characters.


#### 2. Image Variations

Variations of a given image can be generated. The image to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


#### 3. Image Edits

Image and, optionally, a mask file must be provided. If mask is
not provided, image must have transparency, which will be used
as the mask. A text prompt is required.

##### 3.1 ImageMagick

If ImageMagick is available, input image and mask will be checked
and edited (converted) to fit dimensions and other requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with `-@[COLOUR]` to create the
mask. Defaults=black.

By defaults, the colour must be exact. Use the fuzz option to match
colours that are close to the target colour. This can be set with
`-@[VALUE%]` as a percentage of the maximum possible intensity,
for example `-@10%black`.

See also:

    <https://imagemagick.org/script/color.php>
    <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Alpha Channel

An alpha channel is generated with ImageMagick from any image
with the set transparent colour (defaults to black). In this way,
it is easy to make a mask with any black and white image as a
template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a mask and a prompt.
Out-painting can also be achieved manually with the aid of this
script. Paint a portion of the outer area of an image with alpha
or a defined colour which will be used as the mask, and set the
same colour in the script with -@. Choose the best result amongst
many results to continue the out-painting process step-wise.


Optionally, for all image generations, variations, and edits,
set size of output image with 256x256 (Small), 512x512 (Medium)
or 1024x1024 (Large) as the first positional argument. Defaults=S.


### AUDIO / WHISPER

#### 1. Transcriptions

Transcribes audio into the input language. Set a two letter
ISO-639-1 language as the second positional parameter. A prompt

may also be set as last positional parameter to help guide the
model. This prompt should match the audio language.

#### 2. Translations

Translates audio into into English. An optional text to guide
the model's style or continue a previous audio segment is optional
as last positional argument. This prompt should be in English.

Setting temperature has an effect, the higher the more random.


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


### BUGS

Instruction prompts are required for the model to even know that
it should answer questions.

Garbage in, garbage out.


### REQUIREMENTS

A free OpenAI API key.

Ksh93, Bash or Zsh. cURL.

JQ, ImageMagick, and Sox/Alsa-tools/FFmpeg are optionally required.


### OPTIONS

    -@ [[VAL%]COLOUR]
    	 Set transparent colour of image mask. Defaults=Black.
    	 Fuzz intensity can be set with [VAL%]. Defaults=0%.
    -NUM, -M [NUM][[+|-]NUM]
    	 Set maximum number of tokens. Response tokens can be set
    	 with a second NUMBER, (max. 2048 to 4000). Defaults=1024+256.
    -a [VAL] Set presence penalty  (cmpls/chat, -2.0 - 2.0).
    -A [VAL] Set frequency penalty (cmpls/chat, -2.0 - 2.0).
    -b [VAL] Set best of, VALUE must be greater than opt -n (cmpls).
    	 Defaults=1.
    -B 	 Print log probabilities to stderr (cmpls, 0 - 5).
    -c 	 Chat mode in text completions, new session.
    -cc 	 Chat mode in chat completions, new session.
    -C 	 Continue from last session (with -c, -cc, compls/chat).
    -e [INSTRUCT] [INPUT]
    	 Set Edit mode. Model Defaults=text-davinci-edit-001.
    -f 	 Don't read user config file.
    -h 	 Print this help page.
    -H 	 Edit history file with text editor.
    -i [PROMPT]
    	 Generate images given a prompt.
    -i [PNG_PATH]
    	 Create variations of a given image.
    -i [PNG_PATH] [MASK_PATH] [PROMPT]
    	 Edit image with mask and prompt (required).
    -j 	 Print raw JSON response (debug with -jVV).
    -k 	 Disable colour output. Defaults=Auto.
    -K [KEY] Set API key (free).
    -l [MODEL]
    	 List models or print details of MODEL. Set twice
    	 to print model indexes instead.
    -L [FILEPATH]
    	 Set log file. FILEPATH is required.
    -m [MODEL]
    	 Set model by NAME.
    -m [IND] Set model by INDEX number:
    	# COMPLETIONS             # EDITS
    	0.  text-davinci-003      8.  text-davinci-edit-001
    	1.  text-curie-001        9.  code-davinci-edit-001
    	2.  text-babbage-001      # AUDIO
    	3.  text-ada-001          11. whisper-1
    	# CHAT                    # GPT-4 
    	4. gpt-3.5-turbo          12. gpt-4
    	# MODERATION
    	6.  text-moderation-latest
    	7.  text-moderation-stable
    -n [NUM] Set number of results. Defaults=1.
    -p [VAL] Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).
    -r [SEQ] Set restart sequence string.
    -R [SEQ] Set start sequence string.
    -s [SEQ] Set stop sequences, up to 4. Defaults="<|endoftext|>".
    -S [INSTRUCTION|FILE]
    	 Set an instruction prompt. It may be a text file.
    -t [VAL] Set temperature value (cmpls/chat/edits/audio),
    	 (0.0 - 2.0, whisper 0.0 - 1.0). Defaults=0.9.
    -vv 	 Less verbose.
    -VV 	 Pretty-print request. Set twice to dump raw request.
    -x 	 Edit prompt in text editor.
    -w [AUD] [LANG]
    	 Transcribe audio file into text. LANG is optional.
    	 Set twice to get phrase-level timestamps. 
    -W [AUD] Translate audio file into English text.
    	 Set twice to get phrase-level timestamps. 
    -z 	 Print last response JSON data.
