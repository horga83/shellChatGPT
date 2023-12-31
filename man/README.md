---
author:
- mountaineerbr
date: June 2023
title: CHATGPT.SH(1) v0.14.6 \| General Commands Manual
---

### NAME

   chatgpt.sh -- ChatGPT / DALL-E / Whisper Shell Wrapper

### SYNOPSIS

   **chatgpt.sh** \[`-c`\|`-d`\] \[`opt`\] \[*PROMPT\|TXT_FILE*\]  
   **chatgpt.sh** `-e` \[`opt`\] \[*INSTRUCTION*\] \[*INPUT*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PROMPT*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]  
   **chatgpt.sh** `-i` \[`opt`\] \[*S*\|*M*\|*L*\] \[*PNG_FILE*\]
\[*MASK_FILE*\] \[*PROPMT*\]  
   **chatgpt.sh** `-TTT` \[-v\] \[`-m`\[*MODEL*\|*ENCODING*\]\]
\[*TEXT*\|*FILE*\]  
   **chatgpt.sh** `-w` \[`opt`\] \[*AUDIO_FILE*\] \[*LANG*\]
\[*PROMPT*\]  
   **chatgpt.sh** `-W` \[`opt`\] \[*AUDIO_FILE*\] \[*PROMPT-EN*\]  
   **chatgpt.sh** `-ccw` \[`opt`\] \[*LANG*\]  
   **chatgpt.sh** `-ccW` \[`opt`\]  
   **chatgpt.sh** `-HH` \[`/`*SESSION_NAME*\]  
   **chatgpt.sh** `-ll` \[*MODEL_NAME*\]

### DESCRIPTION

Complete INPUT text when run without any options (single-turn, plain
text completions).

Positional arguments are read as a single **PROMPT**. Model
**INSTRUCTION** is usually optional, however if it is mandatory for a
chosen model (such as edits models), then the first positional argument
is read as **INSTRUCTION** and the following ones as **INPUT** or
**PROMPT**.

`Option -d` starts a multi-turn session in **plain text completions**.
This does not set further options automatically.

Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option accepts various models, defaults to
*text-davinci-003* if none set.

Set `option -cc` to start the chat mode via **native chat completions**
and use turbo models. While in chat mode, some options are automatically
set to un-lobotomise the bot.

Set `option -C` to **resume** from last history session.

If the first positional argument of the script starts with the command
operator, the command “`/session` \[*HIST_NAME*\]” to change to or
create a new history file is assumed (with `options -ccCdHH`).

Set model with “`-m` \[*NAME*\]” (full model name). Some models have an
equivalent *INDEX* as short-hand, so “`-m`*text-davinci-003*” and
“`-m`*0*” set the same model (list model by *NAME* with `option -l` or
by *INDEX* with `option -ll`).

Set *maximum response tokens* with `option` “`-`NUM” or “`-M` NUM”. This
defaults to 512 tokens in chat and single-turn modes.

*Model capacity* (max model tokens) can be set with a second *NUM* such
as “`-`*NUM,NUM*” or “`-M` NUM-NUM”, otherwise it is set automatically
to the capacity of known models, or to *2048* tokens as fallback.

If a plain text file path is set as first positional argument, it is
loaded as text PROMPT (text cmpls, chat cmpls, and text/code edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for text
cmpls, chat cmpls, and text/code edits. A text file path may be supplied
as the single argument.

If the argument to `-S` option starts with a backslash or a percent
sign, such as “`-S` `/`*linux_terminal*”, start search for an
*awesome-chatgpt-prompt(-zh)* (by Fatih KA and PlexPt). Set “`//`” or
“`%%`” to refresh cache. Use with *davinci* and *gpt-3.5+* models.

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
(*ISO-639-1*) as second argument. A PROMPT may also be set to guide the
model’s style or continue a previous audio segment. The prompt should
match the audio language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional argument.

Combine `-wW` **with** `-cc` to start **chat with voice input**
(Whisper) support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

`Option -y` sets python tiktoken instead of the default script hack to
preview token count. This option makes token count preview accurate
however it is slow. Useful for rebuilding history context independently
from the original model used to generate responses.

Stdin is supported when there is no positional arguments left after
option parsing. Stdin input sets a single PROMPT.

User configuration is kept at “*~/.chatgpt.conf*”. Script cache is kept
at “*~/.cache/chatgptsh*”.

A personal (free) OpenAI API is required, set it with `-K`. Also, see
**ENVIRONMENT section**.

See the online man page and script usage examples at:
<https://github.com/mountaineerbr/shellChatGPT/tree/main>.

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

| Model  | Settings                |                                       |
|:-------|:------------------------|---------------------------------------|
| `!NUM` | `!max` \[*NUM*,*NUM*\]  | Set response tokens / model capacity. |
| `-a`   | `!pre` \[*VAL*\]        | Set presence pensalty.                |
| `-A`   | `!freq` \[*VAL*\]       | Set frequency penalty.                |
| `-b`   | `!best` \[*NUM*\]       | Set best-of n results.                |
| `-m`   | `!mod` \[*MOD*\|*IND*\] | Set model (by index or name).         |
| `-n`   | `!results` \[*NUM*\]    | Set number of results.                |
| `-p`   | `!top` \[*VAL*\]        | Set top_p.                            |
| `-r`   | `!restart` \[*SEQ*\]    | Set restart sequence.                 |
| `-R`   | `!start` \[*SEQ*\]      | Set start sequence.                   |
| `-s`   | `!stop` \[*SEQ*\]       | Set one stop sequence.                |
| `-t`   | `!temp` \[*VAL*\]       | Set temperature.                      |
| `-w`   | `!rec`                  | Start audio record chat.              |

| Script | Settings |                               |
|:-------|:---------|-------------------------------|
| `-o`   | `!clip`  | Copy responses to clipboard.  |
| `-u`   | `!multi` | Toggle multiline prompter.    |
| `-v`   | `!ver`   | Toggle verbose.               |
| `-x`   | `!ed`    | Toggle text editor interface. |
| `-y`   | `!tik`   | Toggle python tiktoken use.   |
| `!r`   | `!regen` | Renegerate last response.     |
| `!q`   | `!quit`  | Exit.                         |

| Session | Management                             |                                          |
|:--------|:---------------------------------------|------------------------------------------|
| `-c`    | `!new`                                 | Start new session.                       |
| `-H`    | `!hist`                                | Edit history in editor.                  |
| `-L`    | `!log` \[*FILEPATH*\]                  | Save to log file.                        |
| `!c`    | `!copy` \[*SRC_HIST*\] \[*DEST_HIST*\] | Copy session from source to destination. |
| `!f`    | `!fork` \[*DEST_HIST*\]                | Fork current session to destination.     |
| `!s`    | `!session` \[*HIST_FILE*\]             | Change to, search or create hist file.   |
| `!!s`   | `!!session` \[*HIST_FILE*\]            | Same as `!session`, break session.       |
|         | `!sub`                                 | Copy session to tail.                    |
|         | `!list`                                | List history files.                      |

E.g.: “`/temp` *0.7*”, “`!mod`*1*”, “`-p` *0.2*”, and “`/s`
*hist_name*”.

###### Session Management

The script uses a *TSV file* to record entries, which is kept at the
script cache directory. A new history file can be created, or an
existing one changed to with command “`/session` \[*HIST_FILE*\]”, in
which *HIST_FILE* is the file name of, or path to a tsv file with or
without the *.tsv* extension.

A history file can contain many sessions. The last one (the tail
session) is always read if the resume `option -C` is set. To continue a
previous session than the tail session of history file, run chat command
“`/copy` \[*SRC_HIST_FILE*\] \[*DEST_HIST_FILE*\]”.

It is also possible to copy a session of a history file to another one.

If “`/copy` *current*” is run, select a session to copy to the tail of
the current history file and resume.

In order to change the chat context at run time, the history file may be
edited with the “`!hist`” command. Delete history entries or comment
them out with “`#`”.

##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before commiting it to history, append a
forward slash “`/`” to the prompt as the last character. Regenerate it
again or press ENTER to accept it.

After a response has been written to the history file, **regenerate** it
with command “`!regen`” or type in a single forward slash in the new
empty prompt.

#### 3. Prompt Engineering and Design

Minimal **INSTRUCTION** to behave like a chatbot is given with chat
`options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, minimal instruction is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of text
cmpls, such as Curie, the best_of option may be worth setting (to 2 or
3).

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

It is also worth trying to sample 3 - 5 times (setting `best_of`, for
example) in order to obtain a good response.

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

**CONFFILE**  
Path to user *chatgpt.sh configuration*.

Defaults="*~/.chatgpt.conf*"

**FILECHAT**  
Path to a script-formatted TSV history file to read from.

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
`Zsh` does not read history file in non-interactive mode.
&#10;`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.
&#10;`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->

### REQUIREMENTS

A free OpenAI **API key**. `Bash`, `cURL`, and `JQ`.

`ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.

### OPTIONS

#### Model Settings

**-@** \[\[*VAL%*\]*COLOUR*\], **--alpha**=\[\[*VAL%*\]*COLOUR*\]  
Set transparent colour of image mask. Def=*black*.

Fuzz intensity can be set with \[VAL%\]. Def=*0%*.

**-NUM**

**-M** \[*NUM*\[*-NUM*\]\], **--max-tokens**=\[*NUM*\[*-NUM*\]\]  
Set maximum number of *response tokens*. Def=*512*.

*Model capacity* can be set with a second number. Def=*auto-512*.

**-a** \[*VAL*\], **--presence-penalty**=\[*VAL*\]  
Set presence penalty (cmpls/chat, -2.0 - 2.0).

**-A** \[*VAL*\], **--frequency-penalty**=\[*VAL*\]  
Set frequency penalty (cmpls/chat, -2.0 - 2.0).

**-b** \[*NUM*\], **--best-of**=\[*NUM*\]  
Set best of, must be greater than `option -n` (cmpls). Def=*1*.

**-B**, **--log-prob**  
Print log probabilities to stderr (cmpls, 0 - 5).

**-m** \[*MOD*\], **--model**=\[*MOD*\]  
Set model by *NAME*.

**-m** \[*IND*\]  
Set model by *INDEX*:

|     |                             |                            |
|-----|:----------------------------|:---------------------------|
|     | **COMPLETIONS**             | **EDITS**                  |
|     | *0*. text-davinci-003       | *8*. text-davinci-edit-001 |
|     | *1*. text-curie-001         | *9*. code-davinci-edit-001 |
|     | *2*. text-babbage-001       | **CHAT**                   |
|     | *3*. text-ada-001           | *10*. gpt-3.5-turbo        |
|     | *4*. davinci                | **AUDIO**                  |
|     | *5*. curie                  | *11*. whisper-1            |
|     | **MODERATION**              | **GPT-4**                  |
|     | *6*. text-moderation-latest | *12*. gpt-4                |
|     | *7*. text-moderation-stable | *13*. gpt-4-32k            |

**-n** \[*NUM*\], **--results**=\[*NUM*\]  
Set number of results. Def=*1*.

**-p** \[*VAL*\], **--top-p**=\[*VAL*\]  
Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).

**-r** \[*SEQ*\], **--restart-sequence**=\[*SEQ*\]  
Set restart sequence string (cmpls).

**-R** \[*SEQ*\], **--start-sequence**=\[*SEQ*\]  
Set start sequence string (cmpls).

**-s** \[*SEQ*\], **--stop**=\[*SEQ*\]  
Set stop sequences, up to 4. Def="*\<\|endoftext\|\>*".

**-S** \[*INSTRUCTION*\|*FILE*\], **--instruction**  
Set an instruction prompt. It may be a text file.

**-t** \[*VAL*\], **--temperature**=\[*VAL*\]  
Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper
0.0 - 1.0). Def=*0*.

#### Script Modes

**-c**, **--chat**  
Chat mode in text completions, session break.

**-cc**  
Chat mode in chat completions, session break.

**-C**, **--continue**, **--resume**  
Continue (resume) from last session (compls/chat).

**-d**, **--text**  
Start new multi-turn session in plain text completions.

**-e** \[*INSTRUCTION*\] \[*INPUT*\], **--edit**  
Set Edit mode. Model def=*text-davinci-edit-001*.

**-i** \[*PROMPT*\], **--image**  
Generate images given a prompt.

**-i** \[*PNG*\]  
Create variations of a given image.

**-i** \[*PNG*\] \[*MASK*\] \[*PROMPT*\]  
Edit image with mask and prompt (required).

**-q**, **--insert**  
Insert text rather than completing only.

Use “*\[insert\]*” to indicate where the language model should insert
text (cmpls).

**-S** `/`\[*AWESOME_PROMPT_NAME*\]

**-S** `%`\[\_AWESOME_PROMPT_NAME_ZH\]  
Set or search an *awesome-chatgpt-prompt(-zh)* (*davinci* and *gpt3.5+*
models).

Set `//` or `%%` instead to refresh cache.

**-TTT**, **--tiktoken**  
Count input tokens with python tiktoken (ignores special tokens). It
heeds `options -ccm`.

Set twice to print tokens, thrice to available encodings.

Set model or encoding with `option -m`.

**-w** \[*AUD*\] \[*LANG*\] \[*PROMPT*\], **--transcribe**  
Transcribe audio file into text. LANG is optional. A prompt that matches
the audio language is optional.

Set twice to get phrase-level timestamps.

**-W** \[*AUD*\] \[*PROMPT-EN*\], **--translate**  
Translate audio file into English text.

Set twice to get phrase-level timestamps.

### Script Settings

**-f**, **--no-config**  
Ignore user config file and environment.

**-F**  
Edit configuration file with text editor, if it exists.

**-h**, **--help**  
Print the help page.

**-H** \[`/`*HIST_FILE*\], **--hist**  
Edit history file with text editor or pipe to stdout.

A history file name can be optionally set as argument.

**-HH** \[`/`*HIST_FILE*\]  
Pretty print last history session to stdout.

Heeds `options -ccdrR` to print with the specified restart and start
sequences.

**-j**, **--raw**  
Print raw JSON response (debug with `-jVVz`).

**-k**, **--no-colour**  
Disable colour output. Def=*auto*.

**-K** \[*KEY*\], **--api-key**=\[*KEY*\]  
Set OpenAI API key.

**-l** \[*MOD*\], **--list-models**  
List models or print details of *MODEL*.

Set twice to print script model indexes instead.

**-L** \[*FILEPATH*\], **--log**=\[*FILEPATH*\]  
Set log file. *FILEPATH* is required.

**-o**, **--clipboard**  
Copy response to clipboard.

**-u**, **--multiline**  
Toggle multiline prompter.

**-v**, **--verbose**  
Less verbose. May set multiple times.

**-V**  
Pretty-print context.

Set twice to dump raw request.

**-x**, **--editor**  
Edit prompt in text editor.

**-y**, **--tik**  
Set tiktoken for token preview (cmpls, chat).

**-z**, **--last**  
Print last response JSON data.

**-Z**  
Run with Z-shell.
