#!/usr/bin/env ksh
# chatgpt.sh -- Ksh93/Bash/Zsh  ChatGPT/DALL-E/Whisper Shell Wrapper
# v0.8  2023  by mountaineerbr  GPL+3
[[ -n $BASH_VERSION ]] && shopt -s extglob
[[ -n $ZSH_VERSION  ]] && setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST NO_NOMATCH NO_POSIX_BUILTINS

# OpenAI API key
#OPENAI_KEY=

# DEFAULTS
# General model
#MOD=text-davinci-003
# Chat model
#MOD_CHAT=gpt-3.5-turbo
# Audio model
#MOD_AUDIO=whisper-1
# Temperature
OPTT=0
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
# Minify JSON request
#OPTMINI=
# Recorder command
#REC_CMD=

# INSTRUCTION
# Text and chat completions, and edits endpoints
#INSTRUCTION="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."

# CHATBOT INTERLOCUTORS
Q_TYPE=Q
A_TYPE=A

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
[[ -n $KSH_VERSION ]] && { 	set -o emacs -o multiline ;HISTFILE="${CACHEDIR%/}/history_ksh" ;}
[[ -n $ZSH_VERSION ]] && HISTFILE="${CACHEDIR%/}/history_zsh"
[[ -n $BASH_VERSION ]] && HISTFILE="${CACHEDIR%/}/history_bash"
HISTSIZE=512

MAN="NAME
	${0##*/} -- ChatGPT / DALL-E / Whisper  Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTION] [INPUT]
	${0##*/} -e [opt] [INSTRUCTION] [INPUT]
	${0##*/} -i [opt] [S|M|L] [PROMPT]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE] [MASK_FILE] [PROPMT]
	${0##*/} -l [MODEL_NAME]
	${0##*/} -w [opt] [AUDIO_FILE] [LANG] [PROMPT-LANG]
	${0##*/} -W [opt] [AUDIO_FILE] [PROMPT-EN]
	${0##*/} -ccw [opt] [LANG]
	${0##*/} -ccW [opt]


	All positional arguments are read as a single PROMPT. If the
	chosen model requires an INSTRUCTION and INPUT prompts, first
	positional argument is taken as INSTRUCTION and the following
	ones as INPUT or PROMPT.

	Set option -c to start the chatbot via the text completion
	endpoint and record the conversation. This option accepts various
	models, defaults to \`text-davinci-003' if none set.
	
	Set option -cc to start the chatbot via native chat completions
	and use the turbo models.

	Set -C (with -cc) to resume from last history session.

	Option -e sets the \`edits' endpoint. That endpoint requires
	both INSTRUCTION and INPUT prompts. This option requires
	setting an \`edits model'.

	Option -i generates images according to text PROMPT. If the first
	positional argument is an image file, then generate variations of it.
	If the first postional argument is an image file and the second a
	mask file (with alpha channel and transparency), and optionally,
	a text prompt, then edit the image according to mask and prompt.
	If mask is not provided, image must have transparency, which will
	be used as the mask. Optionally, set size of output image with
	[S]mall, [M]edium or [L]arge as the first positional argument.
	See IMAGES section below for more information on inpaint and out-
	paint.

	Option -w transcribes audio from mp3, mp4, mpeg, mpga, m4a, wav,
	and webm files. First positional argument must be an audio file.
	Optionally, set a two letter input language (ISO-639-1) as second
	argument. A prompt may also be set after language (must be in the
	same language as the audio). Option -W translates audio to English
	text and a prompt in English may be set to guide the model.

	Combine -wW with -cc to start chat with voice input (whisper)
	support. Output may be piped to a voice synthesiser such as
	\`espeakng', to have full voice in and out.

	Stdin is supported when there is no positional arguments left
	after option parsing. Stdin input sets a single PROMPT.

	User configuration is kept at \`${CHATGPTRC:-${CONFFILE/$HOME/"~"}}'.
	Script cache is kept at \`${CACHEDIR/$HOME/"~"}'.

	A personal (free) OpenAI API is required, set it with -K or
	see ENVIRONMENT section.

	For complete model and settings information, refer to OPENAI
	API docs at <https://beta.openai.com/docs/guides>.


TEXT COMPLETIONS
	1. Text completion
	Given a prompt, the model will return one or more predicted
	completions. For example, given a truncated input, the language
	model will try completing it. With specific instruction,
	language model SKILLS can activated, see
	<https://platform.openai.com/examples>.


	2. Chat Bot
	2.1 Text Completion Chat
	Set option -c to start chat mode of text completion. It keeps a
	history file and remembers the conversation follow-up, and works
	with a variety of models.

	2.1.1 Q&A Format
	The defaults chat format is \`Q & A'. A name such as \`NAME:'
	may be introduced as interlocutor. Setting only \`:' works as
	an instruction prompt (or to add to the previous answer), send
	an empty prompt or complete the previous answer prompt. See also
	Prompt Design.

	In the chat mode of text completion, the only initial indication 
	a conversation is to begun is given with the \`$Q_TYPE: ' interlocutor
	flag. Without initial instructions, the first replies may return
	lax but should stabilise on further promtps.
	
	Alternatively, one may set an instruction prompt with the flag
	\`: [INSTRUCTION]' or with environment variable \$INSTRUCTION.
	
	2.2 Native Chat Completions
	Set option -cc to use the chat completions. If user starts a prompt
	with \`:', message is set as \`system' (very much like instructions)
	else the message is sent as a question. Turbo models are also the
	best option for many non-chat use cases and can be set to run a
	single time setting -mgpt-3.5-turbo instead of -cc.


	3. Chat Commands
	While in chat mode the following commands (and a value), can be
	typed in the new prompt (e.g. \`!temp0.7', \`!mod1'):

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
	
	To change the chat context at run time, the history file must be
	edited with \`!hist'. Delete entries or comment them out with \`#'.


	4. Prompt Engineering and Design
	Make a good prompt. May use bullets for multiple questions in
	a single prompt. Write \`act as [technician]', add examples of
	expected results.

	Note that the model's steering and capabilities require prompt
	engineering to even know that it should answer the questions.

	For more on prompt design, see:
	<https://platform.openai.com/docs/guides/completion/prompt-design>
	<https://github.com/openai/openai-cookbook/blob/main/techniques_to_improve_reliability.md>


	5. Settings
	Temperature 	number 	Optional 	Defaults to $OPTT

	Lowering temperature means it will take fewer risks, and
	completions will be more accurate and deterministic. Increasing
	temperature will result in more diverse completions.
	Ex: low-temp:  We’re not asking the model to try to be creative
	with its responses – especially for yes or no questions.

	For more on settings, see <https://beta.openai.com/docs/guides>.


TEXT EDITS
	This endpoint is set with models with \`edit' in their name
	or option -e.

	Editing works by specifying existing text as a prompt and an
	instruction on how to modify it. The edits endpoint can be used
	to change the tone or structure of text, or make targeted changes
	like fixing spelling. We’ve also observed edits to work well on
	empty prompts, thus enabling text generation similar to the
	completions endpoint. 


IMAGES / DALL-E
	1. Image Generations
	An image can be created given a text prompt. A text description
	of the desired image(s). The maximum length is 1000 characters.


	2. Image Variations
	Variations of a given image can be generated. The image to use as
	the basis for the variations must be a valid PNG file, less than
	4MB and square.


	3. Image Edits
	Image and mask files must be provided. If mask is not provided,
	image must have transparency, which will be used as the mask. A
	text prompt is required for the edits endpoint to be used.

	3.1 ImageMagick
	If ImageMagick is available, input image will be checked and edited
	(converted) to fit dimensions and mask requirements.

	3.2 Transparent Colour and Fuzz
	A transparent colour must be set with -@[COLOUR] with colour specs
	ImageMagick can understand. Defaults=black.

	By default the colour must be exact. Use the fuzz option to match
	colours that are close to the target colour. This can be set with
	\`-@[VALUE%]' as a percentage of the maximum possible intensity,
	for example \`-@10%black'.

	See also:
	    <https://imagemagick.org/script/color.php>
	    <https://imagemagick.org/script/command-line-options.php#fuzz>

	3.3 Alpha Channel
	And alpha channel is generated with ImageMagick from any image
	with the set transparent colour (defaults to black). In this way,
	it is easy to make a mask with any black and white image as a
	template.

	3.4 In-Paint and Out-Paint
	In-painting is achieved setting an image with a mask and a prompt.
	Out-painting can be achieved manually with the aid of this script.
	Paint a portion of the outer area of an image with a defined colour
	which will be used as the mask, and set the same colour in the
	script with -@. Choose the best result amongst many to continue
	the out-painting process.


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
	Currently, only one audio model is available.


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


LIMITS
	For most models this is 2048 tokens, or about 1500 words).
	Davici model limit is 4000 tokens (~3000 words) and for
	turbo models it is 4096 tokens.

	Free trial users
	Text & Embedding        Codex          Edit        Image
                  20 RPM       20 RPM        20 RPM
             150,000 TPM   40,000 TPM   150,000 TPM   50 img/min

	RPM 	(requests per minute)
	TPM 	(tokens per minute)


BUGS
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


REQUIREMENTS
	A free OpenAI GPTChat key. Ksh93, Bash or Zsh. cURL. JQ,
	ImageMagick, and Sox/Alsa-tools/FFmpeg are optionally required.


OPTIONS
	-@ [[VAL%]COLOUR]
		 Set transparent colour of image mask. Defaults=black.
		 Fuzz intensity can be set with [VAL%]. Defaults=0%.
	-NUM 	 Set maximum tokens. Defaults=$OPTMM. Max=4096.
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
	-k [KEY] Set API key (free).
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
	-n [NUM] Set number of results. Defaults=$OPTN.
	-p [VAL] Set top_p value, nucleus sampling (cmpls/chat),
		 (unset, 0.0 - 1.0).
	-S [INSTRUCTION|FILE]
		 Set an instruction prompt.
	-t [VAL] Set temperature value (cmpls/chat/edits/audio),
		 (0.0 - 2.0, whisper 0.0 - 1.0). Defaults=$OPTT.
	-vv 	 Less verbose in chat mode.
	-VV 	 Pretty-print request body. Set twice to dump raw.
	-x 	 Edit prompt in text editor.
	-w 	 Transcribe audio file into text.
	-W 	 Translate audio file into English text.
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
	gpt-3.5-turbo-0301        #11
	#AUDIO
	whisper-1                 #12
	#GPT4
	gpt-4 #gpt-4-0314 June 14 #13
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
		*turbo*) 		EPN=6 ;((OPTC)) && OPTC=2 ;unset OPTB;;
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
	((OPTMINI)) && json_minif
	((OPTVV)) && ((!OPTII)) && { 	block_printf || return ;}

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

	printf "${BWhite}%s${NC} \\n" "Confirm prompt? [Y]es, [n]o,${OPTX:+ [e]dit,} [r]edo or [a]bort " >&2
	REPLY=$(__read_charf)
	case "${REPLY:-$1}" in
		[AaQq]*) 	return 201;;  #break
		[Rr]*) 	return 200;;  #continue
		[EeVv]*) 	return 199;;  #edf
		[Nn]*) 	unset REC_OUT TKN_PREV ;return 1;;  #no
	esac  #yes
}

#read one char from user
function __read_charf
{
	typeset REPLY
	read -n ${ZSH_VERSION:+-k} 1 "$@"
	printf '\n' >&2 ;printf '%s\n' "$REPLY"
}

#print response
function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	else 	((OPTV)) || jq -r '"Model_: \(.model//"?") (\(.object//"?"))",
			"Usage_: \(.usage.prompt_tokens) + \(.usage.completion_tokens) = \(.usage.total_tokens//empty) tokens",
			.choices[].logprobs//empty' "$FILE" >&2

		jq -r "$JQCOLOURS
		.choices[1] as \$sep | .choices[] |
		(byellow + (.text//.message.content) + reset,
		if \$sep != null then \"---\" else empty end)" "$FILE" 2>/dev/null \
		|| jq -r '.choices[]|.text//.message.content' "$FILE" 2>/dev/null \
		|| jq . "$FILE" 2>/dev/null || cat -- "$FILE"
	fi
}
#https://stackoverflow.com/questions/57298373/print-colored-raw-output-with-jq-on-terminal

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
	((OPTV)) || printf 'Prompt tokens: ~%d; Max tokens: %d\n' "$TKN_PREV" "$OPTMAX" >&2
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

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string tkn_min tkn
	string="$1" ;tkn_min=$(__tiktokenf "$string" "4")
	((tkn = ${2:-$tkn_min}>0 ? ${2:-$tkn_min} : 0))
	printf '%s\t%d\t"%s"\n' "${3:-$(date -Isec)}" "$tkn" "$string" >> "$FILECHAT"
}

#check for interlocutor
SPC1="?(*+(\\\\n|$'\n'))*([$IFS\"])"
TYPE_GLOB="*([A-Za-z0-9@_/.+-])"
SPC2="*(\\\\t|[$' \t'])"
SPC3="*(\\\\[ntrvf]|[$IFS])"
function check_typef
{
	[[ $* = $SPC1$TYPE_GLOB:$SPC3* ]]
}
#set interlocutor if none set
function set_typef
{
	check_typef "$*" || return
	SET_TYPE="$*"
	SET_TYPE="${SET_TYPE%%:*}"
	#SET_TYPE="${SET_TYPE%%$SPC2}"
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
			set_optsf
			;;
		-A*|freq*|frequency*)
			set -- "${*//[!0-9.]}"
			OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA ;cmd_verf 'Frequency' "$OPTAA"
			set_optsf
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
			set_optsf
			;;
		-t*|temp*|temperature*)
			set -- "${*//[!0-9.]}"
			OPTT="${*:-$OPTT}"
			fix_dotf OPTT  ;cmd_verf 'Temperature' "$OPTT"
			set_optsf
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
	typeset ed_msg pos REPLY
	
	if ((OPTC>0))
	then 	ed_msg=",,,,,,(edit below this line),,,,,,"
		PRE=$(unescapef "$HIST${HIST:+\\n$ed_msg}")
		printf "%s${PRE:+\\n}" "$PRE" >"$FILETXT"
		printf "${PRE:+\\n}%s\\n" "${*:-${SET_TYPE:-$Q_TYPE}: }" >>"$FILETXT"
	elif ((!OPTC))
	then 	printf "%s\\n" "$*" >"$FILETXT"
	fi
	
	__edf "$FILETXT"
	
	if ((OPTC)) && pos=$(<"$FILETXT") && [[ "$pos" != "$PRE" ]]
	then 	while [[ "$pos" != "$PRE"* ]]
		do 	printf "${Red}Warning: %s${NC} \\n" 'bad edit: [E]dit, [r]edo or [c]ontinue?' >&2
			REPLY=$(__read_charf)
			case "${REPLY:-$1}" in
				[CcNnQqAa]) 	break;;  #continue
				[Rr]*) 	return 200;;  #redo
				[Ee]|*) OPTC= edf "$@"  #edit
					pos=$(<"$FILETXT");;
			esac
		done
		set -- "${pos#*"$PRE"}"
		check_cmdf "${*#*:}" && return 200
		set_typef "$*" && REC_OUT="$*" \
		|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $*"
	fi
	return 0
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
	[[ $(tail -n 20 "$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] \
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
	blk=$(jq -c . <<<"$BLOCK") || {
		blk=${BLOCK//[$'\t\n\r\v\f']} blk="${blk//\": \"/\":\"}"
		blk="${blk//, \"/,\"}" blk="${blk//\" ,\"/\",\"}"
	}
	BLOCK="$blk"
}

#format for chat completion endpoint
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
	check_optrangef "$OPTA" -2.0 2.0 'Presence penalty'
	check_optrangef "$OPTAA" -2.0 2.0 'Frequency penalty'
	check_optrangef "$OPTB" 0 5 Logprobs
	check_optrangef "$OPTP" 0 1.0 Top_p
	check_optrangef "$OPTT" 0 2.0 Temperature  #whisper max=1
	((OPTI)) && check_optrangef "$OPTN" 1 10 NumberOfResults
	[[ -n ${OPTT#0} ]] && [[ -n ${OPTP#1} ]] \
	&& printf "${Red}Warning: %s${NC}\\n" "Temperature and Top_p are both set" >&2

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	[[ -n $OPTB ]] && OPTB_OPT="\"logprobs\": $OPTB," || unset OPTB_OPT
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
}

#record mic
#usage: recordf [filename]
function recordf
{
	typeset termux pid REPLY

	[[ -e $1 ]] && rm -- "$1"  #remove old cache audio file
	if ((!OPTV)) && ((N)) && ((!CONTINUE))
	then 	printf "\\r${BWhite}%s${NC}\\n\\n" '*** Press to START recording ***' >&2
		__read_charf
	fi ;printf "\\r${BWhite}%s${NC}\\n\\n" '*** Press to STOP recording ***' >&2

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
	fi
	pid=${pid:-$!}
	trap "__recordkillf $pid $termux ;exit 2" INT HUP TERM EXIT
	read ;__recordkillf $pid $termux ;trap "-" INT HUP TERM EXIT
	wait
}
#avfoundation for macos: <https://apple.stackexchange.com/questions/326388/terminal-command-to-record-audio-through-macbook-microphone>.
function __recordkillf
{
	((${2:-0})) && termux-microphone-record -q || kill -INT $1
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
	then 	printf "${BRed}Err: %s${NC}\\n" 'audio file required' >&2 ;exit 1
	elif [[ $1 != *@(mp3|mp4|mpeg|mpga|m4a|wav|webm) ]]
	then 	printf "${BRed}Err: %s${NC}\\n" 'file format not supported' >&2 ;exit 1
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
	[[ -n ${*//@([$IFS]|\\[ntrvf])} ]] && set -- -F prompt="$(escapef "$*")"
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
		printf "${BWhite}%s${NC} " 'Edit with ImageMagick? [Y/n]' >&2
		REPLY=$(__read_charf) ;case "$REPLY" in [AaNnQq]) 	return 2;; *) 	:;; esac
	}

	if magick convert "$1" -background none -gravity center -extent 1:1 "${@:2}"
	then
		((OPTV)) || {
			set -- "${@##png32:}" ;__openf "${@:$#}"
			printf "${BWhite}%s${NC} " 'Confirm edit? [Y/n]' >&2
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
	then 	printf "${Red}%s${NC}\\n" "Warning: max image size is 4MB [file:$((chk_fsize/1000))KB]" >&2
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
while getopts a:A:b:cCefhHijlL:m:n:kK:p:S:t:vVxwWz0123456789@: c
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
		c) 	((++OPTC));;
		C) 	((++OPTRESUME));;
		e) 	OPTE=1 EPN=2;;
		f$OPTF) 	unset MOD MOD_AUDIO INSTRUCTION CHATINSTR EPN OPTM OPTMM OPTMAX OPTA OPTAA OPTB OPTP OPTMINI KSH_EDIT_MODE
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
		K) 	OPENAI_KEY="$OPTARG";;
		p) 	OPTP="$OPTARG";;
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
White='\e[0;37m'   BWhite='\e[1;37m'   On_White='\e[47m'
Alert=$BWhite$On_Red  NC='\e[m' \
JQCOLOURS='def red: "\u001b[31m"; def bgreen: "\u001b[1;32m"; def bwhite: "\u001b[1;37m"; def yellow: "\u001b[33m"; def byellow: "\u001b[1;33m"; def reset: "\u001b[0m";'

OPTMAX="${OPTMAX:-$OPTMM}"
OPENAI_KEY="${OPENAI_KEY:-${OPENAI_API_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTC)) && ((OPTE+OPTI)) && OPTC=  ;((OPTL+OPTZ)) && OPTX=  ;set_optsf
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
if ((OPTE))
then 	OPTM=8
elif ((OPTC>1))
then 	OPTM=10 MOD="$MOD_CHAT"
elif ((OPTW)) && ((!OPTC))
then 	OPTM=12 MOD="$MOD_AUDIO"
fi
MOD="${MOD:-${MODELS[OPTM]}}"
[[ -n $EPN ]] || set_model_epnf "$MOD"

(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"

((OPTX)) && (( (OPTE+OPTEMBED+OPTI+OPTII) || (OPTW==1 && !OPTC) )) &&
edf "$@" && set -- "$(<"$FILETXT")"  #editor

((OPTL+OPTZ+OPTW)) || ((!$#)) || token_prevf "$*"

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
elif ((OPTW)) && ((!OPTC))  #audio transcribe
then 	whisperf "$@"
elif ((OPTII))     #image variations/edits
then 	((OPTV)) || printf "${BWhite}%s${NC}\\n" 'Image Variations / Edits' >&2
	imgvarf "$@"
elif ((OPTI))      #image generations
then 	((OPTV)) || printf "${BWhite}%s${NC}\\n" 'Image Generations' >&2
	imggenf "$@"
elif ((OPTEMBED))  #embeds
then 	embedf "$@"
elif ((OPTE))      #edits
then 	if (($# == 1)) && [[ -n "$INSTRUCTION" ]]
	then 	set -- "$INSTRUCTION" "$@"
		((OPTV)) || printf '%s -- "%s"\n' 'INSTRUCTION' "$INSTRUCTION" >&2
	fi
	editf "$@"
else               #completions
	if ((OPTW))  #whisper input
	then 	unset OPTX
		INPUT_ORIG=("$@") ;set --
	fi
	((OPTRESUME)) || { 	((OPTC)) && break_sessionf ;}

	#chatbot instructions
	((!${#INSTRUCTION})) || ((OPTV)) || printf "${BWhite}%s${NC}: %s\\n" 'INSTRUCTION' "$INSTRUCTION" >&2
	if ((OPTRESUME))
	then 	unset INSTRUCTION
	elif ((OPTC))
	then  #chat should have instructions??? Or can it be used anotehr way?
		INSTRUCTION="${INSTRUCTION-Be a nice bot.}"
		push_tohistf "$(escapef ": $INSTRUCTION")"
		(( OLD_TOTAL += $(__tiktokenf ": $INSTRUCTION" "4") ))
		unset INSTRUCTION
	fi

	while :
	do 	unset REPLY
		if ((OPTC))  #chat mode
		then 	if (($#))  #input from pos args, first pass
			then 	check_cmdf "$*" && { 	set -- ;continue ;}
				if [[ -n $BASH_VERSION ]]
				then 	history -s -- "$*"
				elif [[ -n $ZSH_VERSION ]]
				then 	print -s -- "$*"
				else 	read -r -s <<<"$*"  #ksh
				fi
				set_typef "$*" && REC_OUT="$*" \
				|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $*"
				set -- "${REC_OUT##*([$IFS:])}"
			fi

			#read history file
			if [[ -s "$FILECHAT" ]]
			then 	((MAX_PREV=TKN_PREV)) ;unset HIST HIST_C
				while IFS=$'\t' read -r time token string
				do 	[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
					[[ ${time//[$IFS]} = \#* ]] && continue
					[[ -n ${string//[$IFS\"]} ]] || continue
					if ((token<1))
					then 	((OPTVV>1||OPTJ)) &&
						printf "${Red}Warning: %s${NC}\\n" 'zero/neg token in history' >&2
						token=$(__tiktokenf "$string")
					fi
					if ((MAX_PREV+token<OPTMAX))
					then 	((MAX_PREV+=token))
						string="${string##[ \"]}" string="${string%%[ \"]}"
						string="${string##$SPC3:$SPC3}" HIST="$string\n\n$HIST"
						
						if ((EPN==6))  #gpt-3.5-turbo
						then 	USER_TYPE="$SET_TYPE"
							set_typef "$string" \
							&& string="${string/$SPC1${SET_TYPE:-$Q_TYPE}}" 
							case "${SET_TYPE:-:}" in
								:) 	role=system;;
								${USER_TYPE:-$Q_TYPE}|$Q_TYPE) 	role=user;;
								*) 	role=assistant;;
							esac
							HIST_C="$(fmt_ccf "${string##:$SPC3}" "$role")${HIST_C:+,}$HIST_C"
							SET_TYPE="$USER_TYPE"
						fi
					fi
				done < <(tac -- "$FILECHAT")
				((MAX_PREV-=TKN_PREV))
				unset REPLY USER_TYPE time token string role
			fi
			#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/
		fi

		#text editor prompter
		if ((OPTX))
		then 	edf "$@" || continue  #sig:200
			while printf "${BCyan}%s${NC}\\n" "${REC_OUT/$SPC1${SET_TYPE:-$Q_TYPE}:$SPC3}"
			do 	new_prompt_confirmf
				case $? in
					201) 	break 2;;  #abort
					200) 	continue 2;;  #redo
					199) 	OPTC=-1 edf "$@" || break 2;;  #edit
					0) 	set -- "$REC_OUT" ; break;;  #yes
					*) 	set -- ; break;;  #no
				esac
			done
		fi

		#defaults prompter
		if [[ ${*//[$'\t\n'\"]} = *($TYPE_GLOB:) ]]
		then 	while printf "\\n${BWhite}%s${NC}[${Purple}%s${NC}%s${NC}]:\\n${BCyan}" \
				"Prompt" "${OPTW:+VOICE-}" "${SET_TYPE:-$Q_TYPE}" >&2
			do 	if ((OPTW))
				then
					((OPTV==1)) && ((N)) && ((!CONTINUE)) \
					&& __read_charf -t $((SLEEP/4))  #3-6 (words/tokens)/sec
					recordf "$FILEINW"
					REPLY=$(MOD="${MOD_AUDIO:-${MODELS[12]}}" OPTT=0
						set_model_epnf "$MOD"
						whisperf "$FILEINW" "${INPUT_ORIG[@]}"
					) ;REPLY="${REPLY:-(EMPTY)}"
					printf "${BPurple}%s${NC}\\n---\\n" "$REPLY" >&2
				elif [[ -n $ZSH_VERSION ]]
				then
					unset REPLY arg ;((OPTK)) || arg='-p%B%F{14}' #cyan=14
					vared -h -c $arg REPLY
					print -s -- "$REPLY" ;fc -I -A ;unset arg
				else
					read -r ${BASH_VERSION:+-e} ${KSH_VERSION:+-s}
					if [[ -n $BASH_VERSION ]]
					then 	history -s -- "$REPLY" ;history -a
					else 	read -r -s <<<"$REPLY"  #ksh
					fi
				fi ;printf "${NC}" >&2
				
				check_cmdf "$REPLY" && continue 2 ;unset CONTINUE
				
				if [[ -n ${REPLY//[$IFS]} ]]
				then 	OPTX=  new_prompt_confirmf
					case $? in
						201) 	break 2;;  #abort
						200|199) 	CONTINUE=1 ;continue;;  #redo/edit
						0) 	:;;  #yes
						*) 	unset REPLY; set -- ;break;;  #no
					esac
					set_typef "$REPLY" && REC_OUT="$REPLY" \
					|| REC_OUT="${SET_TYPE:-$Q_TYPE}: $REPLY"
					set -- "$REPLY"
				else
					set --
				fi ;break
			done
		fi

################################################################################
		((!$#)) && [[ -n $REC_OUT ]] && set -- "$REC_OUT"
		if ((EPN==6))
		then
			[[ ${*//[$IFS]} = :* ]] && role=system || role=user
			set -- "$(fmt_ccf "$(escapef "${*/$SPC1${SET_TYPE:-$Q_TYPE}:$SPC3}")" "$role")"
			[[ -n $HIST_C ]] && set -- "${HIST_C},$*"
			[[ -n $INSTRUCTION ]] && set -- "$(fmt_ccf "$(escapef "$INSTRUCTION")" system),$*"
			unset role
		else
			[[ -n $INSTRUCTION ]] && INSTRUCTION="$(escapef "$INSTRUCTION\\n\\n")"
			set -- "$INSTRUCTION$HIST$(escapef "$*")"
		fi
################################################################################
		
		if ((OPTC)) && [[ ${REC_OUT//[$IFS]} = :* ]]
		then 	#instructions/system?
			push_tohistf "$(escapef "$REC_OUT")"
			unset REC_OUT TKN_PREV ;set -- ;continue
		fi
		[[ -n "${*:?PROMPT ERR}" ]]
		if ((EPN==6))
		then 	BLOCK="{\"messages\": [${*%,}],"
		else 	BLOCK="{\"prompt\": \"${*}\","
		fi
		BLOCK="$BLOCK
			\"model\": \"$MOD\",
			\"temperature\": $OPTT, $OPTA_OPT $OPTAA_OPT
			\"max_tokens\": $OPTMAX, $OPTB_OPT $OPTP_OPT 
			\"n\": $OPTN
		}"
		promptf
		prompt_printf
		[[ -t 1 ]] || OPTV=1 prompt_printf >&2

		#record to hist file
		if ((OPTC)) && {
		 	tkn=($(jq -r '.usage.prompt_tokens//"0",
				.usage.completion_tokens//"0",
				(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
			) )
			ans=$(jq '.choices[0]|.text//.message.content' "$FILE") #ans="${ans//\\\"/''}"
			ans="${ans##*([$IFS]|\\[ntrvf]|\")}" ans="${ans%\"}"
			((${#tkn[@]}>2)) && ((${#ans}))
			}
		then 	check_typef "$ans" || ans="$A_TYPE: $ans"
			push_tohistf "$(escapef "${REC_OUT:-$*}")" "$((tkn[0]-OLD_TOTAL))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]}" "${tkn[2]}"
			((OLD_TOTAL=tkn[0]+tkn[1]))
		fi
		((OPTLOG)) && usr_logf "$(unescapef "$HIST${REC_OUT:-$*}"$'\n\n'"$ans")"
		SLEEP="${tkn[1]}" ;unset tkn ans

		set --
		unset REPLY TKN_PREV MAX_PREV REC_OUT HIST PRE USER_TYPE HIST_C CONTINUE INSTRUCTION
		((++N)) ;((OPTC)) || break
	done ;unset OLD_TOTAL SLEEP N
fi
