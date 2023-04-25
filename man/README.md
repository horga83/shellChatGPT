---
author:
- mountaineerbr
date: April 2023
title: CHATGPT.SH(1) v0.12.14 \| General Commands Manual
---

### NAME

   chatgpt.sh – ChatGPT / DALL-E / Whisper Shell Wrapper

### SYNOPSIS

   **chatgpt.sh** \[`-m` \[*MODEL_NAME*\|*MODEL_INDEX*\]\] \[`opt`\]
\[*PROMPT\|TXT_FILE*\]  
   **chatgpt.sh** \[`-m` \[*MODEL_NAME*\|*MODEL_INDEX*\]\] \[`opt`\]
\[*INSTRUCTION*\] \[*INPUT*\]  
   **chatgpt.sh** `-e` \[`opt`\] \[*INSTRUCTION*\] \[*INPUT*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PROMPT*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]
\[*MASK_FILE*\] \[*PROPMT*\]  
   **chatgpt.sh** `-w` \[`opt`\] \[*AUDIO_FILE*\] \[*LANG*\]
\[*PROMPT-LANG*\]  
   **chatgpt.sh** `-W` \[`opt`\] \[*AUDIO_FILE*\] \[*PROMPT-EN*\]  
   **chatgpt.sh** `-ccw` \[`opt`\] \[*LANG*\]  
   **chatgpt.sh** `-ccW` \[`opt`\]  
   **chatgpt.sh** `-ll` \[*MODEL_NAME*\]

### DESCRIPTION

Complete INPUT text when run without any options (single-turn, pure text
completions).

Positional arguments are read as a single **PROMPT**. Model
**INSTRUCTION** is usually optional, however if it is mandatory for a
chosen model (such as edits models), then the first positional argument
is read as **INSTRUCTION** and the following ones as **INPUT** or
**PROMPT**.

Set `option -c` to start the chat mode via **text completions** and
record conversation. This option accepts various models, defaults to
*text-davinci-003* if none set.

Set `option -cc` to start the chat mode via **native chat completions**
and use turbo models. While in chat mode, some options are automatically
set to un-lobotomise the bot.

Set `option -C` to **resume** from last history session. Setting only
`option -CC` (without -cc) starts a multi-turn session in **pure text
completions**, and use restart and start sequences when defined.

Set model with “`-m` \[*NAME*\]” (full model name). Some models have an
equivalent *INDEX* as short-hand, so “`-m`*text-davinci-003*” and
“`-m`*0*” set the same model (list model by *NAME* with `option -l` or
by *INDEX* with `option -ll`).

Set *maximum response tokens* with `option` “`-`NUM” or “`-M` NUM”. This
defaults to 256 tokens in chat and single-turn modes.

*Model capacity* (max model tokens) can be set with a second *NUM* such
as “`-`*NUM,NUM*” or “`-M` NUM-NUM”, otherwise it is set automatically
to the capacity of known models, or to *2048* tokens as fallback.

If a plain text file path is set as first positional argument, it is
loaded as text PROMPT (text cmpls, chat cmpls, and text/code edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text
cmpls, chat cmpls, and text/code edits. A text file path may be supplied
as the single argument. If the argument to this option starts with a
backslash such as “`-S` \_/\_linux_terminal”, start search for an
awesome-chatgpt-prompts (by Fatih KA).

`Option -e` sets the **text edits** endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. User may choose a model amongst the
*edit model family*.

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an *IMAGE* file, then **generate variations** of
it. If the first positional argument is an *IMAGE* file and the second a
*MASK* file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** *IMAGE* according to *MASK* and PROMPT. If
*MASK* is not provided, *IMAGE* must have transparency.

Optionally, size of output image may be set with “\[*S*\]*mall*”,
“\[*M*\]*edium*” or “\[*L*\]*arge*” as the first positional argument.
See **IMAGES section** below for more information on **inpaint** and
**outpaint**.

`Option -w` **transcribes audio** from *mp3*, *mp4*, *mpeg*, *mpga*,
*m4a*, *wav*, and *webm* files. First positional argument must be an
*AUDIO* file. Optionally, set a *TWO-LETTER* input language
(*ISO-639-1*) as second argument. A PROMPT may also be set after
language (must be in the same language as the audio).

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional argument.

Combine `-wW` **with** `-cc` to start **chat with voice input**
(Whisper) support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

Stdin is supported when there is no positional arguments left after
option parsing. Stdin input sets a single PROMPT.

User configuration is kept at “*~/.chatgpt.conf*”. Script cache is kept
at “*~/.cache/chatgptsh*”.

A personal (free) OpenAI API is required, set it with `-K`. Also, see
**ENVIRONMENT section**.

For complete model and settings information, refer to OpenAI API docs at
<https://platform.openai.com/docs/>.

### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted completions.
For example, given a partial input, the language model will try
completing it until probable “`<|endoftext|>`”, or other stop sequences
(stops may be set with `-s`).

**Restart** and **start sequences** may be optionally set and are always
preceded by a new line.

To enable **multiline input**, type in a backslash “*\\*” as the last
character of the input line and press ENTER (backslash will be removed
from input), or set `option -u`. Once enabled, press ENTER twice to
confirm the multiline prompt. Useful to paste from clipboard, but empty
lines will confirm the prompt up to that point.

Language model **SKILLS** can activated, with specific prompts, see
<https://platform.openai.com/examples>.

#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps a
history file, and keeps new questions in context. This works with a
variety of models.

##### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo models
are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is “**Q & A**”. The **restart sequence**
“\n_Q: *” and the **start text** ”\n_A:*” are injected for the chat bot
to work well with text cmpls.

In native chat completions, setting a prompt with “*:*” as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon “*:*” at the start of the prompt causes the text
following it to be appended immediately to the last (response) prompt
text.

##### 2.4 Chat Commands

While in chat mode, the following commands can be typed in the new
prompt to set a new parameter. The command operator may be either “`!`”,
or “`/`”.

|        |            |                                       |
|-------:|:-----------|:--------------------------------------|
| `!NUM` | `!max`     | Set response tokens / model capacity. |
|   `-a` | `!pre`     | Set presence pensalty.                |
|   `-A` | `!freq`    | Set frequency penalty.                |
|   `-c` | `!new`     | Start new session.                    |
|   `-H` | `!hist`    | Edit history in editor.               |
|   `-L` | `!log`     | Save to log file.                     |
|   `-m` | `!mod`     | Set model (by index or name).         |
|   `-o` | `!clip`    | Copy responses to clipboard.          |
|   `-p` | `!top`     | Set top_p.                            |
|   `-r` | `!restart` | Set restart sequence.                 |
|   `-R` | `!start`   | Set start sequence.                   |
|   `-s` | `!stop`    | Set stop sequences.                   |
|   `-t` | `!temp`    | Set temperature.                      |
|   `-u` | `!multi`   | Toggle multiline prompter.            |
|   `-v` | `!ver`     | Toggle verbose.                       |
|   `-x` | `!ed`      | Toggle text editor interface.         |
|   `-w` | `!rec`     | Start audio record chat.              |
|   `!r` | `!regen`   | Renegerate last response.             |
|   `!q` | `!quit`    | Exit.                                 |

E.g.: “`!temp` *0.7*”, “`!mod`*1*”, and “`-p` *0.2*”.

To change the chat context at run time, the history file must be edited
with “`!hist`”. Delete history entries or comment them out with “`#`”.

##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before commiting it to history, append a
forward slash “*/*” to the prompt as the last character. Regenerate it
again or press ENTER to accept it.

After a response has been written to the history file, **regenerate** it
with command “`!regen`” or type in a single forward slash in the new
empty prompt.

#### 3. Prompt Engineering and Design

Very short **INSTRUCTION** to behave like a chatbot are given with
`options -ccCC`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, a short one is given, and some
options auto set, such as increasing temp and presence penalty, in order
to un-lobotomise the bot. With cheap and fast models of text cmpls, such
as Curie, the best_of option may be worth setting (to 2 or 3).

Prompt engineering is an art on itself. Study carefully how to craft the
best prompts to get the most out of text, code and chat compls models.

Certain prompts may return empty responses. Maybe the model has nothing
to further complete input or it expects more text. Try trimming spaces,
appending a full stop/ellipsis, resetting temperature, or adding more
text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing spaces in
its dictionary of tokens.

Note that the model’s steering and capabilities require prompt
engineering to even know that it should answer the questions.

For more on prompt design, see:

- <https://platform.openai.com/docs/guides/completion/prompt-design>
- <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>

See detailed info on settings for each endpoint at:

- <https://platform.openai.com/docs/>

### CODE COMPLETIONS

Codex models are discontinued. Use davinci or turbo models for coding
tasks.

Turn comments into code, complete the next line or function in context,
add code comments, and rewrite code for efficiency, amongst other
functions.

Start with a comment with instructions, data or code. To create useful
completions it’s helpful to think about what information a programmer
would need to perform a task.

### TEXT EDITS

This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify a
prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure of text,
or make targeted changes like fixing spelling. Edits work well on empty
prompts, thus enabling text generation similar to the completions
endpoint.

### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text PROMPT of the
desired image(s) is required. The maximum length is 1000 characters.

#### 2. Image Variations

Variations of a given *IMAGE* can be generated. The *IMAGE* to use as
the basis for the variations must be a valid PNG file, less than 4MB and
square.

#### 3. Image Edits

To edit an *IMAGE*, a *MASK* file may be optionally provided. If *MASK*
is not provided, *IMAGE* must have transparency, which will be used as
the mask. A text prompt is required.

##### 3.1 ImageMagick

If **ImageMagick** is available, input *IMAGE* and *MASK* will be
checked and processed to fit dimensions and other requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with “`-@`\[*COLOUR*\]” to create the
mask. Defaults=*black*.

By defaults, the *COLOUR* must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
“`-@`\[*VALUE%*\]” as a percentage of the maximum possible intensity,
for example “`-@`*10%black*”.

See also:

- <https://imagemagick.org/script/color.php>
- <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image with
the set transparent colour (defaults to *black*). In this way, it is
easy to make a mask with any black and white image as a template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this script.
Paint a portion of the outer area of an image with *alpha*, or a defined
*transparent* *colour* which will be used as the mask, and set the same
*colour* in the script with `-@`. Choose the best result amongst many
results to continue the out-painting process step-wise.

Optionally, for all image generations, variations, and edits, set **size
of output image** with “*256x256*” (“*Small*”), “*512x512*”
(“*Medium*”), or “*1024x1024*” (“*Large*”) as the first positional
argument. Defaults=*512x512*.

### AUDIO / WHISPER

#### 1. Transcriptions

Transcribes audio file or voice record into the input language. Set a
*two-letter* *ISO-639-1* language code (*en*, *es*, *ja*, or *zh*) as
the positional argument following the input audio file. A prompt may
also be set as last positional parameter to help guide the model. This
prompt should match the audio language.

#### 2. Translations

Translates audio into **English**. An optional text to guide the model’s
style or continue a previous audio segment is optional as last
positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.

### QUOTING AND SPECIAL SYMBOLS

The special sequences (`\b`, `\f`, `\n`, `\r`, `\t` and `\uHEX`) are
interpreted as quoted *backspace*, *form feed*, *new line*, *return*,
*tab* and *unicode hex*. To preserve these symbols as literals instead
(e. g. **Latex syntax**), type in an extra backslash such as
“`\\theta`”.

### ENVIRONMENT

**CHATGPTRC**  
Path to user chatgpt.sh configuration.

Defaults="*~/.chatgpt.conf*"

**INSTRUCTION**  
Initial instruction set for the chatbot.

**OPENAI_API_KEY**

**OPENAI_KEY**  
Set your personal (free) OpenAI API key.

**REC_CMD**  
Audio recording command.

**VISUAL**

**EDITOR**  
Text editor for external prompt editing.

Defaults="*vim*"

### BUGS

Changing models in the same session may generate token count errors
because the token count recorded in history file entries may differ
significantly from model to model (encoding).

With the exception of Davinci models, older models were designed to be
run as one-shot.

Instruction prompts are required for the model to even know that it
should answer questions.

Garbage in, garbage out. An idiot savant.

<!--
`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.
&#10;`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->

### REQUIREMENTS

A free OpenAI **API key**. `Bash`, `cURL`, and `JQ`.

`ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.

### LONG OPTIONS

The following options can be set with an argument, or multiple times
when appropriate.

> `--alpha`, `--api-key`, `--best`, `--best-of`, `--chat`,
> `--clipboard`, `--clip`, `--cont`, `--continue`, `--edit`, `--editor`,
> `--frequency`, `--frequency-penalty`, `--help`, `--hist`, `--image`,
> `--instruction`, `--last`, `--list-model`, `--list-models`, `--log`,
> `--log-prob`, `--max`, `--max-tokens`, `--mod`, `--model`,
> `--no-colour`, `--no-config`, `--presence`, `--presence-penalty`,
> `--prob`, `--raw`, `--restart-seq`, `--restart-sequence`, `--results`,
> `--resume`, `--start-seq`, `--start-sequence`, `--stop`, `--temp`,
> `--temperature`, `--tiktoken`, `--top`, `--top-p`, `--transcribe`,
> `--translate`, `--multi`, `--multiline`, and `--verbose`.

E.g.: “`--chat`”, “`--temp`=*0.9*”, “`--max`=*1024,128*”, and
“`--presence-penalty` *0.6*”.

### OPTIONS

**-@** \[\[*VAL%*\]*COLOUR*\]  
Set transparent colour of image mask. Def=*black*.

Fuzz intensity can be set with \[VAL%\]. Def=*0%*.

**-NUM**

**-M** \[*NUM*\[*-NUM*\]\]  
Set maximum number of `response tokens`. Def=*256*.

`Model capacity` can be set with a second number. Def=*auto-256*.

**-a** \[*VAL*\]  
Set presence penalty (cmpls/chat, -2.0 - 2.0).

**-A** \[*VAL*\]  
Set frequency penalty (cmpls/chat, -2.0 - 2.0).

**-b** \[*VAL*\]  
Set best of, must be greater than `option -n` (cmpls). Def=*1*.

**-B**  
Print log probabilities to stderr (cmpls, 0 - 5).

**-c**  
Chat mode in text completions, new session.

**-cc**  
Chat mode in chat completions, new session.

**-C**  
Continue from last session (compls/chat).

**-CC**  
Start new session of pure text compls (without -cc).

**-e** \[*INSTRUCTION*\] \[*INPUT*\]  
Set Edit mode. Model def=*text-davinci-edit-001*.

**-f**  
Ignore user config file and environment.

**-h**  
Print this help page.

**-H**  
Edit history file with text editor or pipe to stdout.

**-HH**  
Pretty print last history session to stdout.

With `-cC`, or `-rR`, prints with the specified restart and start
sequences.

**-i** \[*PROMPT*\]  
Generate images given a prompt.

**-i** \[*PNG*\]  
Create variations of a given image.

**-i** \[*PNG*\] \[*MASK*\] \[*PROMPT*\]  
Edit image with mask and prompt (required).

**-j**  
Print raw JSON response (debug with -jVV).

**-k**  
Disable colour output. Def=*auto*.

**-K** \[*KEY*\]  
Set API key (free).

**-l** \[*MOD*\]  
List models or print details of MODEL.

Set twice to print model indexes instead.

**-L** \[*FILEPATH*\]  
Set log file. *FILEPATH* is required.

**-m** \[*MOD*\]  
Set model by *NAME*.

**-m** \[*IND*\]  
Set model by *INDEX*:

|     |                             |                            |
|-----|:----------------------------|:---------------------------|
|     | **COMPLETIONS**             | **EDITS**                  |
|     | *0*. text-davinci-003       | *8*. text-davinci-edit-001 |
|     | *1*. text-curie-001         | *9*. code-davinci-edit-001 |
|     | *2*. text-babbage-001       | **AUDIO**                  |
|     | *3*. text-ada-001           | *11*. whisper-1            |
|     | **CHAT**                    | **GPT-4**                  |
|     | *4*. gpt-3.5-turbo          | *12*. gpt-4                |
|     | **MODERATION**              | *13*. gpt-4-32k            |
|     | *6*. text-moderation-latest |                            |
|     | *7*. text-moderation-stable |                            |

**-n** \[*NUM*\]  
Set number of results. Def=*1*.

**-o**  
Copy response to clipboard.

**-p** \[*VAL*\]  
Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).

**-r** \[*SEQ*\]  
Set restart sequence string (cmpls).

**-R** \[*SEQ*\]  
Set start sequence string (cmpls).

**-s** \[*SEQ*\]  
Set stop sequences, up to 4. Def="*\<\|endoftext\|\>*".

**-S** \[*INSTRUCTION*\|*FILE*\]  
Set an instruction prompt. It may be a text file.

**-S** */*\[*PROMPT_NAME*\]  
Set/search prompt from awesome-chatgpt-prompts.

**-t** \[*VAL*\]  
Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper
0.0 - 1.0). Def=*0*.

**-T**  
Count input tokens with python tiktoken. It heeds `options -ccm` for
model encoding.

**-u**  
Toggle multiline prompter.

**-v**  
Less verbose. May set multiple times.

**-V**  
Pretty-print context.

Set twice to dump raw request.

**-x**  
Edit prompt in text editor.

**-w** \[*AUD*\] \[*LANG*\]  
Transcribe audio file into text. LANG is optional.

Set twice to get phrase-level timestamps.

**-W** \[*AUD*\]  
Translate audio file into English text.

Set twice to get phrase-level timestamps.

**-z**  
Print last response JSON data.
