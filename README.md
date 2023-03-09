# shellChatGPT
Shell wrapper for OpenAI API for ChatGPT, DALL-E and Whisper.


## Features

- GPT chat from the command line
- Follow up conversations
- Generate images from text input
- Generate variations of images
- Record prompt voice, hear the answer back from the AI
- Choose amongst available models
- Lots of command line options
- Converts base64 JSON data to PNG image
- Should™ work on Linux, FreeBSD and MacOS.


```
% chatgpt.sh  What are the best Linux distros\?
Prompt: 6 words; Max tokens: 1024
######################################## 100.0%
Model_: text-davinci-003 (text_completion)
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
- Sox/Arecord/FFmpeg (optional)


### Installation

Just download the stand-alone `chatgpt.sh` and make it executable or clone this repo.


## Environment

- Set `$OPENAI_API_KEY` with your OpenAI API key.
- Set `$CHATGPTRC` with path to the configuration file. Defaults = `~/.chatgptsh.conf`.


## Usage

- Set your OpenAI API key with option `-k [KEY]` or environment variable `$OPENAI_KEY`
- Just write your prompt after the script name `chatgpt.sh`
- Chat mode may be configured with Instructions or not.
- Set temperature value with `-t [VAL]` (0.0 to 2.0), defaults=0.
- To set your model, run `chatgpt.sh -l` and then set option `-m [MODEL_NAME]`
- Some models require a `prompt` while others `instructions` and `input`
- To generate images, set option -i and write your prompt
- Make a variation of an image, set -i and an image path for upload

## Examples

One-shot text completion:

    chatgpt.sh "Hello there! What is your name?"

Text completion with Curie model:

    chatgpt.sh -mtext-curie-001 "Hello there! What is your name?"
    chatgpt.sh -m1 "List biggest cities in the world"

Chat completion, set temperature:

    chatgpt.sh -cc -t0.7 "Hello there! What is your name?"

Text/chat completion, use visual editor instead of shell `read` or `vared` (reuse initial text from positional arguments):

    chatgpt.sh -cx "Alice was visiting Bob when John arrived  "

Chat completion with voice as input:

    chatgpt.sh -ccw

Chat in portuguese with voice in and voice out (pipe output to voice synthesiser):

    chatgpt.sh -ccw pt | espeakng -v pt-br

Use the `edits` endpoint, this option requires two or more prompts,
instructions (required) and the proper (optional):

    chatgpt.sh -e "Fix spelling mistakes" "This promptr has spilling mistakes."
    chatgpt.sh -e "Shell code to move files to trash bin." ""

Generate image according to prompt:

    chatgpt.sh -i "Dark tower in the middle of a field of red roses."
    chatgpt.sh -i "512x512" "A tower."

Generate image variation:

    chatgpt.sh -i path/to/image.png

Generate transcription from audio file:

    chatgpt.sh -w path/to/audio.mp3
    chatgpt.sh -w path/to/audio.mp3 "en" "This is a poem about X."

Generate transcription from input record, set portuguese as input language:

    chatgpt.sh -w pt


## Help page

An updated help page can be printed with `chatgpt.sh -h`.
Below is a copy of it.

---

### NAME

	chatgpt.sh -- ChatGPT/DALL-E/Whisper Shell Wrapper


### SYNOPSIS

	chatgpt.sh [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	chatgpt.sh [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTION] [INPUT]
	chatgpt.sh -e [opt] [INSTRUCTION] [INPUT]
	chatgpt.sh -i [opt] [S|M|L] [PROMPT]
	chatgpt.sh -i [opt] [S|M|L] [INPUT_PNG_PATH]
	chatgpt.sh -l [MODEL_NAME]
	chatgpt.sh -w [opt] [AUDIO_FILE] [LANG] [PROMPT]
	chatgpt.sh -ccw [opt] [LANG]


All positional arguments are read as a single PROMPT. If the
chosen model requires an INSTRUCTION and INPUT prompts, first
positional argument is taken as INSTRUCTION and the following
ones as INPUT or PROMPT.

Set option -c to start the chatbot via the text completion
endpoint and record the conversation. This option accepts various
models, defaults to `text-davinci-003` if none set.

Set option -cc to start the chatbot via the chat endpoint and
use the turbo models.

Set -C (with -cc) to resume from last history session.

Option -e sets the `edits` endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. This option requires
setting an `edits model`.

Option -i generates images according to PROMPT. If first
positional argument is a picture file, then generate variation
of it. A size of output image may se set, such as S, M or L.

Option -w transcribes audio from mp3, mp4, mpeg, mpga, m4a, wav,
and webm files. First positional argument must be an audio file.
Optionally, set a two letter input language (ISO-639-1) as second
argument. A prompt may also be set after language (must be in the
same language as the audio).

Combine -w with -cc to start chat with voice input (whisper)
support. Output may be piped to a voice synthesiser such as
`espeakng`, to have full voice experience.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

User configuration is kept at `~/.chatgpt.conf`.
Script cache is kept at `~/.cache/chatgptsh`.

A personal (free) OpenAI API is required, set it with -k or
see ENVIRONMENT section.

For the skill list, see <https://platform.openai.com/examples>.

For complete model and settings information, refer to OPENAI
API docs at <https://beta.openai.com/docs/guides>.


### COMPLETIONS

Given a prompt, the model will return one or more predicted
completions. It can be used a chatbot.

Set option -c to enter text completion chat and keep a history
of the conversation and works with a variety of models.

Set option -cc to use the chat completion endpoint. Works the
same as the text completion chat (turbo models).

The defaults chat format is `Q & A`. A name such as `NAME:`
may be introduced as interlocutor. Setting only `:` works as
an instruction prompt, send an empty prompt or complete the
previous answer prompt.

While in chat mode, type in one of the following commands, and
a value in the new prompt (e.g. `!temp0.7`, `!mod1`):

	!NUM |  !max 	  Set maximum tokens.
	-a   |  !pre 	  Set presence.
	-A   |  !freq 	  Set frequency.
	-c   |  !new 	  Starts new session.
	-H   |  !hist 	  Edit history.
	-L   |  !log 	  Save to log file.
	-m   |  !mod 	  Set model by index number.
	-p   |  !top 	  Set top_p.
	-t   |  !temp 	  Set temperature.
	-v   |  !ver	  Set/unset verbose.
	-x   |  !ed 	  Set/unset text editor.
	!q   |  !quit	  Exit.


To change chat history, the history file must be edited with
`!hist`. Delete entries or comment them out with `#`.

Prompt Design
Make a good prompt. May use bullets for multiple questions in
a single prompt. Write `act as [technician]`, add examples of
expected results.

For the chatbot, the only initial indication given is a `Q: `
interlocutor flag. Without previous instructions, the first
replies may return lax but should stabilise on further promtps.

Alternatively, one may try setting initial instructions prompt
with the bot identity and how it should behave as, such as:

	prompt>	": The following is a conversation with an AI
		  assistant. The assistant is helpful, creative,
		  clever, and friendly."

	reply_> "A: Hello! How can I help you?"

	prompt> "Q: Hello, what is your name?"

Also see section ENVIRONMENT to set defaults chatbot instructions.
For more on prompt design, see:
<https://platform.openai.com/docs/guides/completion/prompt-design>
<https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>
 
 

    Settings
    Temperature 	number 	Optional 	Defaults to 1
    
    Lowering temperature means it will take fewer risks, and
    completions will be more accurate and deterministic. Increasing
    temperature will result in more diverse completions.
    Ex: low-temp:  We’re not asking the model to try to be creative
    with its responses – especially for yes or no questions.

For more on settings, see <https://beta.openai.com/docs/guides>.


### EDITS

This endpoint is set with models with `edit` in their name
or option -e.

Editing works by specifying existing text as a prompt and an
instruction on how to modify it. The edits endpoint can be used
to change the tone or structure of text, or make targeted changes
like fixing spelling. We’ve also observed edits to work well on
empty prompts, thus enabling text generation similar to the
completions endpoint. 


### IMAGES / DALL-E

The first positional parameter sets the output image size
256x256/Small, 512x512/Medium or 1024x1024/Large. Defaults=512x512.

An image can be created given a prompt. A text description of
the desired image(s). The maximum length is 1000 characters.

Also, a variation of a given image can be generated. The image
to use as the basis for the variation(s). Must be a valid PNG
file, less than 4MB and square. If Imagemagick is available,
input image will be converted to square before upload.


### AUDIO / WHISPER

Transcribes audio into the input language. May set a two letter
ISO-639-1 language as the second positional parameter. A prompt
may also be set after language to help the model.

Setting temperature has an effect. Currently, only one audio model
is available.


### ENVIRONMENT

    CHATGPTRC 	Path to user chatgpt.sh configuration.
			Defaults=~/.chatgpt.conf

	INSTRUCTION 	Initial instruction set for the chatbot.

	OPENAI_API_KEY
	OPENAI_KEY 	Set your personal (free) OpenAI API key.

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

Certain PROMPTS may return empty responses. Maybe the model has
nothing to add to the input prompt or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, or resetting
temperature or adding more text. See prompt design. Keep in mind
that prompts ending with a space character may result in lower-
quality output. This is because the API already incorporates
trailing spaces in its dictionary of tokens.

Language models are but a mirror of human written records, they
do not `understand` your questions or `know` the answers to it.
Garbage in, garbage out.


### REQUIREMENTS

A free OpenAI GPTChat key. Ksh93, Bash or Zsh. cURL. JQ, ImageMagick, Sox/Ffmpeg are optionally required.


### OPTIONS

	-NUM 		Set maximum tokens. Max=4096, defaults=1024.
	-a [VAL]	Set presence penalty  (completions; -2.0 - 2.0).
	-A [VAL]	Set frequency penalty (completions; -2.0 - 2.0).
	-c 		Chat mode in text completion, new session.
	-cc 		Chat mode in chat endpoint, new session.
	-C 		Continue from last session (with -cc).
	-e [INSTRUCT] [INPUT]
			Set Edit mode, model defaults=text-davinci-edit-001.
	-f 		Skip sourcing user configuration file.
	-h 		Print this help page.
	-H 		Edit history file with text editor.
	-i [PROMPT] 	Creates an image given a prompt.
	-i [PNG_PATH] 	Creates a variation of a given image.
	-j 		Print raw JSON response data (debug with -VVj).
	-k [KEY] 	Set API key (free).
	-l [MODEL] 	List models or print details of a MODEL.
	-L [FILEPATH] 	Set a logfile.
	-m [MODEL] 	Set a model name, check with -l.
	-m [NUM] 	Set model by index NUM:
		  # Completions           # Moderation
		  0.  text-davinci-003    6.  text-moderation-latest
		  1.  text-curie-001      7.  text-moderation-stable
		  2.  text-babbage-001    # Edits                  
		  3.  text-ada-001        8.  text-davinci-edit-001
		  # Codex                 9.  code-davinci-edit-001
		  4.  code-davinci-002    # Chat
		  5.  code-cushman-001    10. gpt-3.5-turbo
	-n [NUM] 	Set number of results. Defaults=1.
	-p [VAL] 	Set top_p value (0.0 - 1.0). Defaults=unset.
	-S [INSTR|FILE] Set an instructions prompt.
	-t [VAL] 	Set temperature value (0.0 - 2.0). Defaults=0.
	-vv 		Less verbose in chat mode.
	-VV 		Pretty-print request body. Set twice to dump raw.
	-x 		Edit prompt in text editor.
	-w 		Transcribe audio file.
	-z 		Print last response JSON data.
