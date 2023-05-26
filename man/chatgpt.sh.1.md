% CHATGPT.SH(1) v0.14.2 | General Commands Manual
% mountaineerbr
% May 2023


### NAME

|    chatgpt.sh \-- ChatGPT / DALL-E / Whisper  Shell Wrapper


### SYNOPSIS

|    **chatgpt.sh** \[`-c`|`-d`] \[`opt`] \[_PROMPT|TXT_FILE_]
|    **chatgpt.sh** `-e` \[`opt`] \[_INSTRUCTION_] \[_INPUT_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PROMPT_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_] \[_MASK_FILE_] \[_PROPMT_]
|    **chatgpt.sh** `-TTT` \[-v] \[`-m`\[_MODEL_|_ENCODING_]] \[_TEXT_|_FILE_]
|    **chatgpt.sh** `-w` \[`opt`] \[_AUDIO_FILE_] \[_LANG_] \[_PROMPT_]
|    **chatgpt.sh** `-W` \[`opt`] \[_AUDIO_FILE_] \[_PROMPT-EN_]
|    **chatgpt.sh** `-ccw` \[`opt`] \[_LANG_]
|    **chatgpt.sh** `-ccW` \[`opt`]
|    **chatgpt.sh** `-HH` \[`/`_SESSION_NAME_]
|    **chatgpt.sh** `-ll` \[_MODEL_NAME_]


### DESCRIPTION

Complete INPUT text when run without any options (single-turn,
pure text completions).

Positional arguments are read as a single **PROMPT**. Model **INSTRUCTION**
is usually optional, however if it is mandatory for a chosen model
(such as edits models), then the first positional argument is read as
**INSTRUCTION** and the following ones as **INPUT** or **PROMPT**.

`Option -d` starts a multi-turn session in **pure text completions**.
This does not set further options automatically.

Set `option -c` to start a multi-turn chat mode via **text completions**
and record conversation. This option accepts various models,
defaults to _text-davinci-003_ if none set.

Set `option -cc` to start the chat mode via **native chat completions**
and use turbo models. While in chat mode, some options are
automatically set to un-lobotomise the bot.

Set `option -C` to **resume** from last history session.

If the first positional argument of the script starts with the
command operator, the command "`/session` \[_HIST_NAME_]" to change to
or create a new history file is assumed (with `options -ccCdHH`).

Set model with "`-m` \[_NAME_]" (full model name). Some models have an
equivalent _INDEX_ as short-hand, so "`-m`_text-davinci-003_" and
"`-m`_0_" set the same model (list model by _NAME_ with `option -l` or
by _INDEX_ with `option -ll`).

Set _maximum response tokens_ with `option` "`-`NUM" or "`-M` NUM". This
defaults to 512 tokens in chat and single-turn modes.

_Model capacity_ (max model tokens) can be set with a second _NUM_ such
as "`-`_NUM,NUM_" or "`-M` NUM-NUM", otherwise it is set automatically
to the capacity of known models, or to _2048_ tokens as fallback.

If a plain text file path is set as first positional argument,
it is loaded as text PROMPT (text cmpls, chat cmpls, and text/code
edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for
text cmpls, chat cmpls, and text/code edits. A text file path
may be supplied as the single argument.

If the argument to `-S` option starts with a backslash or a percent sign,
such as "`-S` `/`_linux_terminal_", start search for an *awesome-chatgpt-prompt(-zh)*
(by Fatih KA and PlexPt). Set "`//`" or "`%%`" to refresh cache.

`Option -e` sets the **text edits** endpoint. That endpoint requires
both INSTRUCTION and INPUT prompts. User may choose a model amongst
the _edit model family_.

`Option -i` **generates images** according to text PROMPT. If the first
positional argument is an _IMAGE_ file, then **generate variations** of
it. If the first positional argument is an _IMAGE_ file and the second
a _MASK_ file (with alpha channel and transparency), and a text PROMPT
(required), then **edit the** _IMAGE_ according to _MASK_ and PROMPT.
If _MASK_ is not provided, _IMAGE_ must have transparency.

Optionally, size of output image may be set with "\[_S_]_mall_",
"\[_M_]_edium_" or "\[_L_]_arge_" as the first positional argument.
See **IMAGES section** below for more information on
**inpaint** and **outpaint**.

`Option -w` **transcribes audio** from _mp3_, _mp4_, _mpeg_, _mpga_,
_m4a_, _wav_, and _webm_ files.
First positional argument must be an _AUDIO_ file.
Optionally, set a _TWO-LETTER_ input language (_ISO-639-1_) as second
argument. A PROMPT may also be set to guide the model's style or continue
a previous audio segment. The prompt should match the audio language.

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional
argument.

Combine `-wW` **with** `-cc` to start **chat with voice input** (Whisper)
support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

`Option -y` sets python tiktoken instead of the default script hack
to preview token count. This option makes token count preview
accurate however it is slow. Useful for rebuilding history context
independently from the original model used to generate responses.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

User configuration is kept at "_~/.chatgpt.conf_".
Script cache is kept at "_~/.cache/chatgptsh_".

A personal (free) OpenAI API is required, set it with `-K`. Also,
see **ENVIRONMENT section**.

See the online man page and script usage examples at:
<https://github.com/mountaineerbr/shellChatGPT/tree/main>.

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.


### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable "`<|endoftext|>`",
or other stop sequences (stops may be set with `-s`).

**Restart** and **start sequences** may be optionally set and are
always preceded by a new line.

To enable **multiline input**, type in a backslash "_\\_" as the last
character of the input line and press ENTER (backslash will be
removed from input), or set `option -u`.
Once enabled, press ENTER twice to confirm the multiline prompt.
Useful to paste from clipboard, but empty lines will confirm
the prompt up to that point.

Language model **SKILLS** can activated, with specific prompts,
see <https://platform.openai.com/examples>.


#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models.

##### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo
models are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is "**Q & A**". The **restart sequence**
"\\n_Q:\ _" and the **start text** "\\n_A:_" are injected
for the chat bot to work well with text cmpls.

In native chat completions, setting a prompt with "_:_" as the initial
character sets the prompt as a **SYSTEM** message. In text completions,
however, typing a colon "_:_" at the start of the prompt
causes the text following it to be appended immediately to the last
(response) prompt text.


##### 2.4 Chat Commands

While in chat mode, the following commands can be typed in the
new prompt to set a new parameter. The command operator
may be either "`!`", or "`/`".


  Model       Settings
  --------    ---------------------    ---------------------------------------------
    `!NUM`    `!max` \[_NUM_,_NUM_]    Set response tokens / model capacity.
      `-a`    `!pre`       \[_VAL_]    Set presence pensalty.
      `-A`    `!freq`      \[_VAL_]    Set frequency penalty.
      `-m`    `!mod` \[_MOD_|_IND_]    Set model (by index or name).
      `-p`    `!top`       \[_VAL_]    Set top_p.
      `-r`    `!restart`   \[_SEQ_]    Set restart sequence.
      `-R`    `!start`     \[_SEQ_]    Set start sequence.
      `-s`    `!stop`      \[_SEQ_]    Set one stop sequence.
      `-t`    `!temp`      \[_VAL_]    Set temperature.
      `-w`    `!rec`                   Start audio record chat.
  --------    ---------------------    ---------------------------------------------

  Script      Settings
  --------    ---------------------    ---------------------------------------------
      `-o`    `!clip`                  Copy responses to clipboard.
      `-u`    `!multi`                 Toggle multiline prompter.
      `-v`    `!ver`                   Toggle verbose.
      `-x`    `!ed`                    Toggle text editor interface.
      `-y`    `!tik`                   Toggle python tiktoken use.
      `!r`    `!regen`                 Renegerate last response.
      `!q`    `!quit`                  Exit.
  --------    ---------------------    ---------------------------------------------

  Session     Management
  --------    ------------------------------------    -----------------------------------------------
      `-c`    `!new`                                  Start new session.
      `-H`    `!hist`                                 Edit history in editor.
      `-L`    `!log` \[_FILEPATH_]                    Save to log file.
      `!c`    `!copy` \[_SRC_HIST_] \[_DEST_HIST_]    Copy session from source to destination.
      `!f`    `!fork` \[_DEST_HIST_]                  Fork current session to destination.
      `!s`    `!session` \[_HIST_FILE_]               Change to, search or create hist file.
      `!!s`   `!!session` \[_HIST_FILE_]              Same as `!session`, break session.
              `!sub`                                  Copy session to tail.
              `!list`                                 List history files.
  --------    ------------------------------------    -----------------------------------------------


| E.g.: "`/temp` _0.7_", "`!mod`_1_", "`-p` _0.2_", and "`/s` _hist_name_".


###### Session Management

The script uses a _TSV file_ to record entries, which is kept at the script
cache directory. A new history file can be created, or an existing one
changed to with command "`/session` \[_HIST_FILE_]", in which _HIST_FILE_
is the file name of, or path to a tsv file with or without the _.tsv_ extension.

A history file can contain many sessions. The last one (the tail session)
is always read if the resume `option -C` is set. To continue a previous
session than the tail session of history file, run chat command
"`/copy` \[_SRC_HIST_FILE_] \[_DEST_HIST_FILE_]".

It is also possible to copy a session of a history file to another one.

If "`/copy` _current_" is run, select a session to copy to the tail
of the current history file and resume.

In order to change the chat context at run time, the history file may be
edited with the "`!hist`" command. Delete history entries
or comment them out with "`#`".


##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before commiting it to history,
append a forward slash "`/`" to the prompt as the last character. Regenerate
it again or press ENTER to accept it.

After a response has been written to the history file, **regenerate**
it with command "`!regen`" or type in a single forward slash in the
new empty prompt.


#### 3. Prompt Engineering and Design

Very short **INSTRUCTION** to behave like a chatbot are given with
chat `options -cc`, unless otherwise explicitly set by the user.

On chat mode, if no INSTRUCTION is set, a short one is given,
and some options auto set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of
text cmpls, such as Curie, the best_of option may be worth
setting (to 2 or 3).

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat compls models.

Certain prompts may return empty responses. Maybe the model has
nothing to further complete input or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, resetting
temperature, or adding more text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing
spaces in its dictionary of tokens.

Note that the model's steering and capabilities require prompt
engineering to even know that it should answer the questions.

It is also worth trying to sample 3 - 5 times (setting `best_of`,
for example) in order to obtain a good response.

For more on prompt design, see:

 - <https://platform.openai.com/docs/guides/completion/prompt-design>
 - <https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


See detailed info on settings for each endpoint at:

 - <https://platform.openai.com/docs/>


### CODE COMPLETIONS

Codex models are discontinued. Use davinci or turbo models for coding tasks.

Turn comments into code, complete the next line or function in
context, add code comments, and rewrite code for efficiency,
amongst other functions.

Start with a comment with instructions, data or code. To create
useful completions it's helpful to think about what information
a programmer would need to perform a task. 


### TEXT EDITS

This endpoint is set with models with **edit** in their name or
`option -e`. Editing works by setting INSTRUCTION on how to modify
a prompt and the prompt proper.

The edits endpoint can be used to change the tone or structure
of text, or make targeted changes like fixing spelling. Edits
work well on empty prompts, thus enabling text generation similar
to the completions endpoint. 


### IMAGES / DALL-E

#### 1. Image Generations

An image can be created given a text prompt. A text PROMPT
of the desired image(s) is required. The maximum length is 1000
characters.


#### 2. Image Variations

Variations of a given _IMAGE_ can be generated. The _IMAGE_ to use as
the basis for the variations must be a valid PNG file, less than
4MB and square.


#### 3. Image Edits

To edit an _IMAGE_, a _MASK_ file may be optionally provided. If _MASK_
is not provided, _IMAGE_ must have transparency, which will be used
as the mask. A text prompt is required.

##### 3.1 ImageMagick

If **ImageMagick** is available, input _IMAGE_ and _MASK_ will be checked
and processed to fit dimensions and other requirements.

##### 3.2 Transparent Colour and Fuzz

A transparent colour must be set with "`-@`\[_COLOUR_]" to create the
mask. Defaults=_black_.

By defaults, the _COLOUR_ must be exact. Use the `fuzz option` to match
colours that are close to the target colour. This can be set with
"`-@`\[_VALUE%_]" as a percentage of the maximum possible intensity,
for example "`-@`_10%black_".

See also:

 - <https://imagemagick.org/script/color.php>
 - <https://imagemagick.org/script/command-line-options.php#fuzz>

##### 3.3 Mask File / Alpha Channel

An alpha channel is generated with **ImageMagick** from any image
with the set transparent colour (defaults to _black_). In this way,
it is easy to make a mask with any black and white image as a
template.

##### 3.4 In-Paint and Out-Paint

In-painting is achieved setting an image with a MASK and a prompt.

Out-painting can also be achieved manually with the aid of this
script. Paint a portion of the outer area of an image with _alpha_,
or a defined _transparent_ _colour_ which will be used as the mask, and set the
same _colour_ in the script with `-@`. Choose the best result amongst
many results to continue the out-painting process step-wise.


Optionally, for all image generations, variations, and edits,
set **size of output image** with "_256x256_" ("_Small_"), "_512x512_" ("_Medium_"),
or "_1024x1024_" ("_Large_") as the first positional argument. Defaults=_512x512_.


### AUDIO / WHISPER

#### 1. Transcriptions

Transcribes audio file or voice record into the input language.
Set a _two-letter_ _ISO-639-1_ language code (_en_, _es_, _ja_, or _zh_) as
the positional argument following the input audio file. A prompt
may also be set as last positional parameter to help guide the
model. This prompt should match the audio language.


#### 2. Translations

Translates audio into **English**. An optional text to guide
the model's style or continue a previous audio segment is optional
as last positional argument. This prompt should be in English.

Setting **temperature** has an effect, the higher the more random.


### QUOTING AND SPECIAL SYMBOLS

The special sequences (`\b`, `\f`, `\n`, `\r`, `\t` and `\uHEX`)
are interpreted as quoted _backspace_, _form feed_, _new line_, _return_,
_tab_ and _unicode hex_. To preserve these symbols as literals instead
(e. g. **Latex syntax**), type in an extra backslash such as "`\\theta`".


### ENVIRONMENT

**CHATGPTRC**

**CONFFILE**

:   Path to user _chatgpt.sh configuration_.

    Defaults=\"_~/.chatgpt.conf_\"


**FILECHAT**

: Path to a script-formatted TSV history file to read from.


**INSTRUCTION**

:   Initial instruction set for the chatbot.


**OPENAI_API_KEY**

**OPENAI_KEY**

:   Set your personal (free) OpenAI API key.


**REC_CMD**

:   Audio recording command.


**VISUAL**

**EDITOR**

:   Text editor for external prompt editing.

    Defaults=\"_vim_\"


### BUGS

Changing models in the same session may generate token count errors
because the token count recorded in history file entries may differ
significantly from model to model (encoding).

With the exception of Davinci models, older models were designed
to be run as one-shot.

Instruction prompts are required for the model to even know that
it should answer questions.

Garbage in, garbage out. An idiot savant.

<!--
`Zsh` does not read history file in non-interactive mode.

`Ksh93` mangles multibyte characters when re-editing input prompt
and truncates input longer than 80 chars. Workaround is to move
cursor one char and press the up arrow key.

`Ksh2020` lacks functionality compared to `Ksh83u+`, such as `read`
with history, so avoid it.
-->


### REQUIREMENTS

A free OpenAI **API key**. `Bash`, `cURL`, and `JQ`.

`ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.


### OPTIONS

#### Model Settings

**-\@** \[\[_VAL%_]_COLOUR_], **\--alpha**=\[\[_VAL%_]_COLOUR_]

:      Set transparent colour of image mask. Def=_black_.

       Fuzz intensity can be set with [VAL%]. Def=_0%_.


**-NUM**

**-M** \[_NUM_[_-NUM_]], **\--max-tokens**=\[_NUM_[_-NUM_]]

:     Set maximum number of _response tokens_. Def=_512_.

      _Model capacity_ can be set with a second number. Def=_auto-512_.


**-a** \[_VAL_], **\--presence-penalty**=\[_VAL_]

: Set presence penalty  (cmpls/chat, -2.0 - 2.0).


**-A** \[_VAL_], **\--frequency-penalty**=\[_VAL_]

: Set frequency penalty (cmpls/chat, -2.0 - 2.0).


**-b** \[_VAL_], **\--best-of**=\[_VAL_]

: Set best of, must be greater than `option -n` (cmpls). Def=_1_.


**-B**, **\--log-prob**

: Print log probabilities to stderr (cmpls, 0 - 5).


**-m** \[_MOD_], **\--model**=\[_MOD_]

: Set model by _NAME_.


**-m** \[_IND_]

: Set model by _INDEX_:

  ----  ----------------------------  ------------------------------
        **COMPLETIONS**               **EDITS**
        _0_.  text-davinci-003        _8_.  text-davinci-edit-001
        _1_.  text-curie-001          _9_.  code-davinci-edit-001
        _2_.  text-babbage-001        **CHAT**
        _3_.  text-ada-001            _10_. gpt-3.5-turbo
        _4_.  davinci                 **AUDIO**
        _5_.  curie                   _11_. whisper-1
        **MODERATION**                **GPT-4**
        _6_.  text-moderation-latest  _12_. gpt-4
        _7_.  text-moderation-stable  _13_. gpt-4-32k
  ----  ----------------------------  ------------------------------


**-n** \[_NUM_], **\--results**=\[_NUM_]

: Set number of results. Def=_1_.


**-p** \[_VAL_], **\--top-p**=\[_VAL_]

: Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).


**-r** \[_SEQ_], **\--restart-sequence**=\[_SEQ_]

: Set restart sequence string (cmpls).


**-R** \[_SEQ_], **\--start-sequence**=\[_SEQ_]

: Set start sequence string (cmpls).


**-s** \[_SEQ_], **\--stop**=\[_SEQ_]

: Set stop sequences, up to 4. Def=\"_<|endoftext|>_\".


**-S** \[_INSTRUCTION_|_FILE_], **\--instruction**

: Set an instruction prompt. It may be a text file.


**-t** \[_VAL_], **\--temperature**=\[_VAL_]

: Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper 0.0 - 1.0). Def=_0_.


#### Script Modes

**-c**, **\--chat**

: Chat mode in text completions, session break.


**-cc**

: Chat mode in chat completions, session break.


**-C**, **\--continue**, **\--resume**

: Continue (resume) from last session (compls/chat).
 
**-d**, **\--text**

: Start new multi-turn session in pure text completions.


**-e** \[_INSTRUCTION_] \[_INPUT_], **\--edit**

: Set Edit mode. Model def=_text-davinci-edit-001_.


**-i** \[_PROMPT_], **\--image**

: Generate images given a prompt.


**-i** \[_PNG_]

: Create variations of a given image.


**-i** \[_PNG_] \[_MASK_] \[_PROMPT_]

: Edit image with mask and prompt (required).


**-q**, **\--insert**

:     Insert text rather than completing only. 

      Use "_\[insert]_" to indicate where the language model should insert text (cmpls).


**-S** `/`[_AWESOME_PROMPT_NAME_]

**-S** `%`[_AWESOME_PROMPT_NAME_ZH]

:     Set or search an *awesome-chatgpt-prompt*.
      
      Set `//` or `%%` instead to refresh cache.


**-TTT**, **\--tiktoken**

:     Count input tokens with python tiktoken (ignores special tokens). It heeds `options -ccm`.

      Set twice to print tokens, thrice to available encodings.
      
      Set model or encoding with `option -m`.


**-w** \[_AUD_] \[_LANG_] \[_PROMPT_], **\--transcribe**

:     Transcribe audio file into text. LANG is optional.
      A prompt that matches the audio language is optional.
      
      Set twice to get phrase-level timestamps.


**-W** \[_AUD_] \[_PROMPT-EN_], **\--translate**

:     Translate audio file into English text.
      
      Set twice to get phrase-level timestamps.


### Script Settings

**-f**, **\--no-config**

: Ignore user config file and environment.


**-F**

: Edit configuration file with text editor, if it exists.


**-h**, **\--help**

: Print the help page.


**-H** \[`/`_HIST_FILE_], **\--hist**

:     Edit history file with text editor or pipe to stdout.
      
      A history file name can be optionally set as argument.


**-HH** \[`/`_HIST_FILE_]

:     Pretty print last history session to stdout.
      
      Heeds `options -ccdrR` to print with the specified restart and start sequences.


**-j**, **\--raw**

: Print raw JSON response (debug with `-jVVz`).


**-k**, **\--no-colour**

: Disable colour output. Def=_auto_.


**-K** \[_KEY_], **\--api-key**=\[_KEY_]

: Set OpenAI API key.


**-l** \[_MOD_], **\--list-models**

:     List models or print details of _MODEL_.
      
      Set twice to print script model indexes instead.


**-L** \[_FILEPATH_], **\--log**=\[_FILEPATH_]

: Set log file. _FILEPATH_ is required.


**-o**, **\--clipboard**

: Copy response to clipboard.


**-u**, **\--multiline**

: Toggle multiline prompter.


**-v**, **\--verbose**

:     Less verbose. May set multiple times.


**-V**

:     Pretty-print context.
      
      Set twice to dump raw request.


**-x**, **\--editor**

: Edit prompt in text editor.


**-y**, **\--tik**

: Set tiktoken for token preview (cmpls, chat).


**-z**, **\--last**

: Print last response JSON data.


**-Z**

: Run with Z-shell.

