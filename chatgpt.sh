#!/usr/bin/env ksh
# chatgpt.sh -- Ksh93/Bash/Zsh  ChatGPT/DALL-E/Whisper Shell Wrapper
# v0.9  2023  by mountaineerbr  GPL+3
[[ -n $BASH_VERSION ]] && shopt -s extglob
[[ -n $KSH_VERSION  ]] && set -o emacs -o multiline
[[ -n $ZSH_VERSION  ]] && { 	emulate -R zsh ;zmodload zsh/zle ;setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST NO_NOMATCH ;}

# OpenAI API key
#OPENAI_KEY=

# DEFAULTS
# Text compls model
#MOD="text-davinci-003"
# Chat compls model
#MOD_CHAT="gpt-3.5-turbo"
# Edits model
#MOD_EDIT="text-davinci-edit-001"
# Audio model
#MOD_AUDIO="whisper-1"
# Temperature
#OPTT=
# Top_p probability mass (nucleus sampling)
#OPTP=1
# Maximum tokens
OPTMM=1024
# Presence penalty
#OPTA=
# Frequency penalty
#OPTAA=
# Number of responses
OPTN=1
# Image size
OPTS=512x512
# Image format
OPTI_FMT=b64_json  #url
# Recorder command
#REC_CMD=

# INSTRUCTION
# Text and chat completions, and edits endpoints
#INSTRUCTION="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."

# CHATBOT INTERLOCUTORS
# Inject restart text
Q_TYPE=Q
# Inject start text
A_TYPE=A
# Obs: no spaces, a colon `:' will be appended


# CACHE AND OUTPUT DIRECTORIES
CONFFILE="$HOME/.chatgpt.conf"
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/chatgptsh"
OUTDIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"

# Load user defaults
((OPTF)) || { 	[[ -e "${CHATGPTRC:-$CONFFILE}" ]] && . "${CHATGPTRC:-$CONFFILE}" ;}

# Set file paths
FILE="${CACHEDIR%/}/chatgpt.json"
FILECHAT="${CACHEDIR%/}/chatgpt.tsv"
FILETXT="${CACHEDIR%/}/chatgpt.txt"
FILEOUT="${OUTDIR%/}/dalle_out.png"
FILEIN="${CACHEDIR%/}/dalle_in.png"
FILEINW="${CACHEDIR%/}/whisper_in.mp3"
USRLOG="${OUTDIR%/}/${FILETXT##*/}"
HISTFILE="${CACHEDIR%/}/history_${KSH_VERSION:+ksh}${BASH_VERSION:+bash}"
#https://www.zsh.org/mla/users/2013/msg00041.html
HISTSIZE=512

MAN="NAME
	${0##*/} -- ChatGPT / DALL-E / Whisper  Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT|TXT_FILE]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTION] [INPUT]
	${0##*/} -e [opt] [INSTRUCTION] [INPUT]
	${0##*/} -i [opt] [S|M|L] [PROMPT]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE] [MASK_FILE] [PROPMT]
	${0##*/} -w [opt] [AUDIO_FILE] [LANG] [PROMPT-LANG]
	${0##*/} -W [opt] [AUDIO_FILE] [PROMPT-EN]
	${0##*/} -ccw [opt] [LANG]
	${0##*/} -ccW [opt]
	${0##*/} -l [MODEL_NAME]


	All positional arguments are read as a single PROMPT. If the
	chosen model requires an INSTRUCTION and INPUT prompts, first
	positional argument is taken as INSTRUCTION and the following
	ones as INPUT or PROMPT.

	Set option -c to start the chat mode via the text completions
	and record the conversation. This option accepts various
	models, defaults to \`text-davinci-003' if none set.
	
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

	Option -e sets the \`text edits' endpoint. That endpoint requires
	both INSTRUCTION and INPUT prompts. User may choose a model amongst
	the \`edit' model family.

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

	User configuration is kept at \`${CHATGPTRC:-${CONFFILE/$HOME/"~"}}'.
	Script cache is kept at \`${CACHEDIR/$HOME/"~"}'.

	A personal (free) OpenAI API is required, set it with -K. Also,
	see ENVIRONMENT section.

	For complete model and settings information, refer to OpenAI
	API docs at <https://platform.openai.com/docs/>.


TEXT / CHAT COMPLETIONS
	1. Text completions
	Given a prompt, the model will return one or more predicted
	completions. For example, given a partial input, the language
	model will try completing it until probable \`<|endoftext|>',
	or other stop sequences (stops may be set with -s).

	Language model SKILLS can activated, with specific prompts,
	see <https://platform.openai.com/examples>.


	2. Chat Mode
	2.1 Text Completions Chat
	Set option -c to start chat mode of text completions. It keeps
	a history file, and keeps new questions in context. This works
	with a variety of models.

	2.2 Native Chat Completions
	Set the double option -cc to start chat cmpls mode. Turbo models
	are also the best option for many non-chat use cases.

	2.3 Q & A Format
	The defaults chat format is \`Q & A'. So, the \`\`restart text''
	\`$Q_TYPE:' and the \`\`start text'' \`$A_TYPE:' must be injected
	for the chat bot to work well with text cmpls.

	If a name such as \`NAME:' is typed in the new prompt, restart
	text is set to it instead of the defaults \`$Q_TYPE' interlocutor.
	
	Typing only a colon \`:' at the start of the prompt causes it to
	be appended after a newline to the last prompt (answer) in text
	cmpls. If this trick is used with the initial prompt in text cmpls,
	it works as the INSTRUCTION. In chat cmpls, setting a prompt with
	\`:' always sets it as a \`system' message.

	2.4 Chat Commands
	While in chat mode, the following commands preceeded by the operator
	\`!' (or \`/'), can be typed in the new prompt to set the new parameter:

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
	
	Examples: \`!temp 0.7', \`!mod1', and \`!-p 0.2'.

	To change the chat context at run time, the history file must be
	edited with \`!hist'. Delete entries or comment them out with \`#'.


	2.5 Completion Preview
	To preview a prompt completion before commiting it to history,
	append a slash \`/' to the prompt as the last character. Regen-
	erate it or press ENTER to accept it.


	3. Prompt Engineering and Design
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


	4. Settings (Abridged)
	Max Tokens
	The maximum number of tokens to generate in completions.
	Beware that setting this to the maximum allowed may stop the
	model itself.

	Temperature
	Also known as creativity, more random outputs. Defaults to 1.
	We generally recommend altering this or top_p but not both.

	Top_p
	Alternative to temperature, called nucleus sampling, where the
	model considers the results with top_p probability mass. So 0.1
	means only the tokens from the top 10% probability mass are
	considered. Defaults to 1

	Presence Penalty
	Number between -2.0 and 2.0. Positive values penalize new tokens
	based on whether they appear in the text so far. Defaults to 0.

	Frequency Penalty
	Number between -2.0 and 2.0. Positive values penalize new tokens
	based on their existing frequency in the text so far. Defaults to 0.

	Best_of
	Returns the \`best' of ou n results. Best_of controls the number
	of candidate completions and n specifies how many to return.
	Best_of must be greater than n (option -n). Defaults to 1.
	Note: This parameter can quickly consume your token quota.

	For more on settings, see <https://platform.openai.com/docs/>.


CODE COMPLETIONS / CODEX
	To use Codex, set a model with \`code' in its name. This utilises
	the same endpoint as text completions.

	Codex models can turn comments into code, complete the next line
	or function in context, add code comments, and rewrite code for
	efficiency, amongst others.

	Start with a comment with instructions, data or code. To get Codex
	to create useful completions it's helpful to think about what
	information a programmer would need to perform a task. 


TEXT EDITS
	This endpoint is set with models with \`edit' in their name or
	option -e. Editing works by setting INSTRUCTION on how to modify
	a prompt and the prompt proper.

	The edits endpoint can be used to change the tone or structure
	of text, or make targeted changes like fixing spelling. Edits
	work well on empty prompts, thus enabling text generation similar
	to the completions endpoint. 


IMAGES / DALL-E
	1. Image Generations
	An image can be created given a text prompt. A text description
	of the desired image(s) is required. The maximum length is 1000
	characters.


	2. Image Variations
	Variations of a given image can be generated. The image to use as
	the basis for the variations must be a valid PNG file, less than
	4MB and square.


	3. Image Edits
	Image and, optionally, a mask file must be provided. If mask is
	not provided, image must have transparency, which will be used
	as the mask. A text prompt is required.

	3.1 ImageMagick
	If ImageMagick is available, input image and mask will be checked
	and edited (converted) to fit dimensions and other requirements.

	3.2 Transparent Colour and Fuzz
	A transparent colour must be set with \`-@[COLOUR]' to create the
	mask. Defaults=black.

	By defaults, the colour must be exact. Use the fuzz option to match
	colours that are close to the target colour. This can be set with
	\`-@[VALUE%]' as a percentage of the maximum possible intensity,
	for example \`-@10%black'.

	See also:
	    <https://imagemagick.org/script/color.php>
	    <https://imagemagick.org/script/command-line-options.php#fuzz>

	3.3 Alpha Channel
	An alpha channel is generated with ImageMagick from any image
	with the set transparent colour (defaults to black). In this way,
	it is easy to make a mask with any black and white image as a
	template.

	3.4 In-Paint and Out-Paint
	In-painting is achieved setting an image with a mask and a prompt.
	Out-painting can also be achieved manually with the aid of this
	script. Paint a portion of the outer area of an image with alpha
	or a defined colour which will be used as the mask, and set the
	same colour in the script with -@. Choose the best result amongst
	many results to continue the out-painting process step-wise.


	Optionally, for all image generations, variations, and edits,
	set size of output image with 256x256 (Small), 512x512 (Medium)
	or 1024x1024 (Large) as the first positional argument. Defaults=$OPTS.


AUDIO / WHISPER
	1. Transcriptions
	Transcribes audio into the input language. Set a two letter
	ISO-639-1 language as the second positional parameter. A prompt
	may also be set as last positional parameter to help guide the
	model. This prompt should match the audio language.

	2. Translations
	Translates audio into into English. An optional text to guide
	the model's style or continue a previous audio segment is optional
	as last positional argument. This prompt should be in English.
	
	Setting temperature has an effect, the higher the more random.


ENVIRONMENT
	CHATGPTRC 	Path to user ${0##*/} configuration.
			Defaults=${CHATGPTRC:-${CONFFILE/$HOME/"~"}}

	INSTRUCTION 	Initial instruction set for the chatbot.

	OPENAI_API_KEY
	OPENAI_KEY 	Set your personal (free) OpenAI API key.

	REC_CMD 	Audio recording command.

	VISUAL
	EDITOR 		Text editor for external prompt editing.
			Defaults=vim


BUGS
	Instruction prompts are required for the model to even know that
	it should answer questions.

	Garbage in, garbage out.


REQUIREMENTS
	A free OpenAI API key.
	
	Ksh93, Bash or Zsh. cURL.

	JQ, ImageMagick, and Sox/Alsa-tools/FFmpeg are optionally required.


OPTIONS
	-@ [[VAL%]COLOUR]
		 Set transparent colour of image mask. Defaults=Black.
		 Fuzz intensity can be set with [VAL%]. Defaults=0%.
	-NUM 	 Set maximum tokens. Defaults=$OPTMM. Max=4096.
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
		 List models or print details of MODEL.
	-L [FILEPATH]
		 Set log file. FILEPATH is required.
	-m [MODEL]
		 Set model by NAME.
	-m [NUM] Set model by INDEX NUMBER:
		  # Completions           # Edits                  
		  0.  text-davinci-003    8.  text-davinci-edit-001
		  1.  text-curie-001      9.  code-davinci-edit-001
		  2.  text-babbage-001    # Chat
		  3.  text-ada-001        10. gpt-3.5-turbo
		  # Codex                 # Audio
		  4.  code-davinci-002    11. whisper-1
		  5.  code-cushman-001    # Gpt-4
		  # Moderation            12. gpt-4
		  6.  text-moderation-latest
		  7.  text-moderation-stable
	-n [NUM] Set number of results. Defaults=$OPTN.
	-p [VAL] Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).
	-s [SEQ] Set stop sequences, up to 4. Defaults=\"<|endoftext|>\".
	-S [INSTRUCTION|FILE]
		 Set an instruction prompt. It may be a text file.
	-t [VAL] Set temperature value (cmpls/chat/edits/audio),
		 (0.0 - 2.0, whisper 0.0 - 1.0). Defaults=${OPTT:-0}.
	-vv 	 Less verbose.
	-VV 	 Pretty-print request. Set twice to dump raw request.
	-x 	 Edit prompt in text editor.
	-w [AUD] [LANG]
		 Transcribe audio file into text. LANG is optional.
	-W [AUD] Translate audio file into English text.
	-z 	 Print last response JSON data."

MODELS=(
	#COMPLETIONS
	text-davinci-003          #0
	text-curie-001            #1
	text-babbage-001          #2
	text-ada-001              #3
	#CODEX
	code-davinci-002          #4
	code-cushman-001          #5
	#MODERATIONS
	text-moderation-latest    #6
	text-moderation-stable    #7
	#EDITS
	text-davinci-edit-001     #8
	code-davinci-edit-001     #9
	#CHAT
	gpt-3.5-turbo             #10
	#gpt-3.5-turbo-0301        #
	#AUDIO
	whisper-1                 #11
	#GPT4
	gpt-4 #gpt-4-0314 June 14 #12
)

ENDPOINTS=(
	completions               #0
	moderations               #1
	edits                     #2
	images/generations        #3
	images/variations         #4
	embeddings                #5
	chat/completions          #6
	audio/transcriptions      #7
	audio/translations        #8
	images/edits              #9
)


#set model endpoint based on its name
function set_model_epnf
{
	unset OPTE OPTEMBED
	case "$1" in
		*whisper*) 		((OPTWW)) && EPN=8 || EPN=7;;
		*turbo*) 		EPN=6 ;((OPTC)) && OPTC=2 ;unset OPTB OPTBB;;
		code-*) 	case "$1" in
					*search*) 	EPN=5 OPTEMBED=1;;
					*edit*) 	EPN=2 OPTE=1;;
					*) 		EPN=0;;
				esac;;
		text-*) 	case "$1" in
					*embedding*|*similarity*|*search*) 	EPN=5 OPTEMBED=1;;
					*edit*) 	EPN=2 OPTE=1;;
					*moderation*) 	EPN=1 OPTEMBED=1;;
					*) 		EPN=0;;
				esac;;
		*) 		#fallback
				case "$1" in
					*-edit*) 	EPN=2 OPTE=1;;
					*-embedding*|*-similarity*|*-search*) 	EPN=5 OPTEMBED=1;;
					*) 	EPN=0;;  #defaults
				esac;;
	esac
}

#make request
function promptf
{
	json_minif
	if ((OPTVV)) && ((!OPTII))
	then 	block_printf || { 	! printf '\n' >&2 ;return ;}
	fi

	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$BLOCK" \
		-o "$FILE"
}

#pretty print request body or dump and exit
function block_printf
{
	if ((OPTVV>1))
	then 	printf '%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK"
		printf '%s ' '<CTRL-D> redo, <CTR-C> exit, or continue' >&2
		typeset REPLY ;read
	else	jq -r '.instruction//empty, .input//empty, .prompt//(.messages[]|"\(.role):\t\(.content)")//empty' <<<"$BLOCK" \
		|| printf '%s\n' "$BLOCK"
	fi >&2
}

#prompt confirmation prompt
function new_prompt_confirmf
{
	typeset REPLY
	((OPTV)) && return

	__sysmsgf 'Confirm prompt?' '[Y]es, [n]o, [e]dit, [r]edo or [a]bort ' ''
	REPLY=$(__read_charf)
	case "${REPLY:-$1}" in
		[AaQq]*) 	return 201;;  #break
		[Rr]*) 	return 200;;  #continue
		[EeVv]*) 	return 199;;  #edit
		[Nn]*) 	unset REC_OUT ;return 1;;  #no
	esac  #yes
}

#read one char from user
function __read_charf
{
	typeset REPLY
	read -n ${ZSH_VERSION:+-k} 1 "$@"
	printf '%s\n' "$REPLY"
	[[ -z ${REPLY//[$IFS]} ]] || printf '\n' >&2
}

#print response
function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	else 	((OPTV)) || jq -r '.choices[].logprobs//empty,
			"Model_: \(.model//"?") (\(.object//"?"))",
			"Usage_: \(.usage.prompt_tokens)" + "+" +
			"\(.usage.completion_tokens) = \(.usage.total_tokens//empty) tkns"' "$FILE" >&2

		jq -r "def byellow: \"\"; def reset: \"\"; $JQCOL $JQCOL2
		.choices[1] as \$sep | .choices[] |
		(byellow + (
		(.text//.message.content) | gsub(\"^[\\\\n\\\\t]\"; \"\") |
		if ${OPTC:-0} > 0 then gsub(\"[\\\\n\\\\t]*$\"; \"\") else . end
		) + reset,
		if \$sep != null then \"---\" else empty end)" "$FILE" 2>/dev/null ||

		jq -r '.choices[]|.text//.message.content' "$FILE" 2>/dev/null ||

		jq . "$FILE" 2>/dev/null || cat -- "$FILE"
	fi
}
#https://stackoverflow.com/questions/57298373/print-colored-raw-output-with-jq-on-terminal
#https://stackoverflow.com/questions/40321035/  #gsub(\"^[\\n\\t]\"; \"\")

#make request to image endpoint
function prompt_imgvarf
{
	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-F image="@$1" \
		-F response_format="$OPTI_FMT" \
		-F n="$OPTN" \
		-F size="$OPTS" \
		"${@:2}" \
		-o "$FILE"
}

#open file with sys defaults
function __openf
{
	if command -v xdg-open >/dev/null 2>&1
	then 	xdg-open "$1"
	elif command -v open >/dev/null 2>&1
	then 	open "$1"
	fi
}
#https://budts.be/weblog/2011/07/xdf-open-vs-exo-open/

#print image endpoint response
function prompt_imgprintf
{
	typeset n m fname fout
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	elif [[ $OPTI_FMT = b64_json ]]
	then 	[[ -d "${FILEOUT%/*}" ]] || FILEOUT="${FILEIN}"
		n=0 m=0
		for fname in "${FILEOUT%.png}"*
		do 	fname="${fname%.png}" fname="${fname##*[!0-9]}"
			((m>fname)) || ((m=fname+1)) 
		done
		while jq -e ".data[${n}]" "$FILE" >/dev/null 2>&1
		do 	fout="${FILEOUT%.*}${m}.png"
			jq -r ".data[${n}].b64_json" "$FILE" | { 	base64 -d || base64 -D ;} > "$fout"
			printf 'File: %s\n' "${fout/$HOME/"~"}" >&2
			((OPTV)) ||  __openf "$fout" || function __openf { : ;}
			((++n, ++m)) ;((n<50)) || break
		done
		((n)) || { 	cat -- "$FILE" ;false ;}
	else 	jq -r '.data[].url' "$FILE" || cat -- "$FILE"
	fi
}

function prompt_audiof
{
	curl -\# ${OPTV:+-s} -L "https://api.openai.com/v1/${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="$MOD" \
		-F temperature="$OPTT" \
		"${@:2}" \
		-o "$FILE"
}

function list_modelsf
{
	curl "https://api.openai.com/v1/models${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-o "$FILE"
	if [[ -n $1 ]]
	then  	jq . "$FILE" || cat -- "$FILE"
	else 	jq -r '.data[].id' "$FILE" | sort
	fi
}

function lastjsonf
{
	if [[ -s $FILE ]]
	then 	jq . "$FILE" || cat -- "$FILE"
	fi
}

#calculate token preview
#usage: token_prevf [string]
function token_prevf
{
	TKN_PREV=$(__tiktokenf "$*")
	((OPTV)) || printf 'Prompt: ~%d tokens; Max: %d\n' "$TKN_PREV" "$OPTMAX" >&2
}

#set up $HIST and $HIST_C
function set_histf
{
	typeset time token string user_type
	[[ -s "$FILECHAT" ]] || return
	(($#)) && OPTV=1 token_prevf "$@"
	
	((MAX_PREV=TKN_PREV)) ;unset HIST HIST_C
	while IFS=$'\t' read -r time token string
	do 	[[ ${time//[$IFS]}${token//[$IFS]} = \#* ]] && continue
		[[ -z $time$token$string ]] && continue
		[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
		if ((token<1))
		then 	((OPTVV>1||OPTJ)) &&
			__warmsgf "Warning:" "Zero/Neg token in history"
			token=$(__tiktokenf "$string")
		fi

		if ((MAX_PREV+token<OPTMAX))
		then 	((MAX_PREV+=token))

			string="${string##$SPC1}" string="${string%%[\"]}"
			HIST="${string##:}${HIST:+\\n\\n}$HIST"

			if ((EPN==6))  #turbo models
			then 	user_type="$SET_TYPE"

				set_typef "$string" && SET_TYPE="${SET_TYPE:-:}" \
				string="${string##$SPC1"${SET_TYPE}"}"

				case "${SET_TYPE:-$string}" in
					"${user_type:-$Q_TYPE}"*|"$Q_TYPE"*) 	role=user
						;;
					:*) 	role=system
						;;
					*) 	role=assistant
						;;
				esac

				HIST_C="$(fmt_ccf "$string" "$role")${HIST_C:+,}$HIST_C"
				SET_TYPE="$user_type"
			fi
		fi
	done < <(tac -- "$FILECHAT")
	((MAX_PREV-=TKN_PREV))
}
#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string tkn_min tkn
	string="$1" ;tkn_min=$(__tiktokenf "$string" "4")
	((tkn = ${2:-$tkn_min}>0 ? ${2:-$tkn_min} : 0))
	printf '%s\t%d\t"%s"\n' "${3:-$(date -Isec)}" "$tkn" "$string" >> "$FILECHAT"
}

#poor man's tiktoken
#usage: __tiktokenf [string] [divide_by]
# divide_by  ^:less tokens  v:more tokens
function __tiktokenf
{
	typeset str tkn by
	by="$2"

	# 1 TOKEN ~= 4 CHARS IN ENGLISH
	#str="${1// }" str=${str//[$'\t\n']/xxxx} str="${str//\\[ntrvf]/xxxx}" tkn=$((${#str}/${by:-4}))
	# 1 TOKEN ~= ¾ WORDS
	set -- ${1//[[:punct:]]/x} ;tkn=$(( ($# * 4) / ${by:-3}))

	printf '%d\n' "$tkn" ;((tkn>0))
}

#check for interlocutor
SPC1="*(\\\\[ntrvf]|[$IFS]|\")"
TYPE_GLOB="*([A-Za-z0-9@_/.+-])"
SPC2="*(\\\\[ntrvf]|[$IFS])"
function check_typef
{
	[[ ${*} = ${SPC1}${TYPE_GLOB}:${SPC2}* ]] ||
	[[ ${*} = *@(\\n|$'\n')${SPC1}${TYPE_GLOB}:${SPC2}* ]]
}
#set interlocutor if none set
function set_typef
{
	check_typef "$*" || return
	SET_TYPE="$*"
	SET_TYPE="${SET_TYPE%%:*}"
	SET_TYPE="${SET_TYPE##$SPC1}"
}

#set output image size
function set_sizef
{
	case "$1" in
		1024*|[Ll]arge|[Ll]) 	OPTS=1024x1024;;
		512*|[Mm]edium|[Mm]) 	OPTS=512x512;;
		256*|[Ss]mall|[Ss]) 	OPTS=256x256;;
		*) 	return 1;;
	esac ;return 0
}

#command run feedback
function cmd_verf
{
	((OPTV)) || printf "${BWhite}%-11s => %s${NC}\\n" "$1" "${2:-unset}" >&2
}

#check if input is a command
function check_cmdf
{
	[[ ${*//[$IFS:]} = [/!-]* ]] || return
	set -- "${*##*([$IFS:\/!])}"
	case "$*" in
		-[0-9]*|[0-9]*|max*)
			set -- "${*%.*}" ;set -- "${*//[!0-9]}"
			OPTMAX="${*:-$OPTMAX}"
			cmd_verf 'Max tokens' "$OPTMAX"
			;;
		-a*|pre*|presence*)
			set -- "${*//[!0-9.]}"
			OPTA="${*:-$OPTA}"
			fix_dotf OPTA  ;cmd_verf 'Presence' "$OPTA"
			;;
		-A*|freq*|frequency*)
			set -- "${*//[!0-9.]}"
			OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA ;cmd_verf 'Frequency' "$OPTAA"
			;;
		-c|br|break|session)
			break_sessionf
			;;
		-[Hh]|hist*|history)
			__edf "$FILECHAT"
			;;
		-[L]|log*)
			((OPTLOG)) && unset OPTLOG || OPTLOG=1
			set -- "${*##-L}" ;set -- "${*##log}"
			USRLOG="${*:-$USRLOG}"
			[[ "$USRLOG" = "$OLD_USRLOG" ]] \
			|| cmd_verf $'\nLog file' "\`\`$USRLOG''"
			OLD_USRLOG="$USRLOG"
			;;
		-m*|mod*|model*)
			set -- "${*#-m}"
			set -- "${*#model}" ;set -- "${*#mod}"
			if [[ $* = *[a-zA-Z]* ]]
			then 	MOD="${*//[$IFS]}"  #by name
			else 	MOD="${MODELS[${*//[!0-9]}]}" #by index
			fi ;set_model_epnf "$MOD" ;cmd_verf 'Model' "$MOD"
			((EPN==6)) && OPTC=2 || OPTC=1
			;;
		-p*|top*)
			set -- "${*//[!0-9.]}"
			OPTP="${*:-$OPTP}"
			fix_dotf OPTP  ;cmd_verf 'Top P' "$OPTP"
			;;
		-t*|temp*|temperature*)
			set -- "${*//[!0-9.]}"
			OPTT="${*:-$OPTT}"
			fix_dotf OPTT  ;cmd_verf 'Temperature' "$OPTT"
			;;
		-v|ver|verbose)
			((OPTV)) && unset OPTV || OPTV=1
			;;
		-V|blk|block)
			((OPTVV)) && unset OPTVV || OPTVV=1
			;;
		-VV|[/!]blk|[/!]block)  #debug
			OPTVV=2
			;;
		-x|ed|editor)
			((OPTX)) && unset OPTX || OPTX=1
			;;
		q|quit|exit|bye)
			exit
			;;
		*) 	return 1
			;;
	esac ;return 0
}

#main plain text editor
function __edf
{
	${VISUAL:-${EDITOR:-vim}} "$1" </dev/tty >/dev/tty
}

#text editor wrapper
function edf
{
	typeset ed_msg pre pos_input pos REPLY
	
	if ((OPTC>0))
	then 	pos_input="${*:-${SET_TYPE:-$Q_TYPE}: }"
		EPN= set_histf "$pos_input"
		ed_msg=",,,,,,(edit below this line),,,,,,"
		pre=$(unescapef "$HIST${HIST:+\\n\\n$ed_msg}")
		printf "%s${pre:+\\n}" "$pre" >"$FILETXT"
		printf "${pre:+\\n}%s\\n" "$pos_input" >>"$FILETXT"
	elif ((!OPTC))
	then 	printf "%s\\n" "$*" >"$FILETXT"
	fi
	
	__edf "$FILETXT"
	
	if ((OPTC)) && pos=$(<"$FILETXT") && [[ "$pos" != "$pre" ]]
	then 	while [[ "$pos" != "$pre"* ]] || [[ "$pos" = *"${pos_input:-$*}" ]]
		do 	__warmsgf "Warning:" "Bad edit: [E]dit, [r]edo or [c]ontinue? " ''
			REPLY=$(__read_charf)
			case "${REPLY:-$1}" in
				[CcNnQqAa]) 	break;;  #continue
				[Rr]*) 	return 200;;  #redo
				[Ee]|*) __edf "$FILETXT"  #edit
					pos=$(<"$FILETXT");;
			esac
		done
		set -- "${pos#*"$pre"}" ;set -- "${*##*([$IFS])}"
		check_cmdf "${*#*:}" && return 200
		printf "%s\\n" "$*" >"$FILETXT"
	fi
	return 0
}

#print msg to stderr
#usage: __sysmsgf [string_one] [string_two] ['']
function __sysmsgf
{
	((OPTV)) || printf "${BWhite}%s${NC}${2:+ }%s${3-\\n}" "$1" "$2" >&2
}

function __warmsgf
{
	printf "${Red}%s${NC}${2:+ }${Red}%s${NC}${3-\\n}" "$1" "$2" >&2
}

function escapef
{
	typeset var
	var="${*%%*([$IFS])}" var="${var##*([$IFS])}"
 	var=${var//[\"]/\\\"}          #double quote marks
	var=${var//[$'\t']/\\t}        #tabs
	var=${var//[$'\n\r\v\f']/\\n}  #new line/form feed
 	var=${var//\\\\[\"]/\\\"}      #rm excess escapes
 	var=${var//\\\\[n]/\\n}
 	var=${var//\\\\[t]/\\t}
	printf '%s\n' "$var"
}

function unescapef
{
	typeset var
 	var=${*//\\\"/\"}
	var=${var//\\t/$'\t'}
	var=${var//\\n/$'\n'}
	printf '%s\n' "$var"
}

function break_sessionf
{
	[[ -e "$FILECHAT" ]] || return
	[[ BREAK$(tail -n 20 "$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] \
	|| tee -a -- "$FILECHAT" >&2 <<<'SESSION BREAK'
}

#fix variable value, add zero before/after dot.
function fix_dotf
{
	eval "[[ \$$1 = .[0-9]* ]] && $1=0\$${1}"
	eval "[[ \$$1 = *[0-9]. ]] && $1=\${${1}}0"
}

#minify json
function json_minif
{
	typeset blk
	blk=$(jq -c . <<<"$BLOCK") || return
	BLOCK="${blk:-$BLOCK}"
}

#format for chat completions endpoint
function fmt_ccf
{
	printf '{"role": "%s", "content": "%s"}\n' "${2:-user}" "$1"
}

#create user log
function usr_logf
{
	[[ -d $USRLOG ]] && USRLOG="$USRLOG/${FILETXT##*/}"
	[[ "$USRLOG" = '~'* ]] && USRLOG="${HOME}${USRLOG##\~}"
	printf '%s\n\n' "$(date -R 2>/dev/null||date)" "$@" > "$USRLOG"
}

#check if a value if within a fp range
#usage: check_optrangef [val] [min] [max]
function check_optrangef
{
	typeset val min max prop ret
	val="${1:-0}" min="${2:-0}" max="${3:-0}" prop="${4:-property}"
	if [[ -n $ZSH_VERSION$KSH_VERSION ]]
	then 	ret=$(( (val < min) || (val > max) ))
	elif command -v bc
	then 	ret=$(bc <<<"($val < $min) || ($val > $max)")
	fi >/dev/null 2>&1
	((ret)) && printf "${Red}Warning: bad %s -- ${BRed}%s${NC}  ${Yellow}(%s - %s)${NC}\\n" "$prop" "$val" "$min" "$max" >&2
	return ${ret:-0}
}

#check and set settings
function set_optsf
{
	typeset s n
	check_optrangef "$OPTA" -2.0 2.0 'Presence Penalty'
	check_optrangef "$OPTAA" -2.0 2.0 'Frequency Penalty'
	check_optrangef "${OPTB:-$OPTN}" $OPTN 50 BestOf
	check_optrangef "$OPTBB" 0 5 LogProbs
	check_optrangef "$OPTP" 0.0 1.0 Top_p
	check_optrangef "$OPTT" 0.0 2.0 Temperature  #whisper max=1
	((OPTI)) && check_optrangef "$OPTN" 1 10 'Number of Results'
	[[ -n ${OPTT#0} ]] && [[ -n ${OPTP#1} ]] \
	&& __warmsgf "Warning:" "Temperature and Top_p are both set"

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	[[ -n $OPTB ]] && OPTB_OPT="\"best_of\": $OPTB," || unset OPTB_OPT
	[[ -n $OPTBB ]] && OPTBB_OPT="\"logprobs\": $OPTBB," || unset OPTBB_OPT
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
	
	if ((${#STOPS[@]}))
	then  #compile stop sequences  #def: <|endoftext|>
		unset OPTSTOP
		for s in "${STOPS[@]}" ${SET_TYPE:+"$SET_TYPE:"} 
		do 	[[ -n $s ]] || continue
			((++n)) ;((n>4)) && break
			OPTSTOP="${OPTSTOP}${OPTSTOP:+,}\"$(escapef "$s")\""
		done
		if ((n==1))
		then 	OPTSTOP="\"stop\":${OPTSTOP},"
		elif ((n))
		then 	OPTSTOP="\"stop\":[${OPTSTOP}],"
		fi
	fi #https://help.openai.com/en/articles/5072263-how-do-i-use-stop-sequences
}

#record mic
#usage: recordf [filename]
function recordf
{
	typeset termux pid REPLY

	[[ -e $1 ]] && rm -- "$1"  #remove file before writing to it
	if { 	((!OPTV)) && ((!SKIP)) ;} || [[ ! -t 1 ]]
	then 	printf "\\r${BWhite}${On_Purple}%s${NC}\\n\\n" ' * Press any key to START record * ' >&2
		__read_charf
	fi ;printf "\\r${BWhite}${On_Purple}%s${NC}\\n\\n" ' * Press any key to STOP record * ' >&2

	if [[ -n ${REC_CMD%% *} ]] && command -v ${REC_CMD%% *} >/dev/null 2>&1
	then 	$REC_CMD "$1" &  #this ensures max user compat
	elif command -v termux-microphone-record >/dev/null 2>&1
	then 	termux=1
		termux-microphone-record -c 1 -l 0 -f "$1" &
	elif command -v sox  >/dev/null 2>&1
	then 	#sox, best auto option
		{ 	rec "$1" & pid=$! ;} ||
		{ 	sox -d "$1" & pid=$! ;}
	elif command -v arecord  >/dev/null 2>&1
	then 	#alsa-utils
		arecord -i "$1" &
	else 	#ffmpeg
		{ 	ffmpeg -f alsa -i pulse -ac 1 -y "$1" & pid=$! ;} ||
		{ 	ffmpeg -f avfoundation -i ":1" -y "$1" & pid=$! ;}
		#-acodec libmp3lame -ab 32k -ac 1  #https://stackoverflow.com/questions/19689029/
	fi >&2
	pid=${pid:-$!}
	trap "__recordkillf $pid $termux ;return 2" INT HUP TERM EXIT
	read ;__recordkillf $pid $termux ;trap "-" INT HUP TERM EXIT
	wait
}
#avfoundation for macos: <https://apple.stackexchange.com/questions/326388/>
function __recordkillf
{
	typeset pid termux ;pid=$1 termux=$2
	((termux)) && termux-microphone-record -q >&2 || kill -INT $pid
}

#whisper
function whisperf
{
	typeset file lang REPLY
	check_optrangef "$OPTT" 0 1.0 Temperature
	if [[ ! -e $1 ]] && ((!OPTC))
	then 	printf "${Purple}%s${NC} " 'Record mic input? [Y/n] ' >&2
		REPLY=$(__read_charf)
		case "$REPLY" in
			[AaNnQq]) 	:;;
			*) 	recordf "$FILEINW"
				set -- "$FILEINW" "$@";;
		esac
	fi
	if [[ ! -e $1 ]]
	then 	printf "${BRed}Err: %s${NC}\\n" 'Audio file required' >&2 ;exit 1
	elif [[ $1 != *@(mp3|mp4|mpeg|mpga|m4a|wav|webm) ]]
	then 	printf "${BRed}Err: %s${NC}\\n" 'File format not supported' >&2 ;exit 1
	else 	file="$1" ;shift
	fi ;[[ -e $1 ]] && shift  #get rid of eventual second filename
	#set language ISO-639-1 (two letters)
	if [[ $1 = [a-z][a-z] ]]
	then 	if ((!OPTWW))
		then 	lang="-F language=$1"
			((OPTV)) || printf 'Audio language -- %s\n' "$1" >&2
		fi
		shift
	fi
	#set a prompt
	[[ -z ${*//[$IFS]} ]] || set -- -F prompt="$(escapef "$*")"
	prompt_audiof "$file" $lang "$@"
	jq -r '.text' "$FILE" || cat -- "$FILE"
}

#image edits/variations
function imgvarf
{
	typeset size prompt mask REPLY
	[[ -e ${1:?input PNG path required} ]]

	if command -v magick >/dev/null 2>&1
	then 	if ! __is_pngf "$1" || ! __is_squaref "$1" ||
			{ 	(($# > 1)) && [[ ! -e $2 ]] ;} || [[ -n ${OPT_AT+force} ]]
		then  #not png or not square, or needs alpha
			if (($# > 1)) && [[ ! -e $2 ]]
			then  #needs alpha
				__set_alphaf "$1"
			else  #no need alpha
			      #resize and convert (to png32?)
				if __is_opaquef "$1"
				then  #is opaque
					ARGS="" PNG32="" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, opaque image' >&2
				else  #is transparent
					ARGS="-alpha set" PNG32="png32:" ;((OPTV)) ||
					printf '%s\n' 'Alpha not needed, transparent image' >&2
				fi
			fi
			__img_convf "$1" $ARGS "${png32}${FILEIN}" &&
				set -- "${FILEIN}" "${@:2}"  #adjusted
		else 	((OPTV)) ||
			printf '%s\n' 'No adjustment needed in image file' >&2
		fi ;unset ARGS PNG32
						
		if [[ -e $2 ]]  #edits + mask file
		then 	size=$(__print_imgsizef "$1") 
			if ! __is_pngf "$2" || {
				[[ $(__print_imgsizef "$2") != "$size" ]] &&
				{ 	((OPTV)) || printf '%s\n' 'Mask size differs' >&2 ;}
			} || __is_opaquef "$2" || [[ -n ${OPT_AT+true} ]]
			then 	mask="${FILEIN%.*}_mask.png" PNG32="png32:" ARGS=""
				__set_alphaf "$2"
				__img_convf "$2" -scale "$size" $ARGS "${PNG32}${mask}" &&
					set  -- "$1" "$mask" "${@:3}"  #adjusted
			else 	((OPTV)) ||
				printf '%s\n' 'No adjustment needed in mask file' >&2
			fi
		fi
	fi ;unset ARGS PNG32
	
	__chk_imgsizef "$1" || exit 2

	## one prompt  --  generations
	## one file  --  variations
	## one file (alpha) and one prompt  --  edits
	## two files, (and one prompt)  --  edits
	if [[ -e $1 ]] && (($# > 1))  #img edits
	then 	OPTII=1 EPN=9 MOD=image-ed
		if (($# > 2)) && [[ -e $2 ]]
		then 	prompt="${@:3}" ;set -- "${@:1:2}" 
		elif (($# > 1)) && [[ ! -e $2 ]]
		then 	prompt="${@:2}" ;set -- "${@:1:1}"
		fi
		[[ -e $2 ]] && set -- "${@:1:1}" -F mask="@$2"
	elif [[ -e $1 ]]  #img variations
	then 	OPTII=1 EPN=4 MOD=image-var
	fi
	[[ -n $prompt ]] && set -- "$@" -F prompt="$prompt"

	prompt_imgvarf "$@"
	prompt_imgprintf
}
#https://legacy.imagemagick.org/Usage/resize/
#https://imagemagick.org/Usage/masking/#alpha
#https://stackoverflow.com/questions/41137794/
#https://stackoverflow.com/questions/2581469/
#https://superuser.com/questions/1491513/
#
#set alpha flags for IM
function __set_alphaf
{
	unset ARGS PNG32
	if __has_alphaf "$1"
	then  #has alpha
		if __is_opaquef "$1"
		then  #is opaque
			ARGS="-alpha set -fuzz ${OPT_AT_PC:-0}% -transparent ${OPT_AT:-black}" PNG32="png32:"
			((OPTV)) ||
			printf '%s\n' 'File has alpha but is opaque' >&2
		else  #is transparent
			ARGS="-alpha set" PNG32="png32:"
			((OPTV)) ||
			printf '%s\n' 'File has alpha and is transparent' >&2
		fi
	else  #no alpha, is opaque
		ARGS="-alpha set -fuzz ${OPT_AT_PC:-0}% -transparent ${OPT_AT:-black}" PNG32="png32:"
		((OPTV)) ||
		printf '%s\n' 'File has alpha but is opaque' >&2
	fi
}
#check if file ends with .png
function __is_pngf
{
	if [[ $1 != *.[Pp][Nn][Gg] ]]
	then 	((OPV)) || printf '%s\n' 'Not a PNG image' >&2
		return 1
	fi ;return 0
}
#convert image
#usage: __img_convf [in_file] [opt..] [out_file]
function __img_convf
{
	typeset REPLY
	((OPTV)) || {
		[[ $ARGS = *-transparent* ]] &&
		printf "${BWhite}%-12s -- %s${NC}\\n" "Alpha colour" "${OPT_AT:-black}" "Fuzz" "${OPT_AT_PC:-2}%" >&2
		__sysmsgf 'Edit with ImageMagick?' '[Y/n] ' ''
		REPLY=$(__read_charf) ;case "$REPLY" in [AaNnQq]) 	return 2;; *) 	:;; esac
	}

	if magick convert "$1" -background none -gravity center -extent 1:1 "${@:2}"
	then
		((OPTV)) || {
			set -- "${@##png32:}" ;__openf "${@:$#}"
			__sysmsgf 'Confirm edit?' '[Y/n] ' ''
			REPLY=$(__read_charf) ;case "$REPLY" in [AaNnQq]) 	return 2;; *) 	:;; esac
		}
	fi
}
#check for image alpha channel
function __has_alphaf
{
	typeset alpha
	alpha=$(magick identify -format '%A' "$1")
	[[ $alpha = [Tt][Rr][Uu][Ee] ]] || [[ $alpha = [Bb][Ll][Ee][Nn][Dd] ]]
}
#check if image is opaque
function __is_opaquef
{
	typeset opaque
	opaque=$(magick identify -format '%[opaque]' "$1")
	[[ $opaque = [Tt][Rr][Uu][Ee] ]]
}
#https://stackoverflow.com/questions/2581469/detect-alpha-channel-with-imagemagick
#check if image is square
function __is_squaref
{
	if (( $(magick identify -format '%[fx:(h != w)]' "$1") ))
	then 	((OPTV)) || printf '%s\n' 'Image is not square' >&2
		return 2
	fi ;return 0
}
#print image size
function __print_imgsizef
{
	magick identify -format "%wx%h\n" "$@"
}
#check file size of image
function __chk_imgsizef
{
	typeset chk_fsize
	if chk_fsize=$(wc -c <"$1" 2>/dev/null) ;(( (chk_fsize+500000)/1000000 >= 4))
	then 	__warmsgf "Warning:" "Max image size is 4MB [file:$((chk_fsize/1000))KB]"
		(( (chk_fsize+500000)/1000000 < 5))
	fi
}

#image generations
function imggenf
{
	BLOCK="{
		\"prompt\": \"${*:?IMG PROMPT ERR}\",
		\"size\": \"$OPTS\",
		\"n\": $OPTN,
		\"response_format\": \"$OPTI_FMT\"
	}"
	promptf
	prompt_imgprintf
}

#embeds
function embedf
{
	BLOCK="{
		\"model\": \"$MOD\",
		\"input\": \"${*:?INPUT ERR}\",
		\"temperature\": $OPTT, $OPTP_OPT
		\"max_tokens\": $OPTMAX,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
}

#edits
function editf
{
	BLOCK="{
		\"model\": \"$MOD\",
		\"instruction\": \"${1:-:?EDIT MODE ERR}\",
		\"input\": \"${@:2}\",
		\"temperature\": $OPTT, $OPTP_OPT
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
}


#parse opts
while getopts a:A:b:B:cCefhHijlL:m:n:kK:p:s:S:t:vVxwWz0123456789@: c
do 	fix_dotf OPTARG
	case $c in
		@) 	OPT_AT="$OPTARG"  #colour name/spec
			if [[ $OPTARG = *%* ]]  #fuzz percentage
			then 	if [[ $OPTARG = *% ]]
				then 	OPT_AT_PC="${OPTARG##${OPTARG%%??%}}"
					OPT_AT_PC="${OPT_AT_PC:-${OPTARG##${OPTARG%%?%}}}"
					OPT_AT_PC="${OPT_AT_PC//[!0-9]}" 
					OPT_AT="${OPT_AT%%"$OPT_AT_PC%"}"
				else 	OPT_AT_PC="${OPTARG%%%*}"
					OPT_AT="${OPT_AT##*%}"
					OPT_AT="${OPT_AT##"$OPT_AT_PC%"}"
				fi ;OPT_AT_PC="${OPT_AT_PC##0}"
			fi;;
		[0-9]) 	OPTMAX="$OPTMAX$c";;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		b) 	OPTB="$OPTARG";;
		B) 	OPTBB="$OPTARG";;
		c) 	((++OPTC));;
		C) 	((++OPTRESUME));;
		e) 	OPTE=1 EPN=2;;
		f$OPTF) 	unset MOD MOD_AUDIO INSTRUCTION CHATINSTR EPN OPTM OPTMM OPTMAX OPTA OPTAA OPTB OPTBB OPTP OPTT KSH_EDIT_MODE
			OPTF=1 ;. "$0" "$@" ;exit;;
		h) 	printf '%s\n' "$MAN" ;exit ;;
		H) 	__edf "$FILECHAT" ;exit ;;
		i) 	OPTI=1 EPN=3 MOD=image;;
		j) 	OPTJ=1;;
		l) 	OPTL=1;;
		L) 	OPTLOG=1 USRLOG="$OPTARG"
			cmd_verf 'Log file' "\`\`$USRLOG''"
			;;
		m) 	OPTMARG="$OPTARG"
			if [[ $OPTARG = *[a-zA-Z]* ]]
			then 	MOD="$OPTARG"  #set model name
			else 	MOD="${MODELS[OPTARG]}" #set one pre defined model number
			fi;;
		n) 	OPTN="$OPTARG" ;;
		k) 	OPTK=1;;
		K) 	OPENAI_KEY="$OPTARG";;
		p) 	OPTP="$OPTARG";;
		s) 	((${#STOPS[@]})) && STOPS=("$OPTARG" "${STOPS[@]}") \
			|| STOPS=("$OPTARG");;
		S) 	if [[ -e "$OPTARG" ]]
			then 	INSTRUCTION=$(<"$OPTARG")
			else 	INSTRUCTION="$OPTARG"
			fi;;
		t) 	OPTT="$OPTARG";;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		x) 	OPTX=1;;
		w) 	OPTW=1;;
		W) 	OPTW=1 OPTWW=1;;
		z) 	OPTZ=1;;
		\?) 	exit 1;;
	esac
done ; unset c
shift $((OPTIND -1))

[[ -t 1 ]] || OPTK=1 ;((OPTK)) ||
# Normal Colours    # Bold              # Background
Black='\e[0;30m'   BBlack='\e[1;30m'   On_Black='\e[40m'  \
Red='\e[0;31m'     BRed='\e[1;31m'     On_Red='\e[41m'    \
Green='\e[0;32m'   BGreen='\e[1;32m'   On_Green='\e[42m'  \
Yellow='\e[0;33m'  BYellow='\e[1;33m'  On_Yellow='\e[43m' \
Blue='\e[0;34m'    BBlue='\e[1;34m'    On_Blue='\e[44m'   \
Purple='\e[0;35m'  BPurple='\e[1;35m'  On_Purple='\e[45m' \
Cyan='\e[0;36m'    BCyan='\e[1;36m'    On_Cyan='\e[46m'   \
White='\e[0;37m'   BWhite='\e[1;37m'   On_White='\e[47m'  \
Alert=$BWhite$On_Red  NC='\e[m'  JQCOL='def red: "\u001b[31m";
def bgreen: "\u001b[1;32m"; def bwhite: "\u001b[1;37m";
def yellow: "\u001b[33m"; def byellow: "\u001b[1;33m"; def reset: "\u001b[0m";'

OPTMAX="${OPTMAX:-$OPTMM}"
OPENAI_KEY="${OPENAI_KEY:-${OPENAI_API_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTC)) && ((OPTE+OPTI)) && unset OPTC ;((OPTL+OPTZ)) && OPTX=  ;set_optsf
if ((OPTI+OPTII))
then 	command -v base64 >/dev/null 2>&1 || OPTI_FMT=url
	if set_sizef "${OPTS:-$1}"
	then 	[[ -n $OPTS ]] || shift
	elif set_sizef "${OPTS:-$2}"
	then 	[[ -n $OPTS ]] || set -- "$1" "${@:3}"
	fi
	[[ -e $1 ]] && OPTII=1  #img edits and variations
fi
[[ -n $OPTMARG ]] ||
if ((OPTE))  #edits
then 	OPTM=8 MOD="$MOD_EDIT"
elif ((OPTC>1))  #chat
then 	OPTM=10 MOD="$MOD_CHAT"
elif ((OPTW)) && ((!OPTC))  #audio
then 	OPTM=11 MOD="$MOD_AUDIO"
fi
MOD="${MOD:-${MODELS[OPTM]}}"
[[ -n $EPN ]] || set_model_epnf "$MOD"
[[ -n ${INSTRUCTION//[$IFS]} ]] || unset INSTRUCTION

(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"

((OPTX)) && ((OPTE+OPTEMBED+OPTI+OPTII)) &&
edf "$@" && set -- "$(<"$FILETXT")"  #editor

((OPTC)) && OPTT="${OPTT:-0.6}" || OPTT="${OPTT:-0}"  #temp
((OPTL+OPTZ+OPTW)) || ((!$#)) || token_prevf "$@"

for arg  #escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done ;unset arg init

mkdir -p "$CACHEDIR" || exit
command -v jq >/dev/null 2>&1 || function jq { 	false ;}

if ((OPTZ))        #last received json
then 	lastjsonf
elif ((OPTL))      #model list
then 	list_modelsf "$@"
elif ((OPTW)) && ((!OPTC))  #audio transcribe/translation
then 	whisperf "$@"
elif ((OPTII))     #image variations/edits
then 	__sysmsgf 'Image Variations / Edits'
	imgvarf "$@"
elif ((OPTI))      #image generations
then 	__sysmsgf 'Image Generations'
	imggenf "$@"
elif ((OPTEMBED))  #embeds
then 	[[ $MOD = *embedding* ]] \
	|| __warmsgf "Warning:" "Not an embedding model -- $MOD"
	embedf "$@"
elif ((OPTE))      #edits
then 	[[ -e $1 ]] && set -- "$(<"$1")" "${@:2}"
	if (($# == 1)) && ((${#INSTRUCTION}))
	then 	set -- "$INSTRUCTION" "$@"
		__sysmsgf 'INSTRUCTION:' "$INSTRUCTION" 
	fi
	[[ $MOD = *edit* ]] \
	|| __warmsgf "Warning:" "Not an edits model -- $MOD"
	editf "$@"
else               #completions
	if [[ $MOD = *-edit* ]]
	then 	function set_typef { : ;}
		__sysmsgf 'Code Completions'
	fi
	[[ -e $1 ]] && set -- "$(<"$1")" "${@:2}"  #load file as 1st arg
	((OPTW)) && { 	INPUT_ORIG=("$@") ;unset OPTX ;set -- ;}  #whisper input

	#chatbot instruction
	if ((OPTC+OPTRESUME))
	then 	((OPTRESUME==1)) || {
		  break_sessionf
		  INSTRUCTION="${INSTRUCTION:-Be a nice chat bot.}"
		  push_tohistf "$(escapef ":${INSTRUCTION##:}")"
		  (( OLD_TOTAL += $(__tiktokenf ":$INSTRUCTION" "4") ))
		  __sysmsgf 'INSTRUCTION:' "${INSTRUCTION##:}" 
		} ;unset INSTRUCTION
		((OPTRESUME>1)) || {
		  #chatbot must sounds like a human, shouldn't be lobotomised
		  [[ -n $OPTA ]] || OPTA=0.4  #playGround: temp:0.9 presencePenalty:0.6
		  ((${#STOPS[@]})) && STOPS=("${STOPS[@]}" "$Q_TYPE:" "$A_TYPE:") \
		  || STOPS=("$Q_TYPE:" "$A_TYPE:")
		}
	fi

	#load history (only ksh/bash)
	[[ -n $BASH_VERSION ]] && { 	history -c ;history -r ;}
	[[ -n $KSH_VERSION ]] && read -s <<<""
	WSKIP=1 SKIP= EDIT= N=0
	while :
	do 	if ((OPTC+OPTRESUME))  #chat mode
		then 	if ((!N)) && (($#))  #first pass
			then 	check_cmdf "$*" && { 	set -- ;continue ;}
				if [[ -n $BASH_VERSION ]]
				then 	history -s -- "$*"
				else 	print -s -- "$*"  #zsh/ksh
				fi
			fi
		fi

		#text editor prompter
		if ((OPTX))
		then 	edf "$@" || continue  #bad edit: sig: 200
			while printf "${BCyan}%s${NC}\\n" "${REC_OUT##$SPC1"${SET_TYPE:-$Q_TYPE}":$SPC2}"
			do 	((OPTV==1)) || new_prompt_confirmf
				case $? in
					201) 	break 2;;  #abort
					200) 	continue 2;;  #redo
					199) 	OPTC=-1 edf "$@" || break 2;;  #edit
					0) 	set -- "$(<"$FILETXT")" ; break;;  #yes
					*) 	set -- ; break;;  #no
				esac
			done
		fi

		#defaults prompter
		if [[ ${*//[$'\t\n'\"]} = *($TYPE_GLOB:) ]]
		then 	while { 	((SKIP)) && { 	((OPTK)) || printf "${BCyan}" >&2 ;} ;} ||
				printf "${BWhite}%s${NC}[${Purple}%s${NC}%s${NC}]:\\n${BCyan}" \
				"Prompt" "${OPTW:+VOICE-}" "${SET_TYPE:-$Q_TYPE}" >&2
			do 	if ((OPTW))
				then 	((OPTV==1)) && ((!WSKIP)) && [[ -t 1 ]] \
					&& __read_charf -t $((SLEEP/4))  #3-6 (words/tokens)/sec
					
					recordf "$FILEINW" || break
					REPLY=$(
						MOD="${MOD_AUDIO:-${MODELS[11]}}" OPTT=0
						set_model_epnf "$MOD"
						whisperf "$FILEINW" "${INPUT_ORIG[@]}"
					)
					printf "${BPurple}%s${NC}${REPLY:+\\n---\\n}" "${REPLY:-"(EMPTY)"}" >&2
				else
					if [[ -n $ZSH_VERSION ]]
					then 	((EDIT)) || unset REPLY ;unset arg
						((OPTK)) || arg='-p%B%F{14}' #cyan=14
						vared -c -e -h $arg REPLY
					else
						read -r ${BASH_VERSION:+-e} \
						${EDIT:+${BASH_VERSION:+-i "$REPLY"} ${KSH_VERSION:+-v}} REPLY
					fi
				
					if check_cmdf "$REPLY"
					then
						continue 2
					elif [[ ${REPLY//[$IFS]} = */ ]]
					then
						REPLY="${REPLY%/*}" REPLY_OLD="$REPLY"
						optv_save=${OPTV:-0} OPTV=1 RETRY=1
						((OPTK)) || BCyan='\e[0;36m' 
					elif [[ -n $REPLY ]]
					then
						((RETRY)) || new_prompt_confirmf
						case $? in
							201) 	break 2;;  #abort
							200) 	WSKIP=1 ;continue;;  #redo
							199) 	WSKIP=1 EDIT=1 ;continue;;  #edit
							0) 	:;;  #yes
							*) 	unset REPLY; set -- ;break;;  #no
						esac
						set -- "$REPLY"

						if ((RETRY))
						then 	if [[ "$REPLY" = "$REPLY_OLD" ]]
							then 	RETRY=2 REPLY_OLD= 
								((OPTK)) || BCyan='\e[1;36m'
							fi
							REPLY_OLD="$REPLY"
						fi
						OPTV=${optv_save:-$OPTV}
						unset optv_save
					else
						set --
					fi
				fi ;((OPTK)) || printf "${NC}" >&2
				unset WSKIP SKIP EDIT arg
				break
			done
		fi

		if [[ -z "$INSTRUCTION$*" ]]
		then 	printf "${BRed}Err: %s${NC}\\n" 'PROMPT is empty!' >&2
			__read_charf -t 1 ;set -- ; continue
		fi ;set -- "${*##$SPC1}"

		if ((OPTC+OPTRESUME))
		then 	((RETRY==1)) ||
			if [[ -n $KSH_VERSION ]]
			then 	read -r -s <<<"$*"
			elif [[ -n $BASH_VERSION ]]
			then 	history -s -- "$*" ;history -a
			else 	print -s -- "$*"  #zsh
			fi

			if set_typef "${*}"
			then 	REC_OUT="${*}"
			else 	REC_OUT="${SET_TYPE:-${Q_TYPE}}: ${*}"
				set -- "${REC_OUT}"
			fi

			if [[ $REC_OUT = :* ]]
			then 	#system/instruction?
				push_tohistf "$(escapef "$REC_OUT")"
				__sysmsgf "System/Instruction added"
				unset REC_OUT ;set -- ;continue
			fi
		fi

		((RETRY>1)) ||
		if ((EPN==6))
		then  #chat cmpls
			((OPTC+OPTRESUME)) && set_histf "$@"
			[[ ${*//[$IFS]} = :* ]] && role=system || role=user
			set -- "$(fmt_ccf "$(escapef "${*##$SPC1"${SET_TYPE:-$Q_TYPE}":$SPC2}")" "$role")"
			[[ -n $HIST_C ]] && set -- "${HIST_C},$*"
			[[ -n $INSTRUCTION ]] && set -- "$(fmt_ccf "$(escapef "$INSTRUCTION")" system),$*"
			unset role
		else  #text compls
			((OPTC+OPTRESUME)) && set_histf "$@"
			[[ -n $INSTRUCTION ]] && INSTRUCTION="$(escapef "$INSTRUCTION")"
			set -- "$INSTRUCTION${INSTRUCTION:+\\n\\n}$HIST${*:+\\n\\n}$(escapef "$*")"
			((OPTC)) && set -- "${*}\\n\\n${A_TYPE}:"
		fi
		
		set_optsf

		if ((EPN==6))
		then 	BLOCK="\"messages\": [${*%,}],"
		else 	BLOCK="\"prompt\": \"${*}\","
		fi
		BLOCK="{ $BLOCK
			\"model\": \"$MOD\",
			\"temperature\": $OPTT, $OPTA_OPT $OPTAA_OPT $OPTP_OPT
			\"max_tokens\": $OPTMAX, $OPTB_OPT $OPTBB_OPT $OPTSTOP
			\"n\": $OPTN
		}"

		#request prompt
		((RETRY>1)) || promptf \
		|| { 	EDIT=1 SKIP=1 ; set -- ;continue ;} #opt -VV
		
		#response prompt
		if ((RETRY>1))  #jq colours
		then 	unset JQCOL2
		elif ((RETRY))
		then 	((OPTK)) || JQCOL2='def byellow: yellow;'
		fi
		prompt_printf ;[[ -t 1 ]] || OPTV=1 prompt_printf >&2
		
		((RETRY==1)) && { 	SKIP=1 EDIT=1 ;set -- ;continue ;}

		#record to hist file
		if ((OPTC+OPTRESUME)) && {
		 	tkn=($(jq -r '.usage.prompt_tokens//"0",
				.usage.completion_tokens//"0",
				(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
			) )
			ans=$(jq '.choices[0]|.text//.message.content' "$FILE")
			ans="${ans##[\"]}" ans="${ans%%[\"]}" ans="${ans##\\[ntrvf]}"
			((${#tkn[@]}>2)) && ((${#ans}))
		}
		then 	user_type="$SET_TYPE"
			check_typef "$ans" && A_TYPE="${SET_TYPE:-$A_TYPE}" || ans="$A_TYPE: ${ans## }"
			push_tohistf "$(escapef "${REC_OUT:-$*}")" "$((tkn[0]-OLD_TOTAL))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]}" "${tkn[2]}"
			((OLD_TOTAL=tkn[0]+tkn[1]))
			SET_TYPE="$user_type"
		fi

		SLEEP="${tkn[1]}"
		((OPTLOG)) && usr_logf "$(unescapef "$*\\n\\n$ans")"

		((++N)) ;set --
		unset INSTRUCTION TKN_PREV MAX_PREV REC_OUT HIST HIST_C WSIP SKIP EDIT REPLY REPLY_OLD OPTA_OPT OPTAA_OPT OPTP_OPT OPTB_OPT OPTBB_OPT OPTSTOP RETRY user_type optv_save tkn arg ans s n
		((OPTC+OPTRESUME)) || break
	done ;unset OLD_TOTAL SLEEP N
fi
