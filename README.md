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


![Showing off Chat Completions](gfx/chat_cpls.gif)


## Getting Started

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
- Chat mode may be configured with Instructions or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set option `-m [MODEL_NAME]`
- Some models require a `prompt` while others `instructions` and `input`
- To generate images, set option -i and write your prompt
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

Use the `edits` endpoint, this option requires two or more prompts,
instructions (required) and the proper (optional):

    chatgpt.sh -e "Fix spelling mistakes" "This promptr has spilling mistakes."
    chatgpt.sh -e "Shell code to move files to trash bin." ""

Edits works great with INSTRUCTION and an empty prompt (e.g. to create
some code based on instructions only).


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

![Showing off Image Edits - Outpaint](gfx/img_edits.gif)


Inpaint - add a bat in the night sky:

![Showing off Image Edits - Inpaint](gfx/img_edits2.gif)

![Inpaint, steps](gfx/img_edits_steps.png)


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


## Prompts

Unless the chat option -c or -cc are set, _no_ instruction is
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
As a workaround, use Ksh emulation from Zsh. To make Zsh is ksh, simply
add a symlink of `zsh` under your path with the name `ksh`.

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
<!--

## Distinct Features

- Chat mode command operator is either `!` or `/`
- Edit chat history on the run with `!hist`, comment entries with `#`
- Mini-edit with `::`, append text to previous completion from history
- Double `CTRL-D` to preview a completion before commiting to history (Zsh and Bash)
-

-->

## Help page

An updated help page can be printed with `chatgpt.sh -h`.
Below is a copy of it.

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


All positional arguments are read as a single PROMPT. If the
chosen model requires an INSTRUCTION and INPUT prompts, first
positional argument is taken as INSTRUCTION and the following
ones as INPUT or PROMPT.

Set option -c to start the chatbot via the text completion
endpoint and record the conversation. This option accepts various
models, defaults to `text-davinci-003` if none set.

Set option -cc to start the chatbot via native chat completions
and use the turbo models.

Set -C (with -cc) to resume from last history session.

Option -e sets the `edits` endpoint. That endpoint requires both
INSTRUCTION and INPUT prompts. User may choose a model amongst the `edit` model family.

Option -i generates images according to text PROMPT. If the first
positional argument is an image file, then generate variations of it.
If the first postional argument is an image file and the second a
mask file (with alpha channel and transparency), and optionally,
a text prompt, then edit the image according to mask and prompt.
If mask is not provided, image must have transparency, which will
be used as the mask. Optionally, set size of output image with
[S]mall, [M]edium or [L]arge as the first positional argument.
See IMAGES section below for more information on inpaint and outpaint.

Option -w transcribes audio from mp3, mp4, mpeg, mpga, m4a, wav,
and webm files. First positional argument must be an audio file.
Optionally, set a two letter input language (ISO-639-1) as second
argument. A prompt may also be set after language (must be in the
same language as the audio). Option -W translates audio to English
text and a prompt in English may be set to guide the model.

Combine -wW with -cc to start chat with voice input (whisper)
support. Output may be piped to a voice synthesiser such as
`espeakng`, to have full voice in and out.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

User configuration is kept at `~/.chatgpt.conf`.
Script cache is kept at `~/.cache/chatgptsh`.

A personal (free) OpenAI API is required, set it with -K or
see ENVIRONMENT section.

For complete model and settings information, refer to OPENAI
API docs at <https://beta.openai.com/docs/guides>.


### TEXT COMPLETIONS

#### 1. Text completion

Given a prompt, the model will return one or more predicted
completions. For example, given a truncated input, the language
model will try completing it. With specific instruction,
language model SKILLS can activated, see
<https://platform.openai.com/examples>.


#### 2. Chat Bot

##### 2.1 Text Completion Chat

Set option -c to start chat mode of text completion. It keeps a
history file and remembers the conversation follow-up, and works
with a variety of models.

##### 2.1.1 Q&A Format

The defaults chat format is `Q & A`. A name such as `NAME:`
may be introduced as interlocutor. Setting only `:` works as
an instruction prompt (or to add to the previous answer), send
an empty prompt or complete the previous answer prompt. See also
Prompt Design.

In the chat mode of text completion, the only initial indication 
a conversation is to begun is given with the `Q: ` interlocutor
flag. Without initial instructions, the first replies may return
lax but should stabilise on further promtps.

Alternatively, one may set an instruction prompt with the flag
`: [INSTRUCTION]` or with environment variable $INSTRUCTION.

##### 2.2 Native Chat Completions

Set option -cc to use the chat completions. If user starts a prompt
with `:`, message is set as `system` (very much like instructions)
else the message is sent as a question. Turbo models are also the
best option for many non-chat use cases and can be set to run a
single time setting -mgpt-3.5-turbo instead of -cc.


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


#### 4. Prompt Engineering and Design

Make a good prompt. May use bullets for multiple questions in
a single prompt. Write `act as [technician]`, add examples of
expected results.

Note that the model's steering and capabilities require prompt
engineering to even know that it should answer the questions.

For more on prompt design, see:

    <https://platform.openai.com/docs/guides/completion/prompt-design>
    <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


#### 5. Settings

Temperature 	number 	Optional 	Defaults to 0

Lowering temperature means it will take fewer risks, and
completions will be more accurate and deterministic. Increasing
temperature will result in more diverse completions.
Ex: low-temp:  We’re not asking the model to try to be creative
with its responses – especially for yes or no questions.

For more on settings, see <https://beta.openai.com/docs/guides>.


### TEXT EDITS

This endpoint is set with models with `edit` in their name
or option -e.

Editing works by specifying existing text as a prompt and an
instruction on how to modify it. The edits endpoint can be used
to change the tone or structure of text, or make targeted changes
like fixing spelling. We’ve also observed edits to work well on
empty prompts, thus enabling text generation similar to the
completions endpoint. 


### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text description
of the desired image(s). The maximum length is 1000 characters.


#### 2. Image Variations

Variations of a given image can be generated. The image to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


#### 3. Image Edits

Image and mask files must be provided. If mask is not provided,
image must have transparency, which will be used as the mask. A
text prompt is required for the edits endpoint to be used.

##### 3.1 ImageMagick

If ImageMagick is available, input image will be checked and edited
(converted) to fit dimensions and mask requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with -@[COLOUR] with colour specs
ImageMagick can understand. Defaults=black.

By default the colour must be exact. Use the fuzz option to match
colours that are close to the target colour. This can be set with
`-@[VALUE%]` as a percentage of the maximum possible intensity,
for example `-@10%black`.

See also:

    <https://imagemagick.org/script/color.php>
    <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Alpha Channel

And alpha channel is generated with ImageMagick from any image
with the set transparent colour (defaults to black). In this way,
it is easy to make a mask with any black and white image as a
template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a mask and a prompt.
Out-painting can be achieved manually with the aid of this script.
Paint a portion of the outer area of an image with a defined colour
which will be used as the mask, and set the same colour in the
script with -@. Choose the best result amongst many to continue
the out-painting process.


Optionally, for all image generations, variations, and edits,
set size of output image with 256x256 (Small), 512x512 (Medium)
or 1024x1024 (Large) as the first positional argument. Defaults=512x512.


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
Currently, only one audio model is available.


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


### LIMITS

For most models this is 2048 tokens, or about 1500 words).
Davici model limit is 4000 tokens (~3000 words) and for
turbo models it is 4096 tokens.

    Free trial users
    Text & Embedding        Codex          Edit        Image
                      20 RPM       20 RPM        20 RPM
                 150,000 TPM   40,000 TPM   150,000 TPM   50 img/min
        
    RPM 	(requests per minute)
    TPM 	(tokens per minute)



### BUGS

Certain prompts may return empty responses. Maybe the model has
nothing to further complete input or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, resetting tem-
perature or adding more text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing
spaces in its dictionary of tokens.

Instruction prompts are required for the model to even know that
it should answer the questions. See Prompt Design above.

Garbage in, garbage out.


### REQUIREMENTS

A free OpenAI GPTChat key. Ksh93, Bash or Zsh. cURL. JQ,
ImageMagick, and Sox/Alsa-tools/FFmpeg are optionally required.


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

