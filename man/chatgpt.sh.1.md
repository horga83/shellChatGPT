% CHATGPT.SH(1) v0.10.19 | General Commands Manual
% Jamil Soni N
% April 2023


### NAME

|    chatgpt.sh -- ChatGPT / DALL-E / Whisper  Shell Wrapper


### SYNOPSIS

|    **chatgpt.sh** \[`-m` \[_MODEL_NAME_|_MODEL_INDEX_]] \[`opt`] \[_PROMPT|TXT_FILE_]
|    **chatgpt.sh** \[`-m` \[_MODEL_NAME_|_MODEL_INDEX_]] \[`opt`] \[_INSTRUCTION_] \[_INPUT_]
|    **chatgpt.sh** `-e` \[`opt`] \[_INSTRUCTION_] \[_INPUT_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PROMPT_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_]
|    **chatgpt.sh** `-i` \[`opt`] \[_S_|_M_|_L_] \[_PNG_FILE_] \[_MASK_FILE_] \[_PROPMT_]
|    **chatgpt.sh** `-w` \[`opt`] \[_AUDIO_FILE_] \[_LANG_] \[_PROMPT-LANG_]
|    **chatgpt.sh** `-W` \[`opt`] \[_AUDIO_FILE_] \[_PROMPT-EN_]
|    **chatgpt.sh** `-ccw` \[`opt`] \[_LANG_]
|    **chatgpt.sh** `-ccW` \[`opt`]
|    **chatgpt.sh** `-l` \[_MODEL_NAME_]


### DESCRIPTION

All positional arguments are read as a single **PROMPT**. If the
chosen model requires an **INSTRUCTION** and **INPUT prompts**, the
first positional argument is taken as INSTRUCTION and the following
ones as INPUT or PROMPT.

Set `option -c` to start the chat mode via the **text completions**
and record the conversation. This option accepts various
models, defaults to _text-davinci-003_ if none set.

Set `option -cc` to start the chat mode via **native chat completions**
and use the turbo models. While in chat mode, some options are
automatically set to un-lobotomise the bot.

Set `-C` to **resume** from last history session. Setting `-CC` starts a
**new session** in the history file (without `-c` or `-cc`).

Set model with "`-m` \[_NAME_]" (full model name). Some models have an
equivalent _INDEX_ as short-hand, so "`-m`_text-davinci-003_" and
"`-m`_0_" set the same model (list model by _NAME_ with `option -l` or
by _INDEX_ with `option -ll`).

Set _maximum response tokens_ with `option` "`-`NUM" or "`-M` NUM". This
defaults to 256 tokens in chat and single-turn modes.

_Maximum model tokens_ can be set with a second _NUM_ such as
"`-`_NUM,NUM_" or "`-M` NUM-NUM", otherwise it is set automatically
to the capacity of known models, or to _2048_ tokens as fallback.

If a plain text file path is set as first positional argument,
it is loaded as text PROMPT (text cmpls, chat cmpls, and text/code
edits).

`Option -S` sets an INSTRUCTION prompt (the initial prompt) for
text cmpls, chat cmpls, and text/code edits. A text file path
may be supplied as the single argument. If the argument to this
option starts with a backslash such as "`-S` _/_linux_terminal",
start search for an awesome-chatgpt-prompt (by Fatih KA).

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
argument. A PROMPT may also be set after language (must be in the
same language as the audio).

`Option -W` **translates audio** stream to **English text**. A PROMPT in
English may be set to guide the model as the second positional
argument.

Combine `-wW` **with** `-cc` to start **chat with voice input** (Whisper)
support. Output may be piped to a voice synthesiser to have a
full voice in and out experience.

Stdin is supported when there is no positional arguments left
after option parsing. Stdin input sets a single PROMPT.

User configuration is kept at "_~/.chatgpt.conf_".
Script cache is kept at "_~/.cache/chatgptsh_".

A personal (free) OpenAI API is required, set it with `-K`. Also,
see **ENVIRONMENT section**.

Long option support, as "`--chat`", "`--temp=`_0.9_", "`--max=`_1024,128_",
"`--presence-penalty=`_0.6_", and "`--log=`_~/log.txt_" is experimental.

For complete model and settings information, refer to OpenAI
API docs at <https://platform.openai.com/docs/>.



### TEXT / CHAT COMPLETIONS

#### 1. Text completions

Given a prompt, the model will return one or more predicted
completions. For example, given a partial input, the language
model will try completing it until probable "`<|endoftext|>`",
or other stop sequences (stops may be set with `-s`).

Language model **SKILLS** can activated, with specific prompts,
see <https://platform.openai.com/examples>.

To enable **multiline input**, type in a backslash "_\\_" as the last
character of the input line and press ENTER (backslash will be
removed from input). Once enabled, press ENTER twice to confirm
the multiline prompt.


#### 2. Chat Mode

##### 2.1 Text Completions Chat

Set `option -c` to start chat mode of text completions. It keeps
a history file, and keeps new questions in context. This works
with a variety of models.

##### 2.2 Native Chat Completions

Set the double `option -cc` to start chat completions mode. Turbo
models are also the best option for many non-chat use cases.

##### 2.3 Q & A Format

The defaults chat format is "`Q & A`". So, the **restart text**
"_Q:\ _" and the **start text** "_A:_" must be injected
for the chat bot to work well with text cmpls.

Typing only a colon "_:_" at the start of the prompt causes it to
be appended after a newline to the last prompt (answer) in text
cmpls. If this trick is used with the initial prompt in text cmpls,
it works as the **INSTRUCTION**. In chat cmpls, setting a prompt with
"`:`" always sets it as a **SYSTEM** message.

##### 2.4 Chat Commands

While in chat mode, the following commands can be typed in the new prompt
to set a new parameter:

----------    --------    ----------------------------------
    `!NUM`    `!max`      Set response / model max tokens.
      `-a`    `!pre`      Set presence pensalty.
      `-A`    `!freq`     Set frequency penalty.
      `-c`    `!new`      Start new session.
      `-H`    `!hist`     Edit history in editor.
      `-L`    `!log`      Save to log file.
      `-m`    `!mod`      Set model (by index or name).
      `-p`    `!top`      Set top_p.
      `-t`    `!temp`     Set temperature.
      `-v`    `!ver`      Set/unset verbose.
      `-x`    `!ed`       Set/unset text editor interface.
      `-w`    `!rec`      Start audio record chat.
      `!r`    `!regen`    Renegerate last response.
      `!q`    `!quit`     Exit.
----------    --------    ----------------------------------

Examples: "`!temp` _0.7_", "`!mod`_1_", and "`-p` _0.2_".
Note that the command operator may be either "`!`", or "`/`".

To change the chat context at run time, the history file must be
edited with "`!hist`". Delete history entries or comment them out with "`#`".


##### 2.5 Completion Preview / Regeneration

To preview a prompt completion before commiting it to history,
append a forward slash "_/_" to the prompt as the last character. Regenerate
it again or press ENTER to accept it.

After a response has been written to the history file, **regenerate**
it with command "`!regen`" or type in a single forward slash in the
new empty prompt.


#### 3. Prompt Engineering and Design

Unless the chat `options -c` or `-cc` are set, __NO__ INSTRUCTION is
given to the language model (as would, otherwise, be the initial
prompt).

On chat mode, if no INSTRUCTION is set, a short one is given,
and some options set, such as increasing temp and presence penalty,
in order to un-lobotomise the bot. With cheap and fast models of
text cmpls, such as Curie, the best_of option may even be worth
setting (to 2 or 3).

Prompt engineering is an art on itself. Study carefully how to
craft the best prompts to get the most out of text, code and
chat compls models.

Certain prompts may return empty responses. Maybe the model has
nothing to further complete input or it expects more text. Try
trimming spaces, appending a full stop/ellipsis, resetting
temperature or adding more text.

Prompts ending with a space character may result in lower quality
output. This is because the API already incorporates trailing
spaces in its dictionary of tokens.

Note that the model's steering and capabilities require prompt
engineering to even know that it should answer the questions.

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

:   Path to user chatgpt.sh configuration.

    Defaults=\"_~/.chatgpt.conf_\"


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

`Ksh2020` lacks functionality compared to `Ksh83u+m`, such as `read`
with history.

With the exception of Davinci models, older models were designed
to be run as one-shot.

Instruction prompts are required for the model to even know that
it should answer questions.

Garbage in, garbage out. An idiot savant.


### REQUIREMENTS

A free OpenAI **API key**.

`Ksh93u+`, `Bash` or `Zsh`. `cURL`.

`JQ`, `ImageMagick`, and `Sox`/`Alsa-tools`/`FFmpeg` are optionally required.


### OPTIONS


**-\@** \[\[_VAL%_]_COLOUR_]

:      Set transparent colour of image mask. Def=_black_.

       Fuzz intensity can be set with [VAL%]. Def=_0%_.


**-NUM**

**-M** \[_NUM_[_-NUM_]]

:     Set maximum number of `response tokens`. Def=_256_.

      Maximum `model tokens` can be set with a second number. Def=_auto-256_.


**-a** \[_VAL_]

: Set presence penalty  (cmpls/chat, -2.0 - 2.0).


**-A** \[_VAL_]

: Set frequency penalty (cmpls/chat, -2.0 - 2.0).


**-b** \[_VAL_]

: Set best of, must be greater than `opt -n` (cmpls). Def=_1_.


**-B**

: Print log probabilities to stderr (cmpls, 0 - 5).


**-c**

: Chat mode in text completions, new session.


**-cc**

: Chat mode in chat completions, new session.


**-C**

:     Continue from last session (compls/chat).

      Set twice to start new session in chat mode (without -c, -cc).


**-e** \[_INSTRUCT_] \[_INPUT_]

: Set Edit mode. Model def=_text-davinci-edit-001_.


**-f**

: Ignore user config file and environment.

**-h**

: Print this help page.


**-H**

: Edit history file with text editor or pipe to stdout.

**-HH**

: Pretty print last history session to stdout.


**-i** \[_PROMPT_]

: Generate images given a prompt.


**-i** \[_PNG_]

: Create variations of a given image.


**-i** \[_PNG_] \[_MASK_] \[_PROMPT_]

: Edit image with mask and prompt (required).


**-j**

: Print raw JSON response (debug with -jVV).


**-k**

: Disable colour output. Def=_auto_.


**-K** \[_KEY_]

: Set API key (free).


**-l** \[_MOD_]

:     List models or print details of MODEL.
  
      Set twice to print model indexes instead.


**-L** \[_FILEPATH_]

: Set log file. _FILEPATH_ is required.


**-m** \[_MOD_]

: Set model by _NAME_.



**-m** \[_IND_]

: Set model by _INDEX_:

  ----  ---------------               -----
        **COMPLETIONS**               **EDITS**
        _0_.  text-davinci-003          _8_.  text-davinci-edit-001
        _1_.  text-curie-001            _9_.  code-davinci-edit-001
        _2_.  text-babbage-001          **AUDIO**
        _3_.  text-ada-001              _11_. whisper-1
        **CHAT**                        **GPT-4**
        _4_. gpt-3.5-turbo              _12_. gpt-4
        **MODERATION**                  _13_. gpt-4-32k
        _6_.  text-moderation-latest
        _7_.  text-moderation-stable
  ----  --------------------------    -----


**-n** \[_NUM_]

: Set number of results. Def=_1_.


**-p** \[_VAL_]

: Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).


**-r** \[_SEQ_]

: Set restart sequence string.


**-R** \[_SEQ_]

: Set start sequence string.


**-s** \[_SEQ_]

: Set stop sequences, up to 4. Def=\"_<|endoftext|>_\".


**-S** \[_INSTRUCTION_|_FILE_]

: Set an instruction prompt. It may be a text file.

**-S** _/_[_PROMPT_NAME_]

: Set/search prompt from awesome-chatgpt-prompt.


**-t** \[_VAL_]

: Set temperature value (cmpls/chat/edits/audio), (0.0 - 2.0, whisper 0.0 - 1.0). Def=_0_.


**-v**

:     Less verbose.
     
      May set multiple times.


**-V**

:     Pretty-print request.

      Set twice to dump raw request.


**-x**

: Edit prompt in text editor.


**-w** \[_AUD_] \[_LANG_]

:     Transcribe audio file into text. LANG is optional.
  
      Set twice to get phrase-level timestamps. 


**-W** \[_AUD_]

:     Translate audio file into English text.
  
      Set twice to get phrase-level timestamps. 


**-z**

: Print last response JSON data.
