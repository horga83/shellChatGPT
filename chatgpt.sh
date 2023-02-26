#!/usr/bin/env ksh
# chatgpt.sh -- Ksh93/Bash/Zsh ChatGPT/DALL-E Shell Wrapper
# v0.4.9  2023  by mountaineerbr  GPL+3
[[ $BASH_VERSION ]] && shopt -s extglob
[[ $ZSH_VERSION  ]] && setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST NO_POSIX_BUILTINS

# OpenAI API key
#OPENAI_KEY=

# DEFAULTS
# Model
OPTM=0
# Endpoint
EPN=0
# Temperature
OPTT=0
# Top P
OPTP=1
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

# CHATBOT INTERLOCUTORS
Q_TYPE=Q
A_TYPE=A
# Obs: no spaces allowed

# CHATBOT INSTRUCTIONS
#CHATINSTR="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."

# CACHE FILES
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/chatgptsh"
FILE="${CACHEDIR}/chatgpt.json"
FILECHAT="${FILE%.*}.tsv"
FILECONF="${FILE%.*}.conf"
FILETXT="${FILE%.*}.txt"
FILEIN="${FILE%.*}_in.png"
FILEOUT="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}/chatgpt_out.png"

# Load user defaults
[[ -e ${CHATGPTRC:-$FILECONF} ]] && . "${CHATGPTRC:-$FILECONF}"

MAN="NAME
	${0##*/} -- ChatGPT/DALL-E Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -e [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -i [opt] [256|512|1024|S|M|L] [PROMPT]
	${0##*/} -i [opt] [INPUT_PNG_PATH]
	${0##*/} -l [MODEL_NAME]

	All positional arguments are read as a single PROMPT. If the
	chosen model requires an INTRUCTION and INPUT prompts, first
	positional argument is taken as INSTRUCTIONS and the following
	ones as INPUT or PROMPT.

	Set option -c to start the chatbot and keep a record of the
	conversation in a history file.

	Option -e sets the \`edits' endpoint. That endpoint requires
	both INSTRUCTIONS and INPUT prompts. This option requires
	setting an \`edits model'.

	Option -i generates images according to PROMPT. If first
	positional argument is a picture file, then generate variation
	of it.

	Stdin is supported when there is no positional arguments left
	after option parsing. Stdin input sets a single PROMPT.

	Cache and configuration is kept at \`${CACHEDIR/$HOME/\~}'.

	A personal (free) OpenAI API is required, set it with -k or
	see ENVIRONMENT section.

	For complete model and settings information, refer to OPENAI
	API docs at <https://beta.openai.com/docs/guides>.


COMPLETIONS
	Given a prompt, the model will return one or more predicted
	completions, and can also return the probabilities of
	alternative tokens at each position.

	To keep a history of the latest context in the chat, set option
	-c. This starts a new session, keeps a record of the latest
	prompts and replies, and sends some history context with new
	questions. This option respects max tokens setting. Set -C to
	continue from last recorded session.

	The defaults chat format is \`Q & A'. A name such as \`NAME:'
	may be introduced as interlocutor. Setting \`:' only will not
	add an interlocutor to the prompt. This may be useful to
	set intructions, and completing a previous prompt.

	While in chat mode, type in one of the following (and a	value)
	in the new prompt to set options on the go:

		-a  |  !pre 	  Set presence.
		-A  |  !freq 	  Set frequency.
		-c  |  !new 	  Starts new session.
		-p  |  !top 	  Set top_p.
		-t  |  !temp 	  Set temperature.
		-v  |  !ver	  Set/unset verbose.
		-x  |  !ed 	  Set/unset text editor.
		!q  |  !quit	  Exit.


	Prompt Design
	Make a good prompt. May use bullets for multiple questions in
	a single prompt. Write \`act as [technician]', add examples of
	expected results.

	For the chatbot, the only initial indication given is a \`$Q_TYPE: '
	interlocutor flag. Without previous instructions, the first
	replies may return lax but should improve with further promtps.
	
	Alternatively, one may try setting initial instructions prompt
	with the bot identity and how it should behave as, such as:

	prompt>	\": The following is a conversation with an AI assistant.
		  The assistant is helpful, creative, clever, and friendly.\"

	reply_> \"A: Hello! How can I help you?\"

	prompt> \"Q: Hello, what is your name?\"

	Also see section ENVIRONMENT to set defaults chatbot instructions.
	For more on prompt design, see <https://platform.openai.com/docs/guides/completion/prompt-design>.


	Settings
	Temperature 	number 	Optional 	Defaults to $OPTT

	Lowering temperature means it will take fewer risks, and
	completions will be more accurate and deterministic. Increasing
	temperature will result in more diverse completions.
	Ex: low-temp:  We’re not asking the model to try to be creative
	with its responses – especially for yes or no questions.

	For more on settings, see <https://beta.openai.com/docs/guides>.


EDITS
	This endpoint is set with models with \`edit' in their name
	or option -e.

	Editing works by specifying existing text as a prompt and an
	instruction on how to modify it. The edits endpoint can be used
	to change the tone or structure of text, or make targeted changes
	like fixing spelling. We’ve also observed edits to work well on
	empty prompts, thus enabling text generation similar to the
	completions endpoint. 


IMAGES
	The first positional parameter sets the output image size
	256x256/small, 512x512/medium or 1024x1024/large. Defaults=$OPTS.

	An image can be created given a prompt. A text description of
	the desired image(s). The maximum length is 1000 characters.

	Also, a variation of a given image can be generated. The image
	to use as the basis for the variation(s). Must be a valid PNG
	file, less than 4MB and square. If Imagemagick is available,
	input image will be converted to square before upload.


SKILLS
	Q&A, Grammar correction, Summarize for a 2nd grader, Natural
	language to OpenAI API, Text to command, English to other
	languages, Natural language to Stripe API, SQL translate, Parse
	unstructured data, Classification, Python to natural language,
	Movie to Emoji, Calculate Time Complexity, Translate programming
	languages, Advanced tweet classifier, Explain code, Keywords,
	Factual answering, Ad from product description, Product name
	generator, TL;DR summarization, Python bug fixer, Spreadsheet
	creator, JavaScript helper chatbot, ML/AI language model tutor,
	Science fiction book list maker, Tweet classifier, Airport code
	extractor, SQL request, Extract contact information, JavaScript
	to Python, Friend chat, Mood to color, Write a Python docstring,
	Analogy maker, JavaScript one line function, Micro horror story
	creator, Third-person converter, Notes to summary, VR fitness
	idea generator, Essay outline, Recipe creator (eat at your own
	risk), Chat, Marv the sarcastic chat bot, Turn by turn directions,
	Restaurant review creator, Create study notes, and Interview
	questions.

	See examples at <https://platform.openai.com/examples>.


ENVIRONMENT
	CHATGPTRC 	Path to user ${0##*/} configuration.
			Defaults=${CHATGPTRC:-${FILECONF/$HOME/\~}}

	CHATINSTR 	Initial instruction set for the chatbot.

	EDITOR
	VISUAL 		Text editor for external prompt editing.
			Defaults=vim
	
	OPENAI_KEY
	OPENAI_API_KEY 	Set your personal (free) OpenAI API key.


LIMITS
	For most models this is 2048 tokens, or about 1500 words).
	Davici model limit is 4000 tokens.

	Free trial users
	Text & Embedding        Codex          Edit        Image
                  20 RPM       20 RPM        20 RPM
             150,000 TPM   40,000 TPM   150,000 TPM   50 img/min

	RPM 	(requests per minute)
	TPM 	(tokens per minute)


BUGS
	Certain PROMPTS may return empty responses. Maybe the model
	has nothing to add to the input prompt or it expects mor text.
	Try trimming spaces, appending a full stop/ellipsis, or
	resetting temperature or adding more text. See prompt deesign.

	Language models are but a mirror of human written records.


REQUIREMENTS
	A free OpenAI GPTChat key. Ksh93, Bash or Zsh. cURL. JQ and
	ImageMagick are optionally required.


OPTIONS
	-NUM 		Set maximum tokens. Max=4096, defaults=$OPTMM.
	-a [VAL]	Set presence penalty  (completions; -2.0 - 2.0).
	-A [VAL]	Set frequency penalty (completions; -2.0 - 2.0).
	-c 		Chat mode, new session (completions).
	-cc 		Chat mode, continue from last history session.
	-e [INSTRUCT] [INPUT]
			Set Edit mode, model defaults=text-davinci-edit-001.
	-h 		Print this help page.
	-i [PROMPT] 	Creates an image given a prompt.
	-i [PNG_PATH] 	Creates a variation of a given image.
	-j 		Print raw JSON data.
	-k [KEY] 	Set API key (free).
	-l 		List models.
	-m [MOD_NAME] 	Set a model name, check with -l.
	-m [NUM] 	Set model by NUM:
		  # Completions           # Moderation
		  0. text-davinci-003     6. text-moderation-latest
		  1. text-curie-001       7. text-moderation-stable
		  2. text-babbage-001
		  3. text-ada-001
		  # Codex                 # Edits
		  4. code-davinci-002     8. text-davinci-edit-001
		  5. code-cushman-001     9. code-davinci-edit-001
	-n [NUM] 	Set number of results. Defaults=$OPTN.
	-p [VAL] 	Set top_p value (0.0 - 1.0). Defaults=$OPTP.
	-t [VAL] 	Set temperature value (0.0 - 2.0). Defaults=$OPTT.
	-v 		Less verbose in chat mode.
	-VV 		View request body. Set twice to dump and exit.
	-x 		Edit prompt in text editor.
	-z 		Print last call JSON file backup."

MODELS=(
	#COMPLETIONS
	text-davinci-003          #0
	text-curie-001            #1
	text-babbage-001          #2
	text-ada-001              #3
	#codex
	code-davinci-002          #4
	code-cushman-001          #5
	#moderated
	text-moderation-latest    #6
	text-moderation-stable    #7
	#EDITS
	text-davinci-edit-001     #8
	code-davinci-edit-001     #9
)

ENDPOINTS=(
	completions               #0
	moderations               #1
	edits                     #2
	images/generations        #3
	images/variations         #4
	embeddings                #5
)



function promptf
{
	((OPTVV)) && ((!OPTII)) && { 	block_printf ;return ;}

	curl -\# ${OPTV:+-s} -L https://api.openai.com/v1/${ENDPOINTS[$EPN]} \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$BLOCK" \
		-o "$FILE"
}

function block_printf
{
	if ((OPTVV>1))
	then 	printf '%s\n' "$BLOCK" ;exit
	else	jq -r '.instruction//empty, .input//empty, .prompt//empty' <<<"$BLOCK" || printf '%s\n' "$BLOCK"
	fi
}

function new_prompt_confirmf
{
	typeset REPLY
	((OPTV)) && return

	printf '%s \n' "Confirm prompt? [Y]es, [n]o,${OPTX:+ [e]dit,} [r]edo or [a]bort" >&2
	read -r -n ${ZSH_VERSION:+-k} 1
	case "${REPLY:-$1}" in
		[AaQq]*) 	return 201;;  #break
		[Rr]*) 	return 200;;  #continue
		[EeVv]*) 	return 199;;  #edf
		[Nn]*) 	unset REC_OUT TKN_PREV ;return 1;;  #no
	esac  #yes
}

function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	else 	((OPTV)) || jq -r '"Model_: \(.model//"?") (\(.object//"?"))",
			"Usage_: \(.usage.prompt_tokens) + \(.usage.completion_tokens) = \(.usage.total_tokens//empty) tokens"' "$FILE" >&2
		jq -r '.choices[1] as $sep | .choices[] | (.text, if $sep != null then "---" else empty end)' "$FILE" \
		|| jq -r '.choices[].text' "$FILE" || cat -- "$FILE"
	fi
}

function prompt_imgvarf
{
	curl -\# ${OPTV:+-s} -L https://api.openai.com/v1/${ENDPOINTS[$EPN]} \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-F image="@$1" \
		-F response_format="$OPTI_FMT" \
		-F n="$OPTN" \
		-F size="$OPTS" \
		-o "$FILE"
}

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
			jq -r ".data[${n}].b64_json" "$FILE" | base64 -d > "$fout"
			printf 'File: %s\n' "${fout/$HOME/\~}" >&2
			((++n, ++m)) ;((n<50)) || break
		done
		((n)) || { 	cat -- "$FILE" ;false ;}
	else 	jq -r '.data[].url' "$FILE" || cat -- "$FILE"
	fi
}

function list_modelsf
{
	curl https://api.openai.com/v1/models${1:+/}${1} \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-o "$FILE"
	if [[ $1 ]]
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

function token_prevf
{
	TKN_PREV="$*" TKN_PREV=$((${#TKN_PREV}/4))
	((OPTV)) || printf 'Prompt tokens: ~%d; Max tokens: %d\n' "$TKN_PREV" "$OPTMAX" >&2
}

function check_typef
{
	TYPE_SPC1="?(*+(\\\\n|$'\n'))*([$IFS\"])"
	TYPE_GLOB="*([A-Za-z0-9@_/.+-])"
	TYPE_SPC2="*(\\\\t|[$' \t'])"
	TYPE_SPC3="*(\\\\[nt]|[$' \n\t'])"
	[[ $* = $TYPE_SPC1$TYPE_GLOB$TYPE_SPC2:$TYPE_SPC3* ]]
}
function set_typef
{
	check_typef "$*" || return
	USER_TYPE="$*"
	USER_TYPE="${USER_TYPE%%:*}"
	USER_TYPE="${USER_TYPE%%$TYPE_SPC2}"
	USER_TYPE="${USER_TYPE##$TYPE_SPC1}"
}

function check_cmdf
{
	case "${*//[$IFS]}" in
		-a*|!pre*|!presence*) 	if [[ $* = *[0-9]* ]]
			then 	OPTA="$*" OPTA="${OPTA//[!0-9.]}"
				[[ $OPTA = .[0-9]* ]] && OPTA=0$OPTA
			fi
			;;
		-A*|!freq*|!frequency*) 	if [[ $* = *[0-9]* ]]
			then 	OPTAA="$*" OPTAA="${OPTAA//[!0-9.]}"
			[[ $OPTAA = .[0-9]* ]] && OPTAA=0$OPTAA
			fi
			;;
		-[Cc]|!br|!break|!session)
			break_sessionf
			;;
		-x|!ed|!editor)
			((OPTX)) && unset OPTX || OPTX=1
			;;
		-v|!ver|!verbose)
			((OPTV)) && unset OPTV || OPTV=1
			;;
		-V|!blk|!block)
			((OPTVV)) && unset OPTVV || OPTVV=1
			;;
		-VV|!!blk|!!block)  #debug
			OPTVV=2
			;;
		-p*|!top*) 	if [[ $* = *[0-9]* ]]
			then 	OPTP="$*" OPTP="${OPTP//[!0-9.]}"
			[[ $OPTP = .[0-9]* ]] && OPTP=0$OPTP
			fi
			;;
		!q|!quit|!exit|!bye)
			exit
			;;
		-t*|!temp*|!temperature*) 	if [[ $* = *[0-9]* ]]
			then 	OPTT="$*" OPTT="${OPTT//[!0-9.]}"
			[[ $OPTT = .[0-9]* ]] && OPTT=0$OPTT
			fi
			;;
		*) 	return 1;;
	esac
	return 0
}

function edf
{
	typeset ed_msg pos REPLY
	
	if ((OPTC>0))
	then 	ed_msg=",,,,,,(edit below this line),,,,,,"
		PRE=$(unescapef "$HIST${HIST:+\\n$ed_msg}")
		printf "%s${PRE:+\\n}" "$PRE" >"$FILETXT"
		if (($#))
		then 	printf "${PRE:+\\n}%s\n" "$*"
		else 	printf "${PRE:+\\n}%s: \n" "${USER_TYPE:-$Q_TYPE}"
		fi >>"$FILETXT"
	fi
	
	${VISUAL:-${EDITOR:-vim}} "$FILETXT" </dev/tty >/dev/tty

	if ((OPTC)) && pos=$(<"$FILETXT") && [[ "$pos" != "$PRE" ]]
	then 	while [[ "$pos" != "$PRE"* ]]
		do 	printf 'Warning: %s \n' 'Bad edit: [E]dit, [r]edo or [c]ontinue?' >&2
			read -r -n ${ZSH_VERSION:+-k} 1
			case "${REPLY:-$1}" in
				[CcNnQqAa]) 	break;;  #continue
				[Rr]*) 	return 200;;  #redo
				[Ee]|*) OPTC= edf "$@"  #edit
					pos=$(<"$FILETXT");;
			esac
		done
		set -- "${pos#*"$PRE"}"
		check_cmdf "$*" && return 200
		set_typef "$*" && REC_OUT="$*" || REC_OUT="${USER_TYPE:-$Q_TYPE}: $*"
	fi
	return 0
}

function escapef
{
	typeset var
 	var=${*//[\"]/\\\"}            #double quote marks
 	var=${var//\\\\[\"]/\\\"}      #rm excess double quote escape
	var=${var//[$'\t']/\\t}        #tabs
	var=${var//[$'\n\r\v\f']/\\n}  #new line/form feed
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
	[[ $(<"$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] ||
	tee -a -- "$FILECHAT" >&2 <<<'SESSION BREAK'
}


#parse opts
while getopts a:A:cehiIjlm:n:kp:t:vVxz0123456789 c
do 	[[ $OPTARG = .[0-9]* ]] && OPTARG=0$OPTARG
	case $c in
		[0-9]) 	OPTMAX=$OPTMAX$c;;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		c) 	((OPTC++));;
		e) 	OPTE=1;;
		h) 	printf '%s\n' "$MAN" ;exit ;;
		i|I) 	OPTI=1;;
		j) 	OPTJ=1;;
		l) 	OPTL=1 ;;
		m) 	OPTMSET=1
			if [[ $OPTARG = *[a-zA-Z]* ]]
			then 	MOD=$OPTARG  #set model name
			else 	OPTM=$OPTARG #set one pre defined model number
			fi;;
		n) 	OPTN=$OPTARG ;;
		k) 	OPENAI_KEY=$OPTARG;;
		p) 	if ((OPTARG>1))
			then 	printf 'err: illegal top_p -- %s\n' "$OPTARG" >&2
			else 	OPTP=$OPTARG
			fi;;
		t) 	if ((OPTARG>2))
			then 	printf 'err: illegal temperature -- %s\n' "$OPTARG" >&2
			else 	OPTT=$OPTARG
			fi;;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		x) 	OPTX=1;;
		z) 	OPTZ=1;;
		\?) 	exit 1;;
	esac
done ; unset c
shift $((OPTIND -1))

OPTMAX=${OPTMAX:-$OPTMM}
OPENAI_KEY="${OPENAI_KEY:-${OPENAI_API_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTC)) && ((OPTE+OPTI)) && OPTC=  ;((OPTL+OPTZ)) && OPTX= 
[[ ${OPTT#0} ]] && [[ ${OPTP#1} ]] && printf '%s\n' "warning: temperature and top_p both set" >&2
[[ $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA,"
[[ $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA,"
if ((OPTI))
then 	command -v base64 >/dev/null 2>&1 || OPTI_FMT=url
	case "$1" in 	#set image size
		1024*|[Ll]arge|[Ll]) 	OPTS=1024x1024 ;shift;;
		512*|[Mm]edium|[Mm]) 	OPTS=512x512 ;shift;;
		256*|[Ss]mall|[Ss]) 	OPTS=256x256 ;shift;;
	esac ;MOD=image
	#set upload image instead
	[[ -e "$1" ]] && OPTII=1 MOD=image-var
fi
((OPTE)) && ((!OPTMSET)) && OPTM=8
MOD="${MOD:-${MODELS[$OPTM]}}"
case "$MOD" in  #set model endpoint
	image-var) 	EPN=4;;
	image) 		EPN=3;;
	code-*) 	case "$MOD" in
				*search*) 	EPN=5 OPTEMBED=1;;
				*edit*) 	EPN=2 OPTE=1;;
				*) 		EPN=0;;
			esac;;
	text-*) 	case "$MOD" in
				*embedding*|*similarity*|*search*) 	EPN=5 OPTEMBED=1;;
				*edit*) 	EPN=2 OPTE=1;;
				*moderations*) 	EPN=1;;
				*) 		EPN=0;;
			esac;;
	*) 		EPN=0;;
esac

(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"
((OPTX)) && ((!OPTC)) && edf "$@" && set -- "$(<"$FILETXT")"  #editor
((OPTI+OPTII+OPTL+OPTZ)) || ((!$#)) || token_prevf "$*"
for arg  #escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done ;unset arg init

mkdir -p "$CACHEDIR" || exit
command -v jq >/dev/null 2>&1 || function jq { 	false ;}

if ((OPTZ))
then 	lastjsonf
elif ((OPTL))
then 	list_modelsf "$@"
elif ((OPTII))     #image variations
then 	[[ -e ${1:?input PNG path required} ]] || exit
	if command -v magick >/dev/null 2>&1  #convert img to 'square png'
	then 	if [[ $1 != *.[Pp][Nn][Gg] ]] ||
			((! $(magick identify -format '%[fx:(h == w)]' "$1") ))
		then 	magick convert "${1}" -gravity Center -extent 1:1 "${FILEIN}" &&
			set  -- "${FILEIN}" "${@:2}"
		fi
		#https://legacy.imagemagick.org/Usage/resize/
	fi
	prompt_imgvarf "$1"
	prompt_imgprintf
elif ((OPTI))      #image generations
then 	BLOCK="{
		\"prompt\": \"${*:?IMG PROMPT ERR}\",
		\"size\": \"$OPTS\",
		\"n\": $OPTN,
		\"response_format\": \"$OPTI_FMT\"
	}"
	promptf
	prompt_imgprintf
elif ((OPTEMBED))  #embeds
then 	BLOCK="{
		\"model\": \"$MOD\",
		\"input\": \"${*:?INPUT ERR}\",
		\"temperature\": $OPTT,
		\"top_p\": $OPTP,
		\"max_tokens\": $OPTMAX,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
elif ((OPTE))      #edits
then 	BLOCK="{
		\"model\": \"$MOD\",
		\"instruction\": \"${1:?EDIT MODE ERR}\",
		\"input\": \"${@:2}\",
		\"temperature\": $OPTT,
		\"top_p\": $OPTP,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
else               #completions
	#if ((OPTC==1))
	#then 	printf '%s ' "[S]tart new session or [c]ontinue from last? " ;read -r
	#	case "$REPLY" in 	[Cc]*) 	OPTC=2;; 	[SsNn]*|*) 	break_sessionf;; esac ;fi
	((OPTC==1)) && break_sessionf
	if [[ $CHATINSTR ]]  #chatbot instructions
	then 	if ((!OPTC))
		then 	set -- "$CHATINSTR\\n\\n$*"
			OPTV=1 token_prevf "$*"
		elif ((OPTC<2))
		then 	printf '%s\t%d\t%s\n' \
			"$(date -Isec)" "1" \
			": $CHATINSTR" >> "$FILECHAT"
		fi
	fi
	while :
	do 	if ((OPTC))  #chat mode
		then 	if (($#))  #input from pos args, first pass
			then 	check_cmdf "$*" && continue
				set_typef "$*" && REC_OUT="$*" \
					|| REC_OUT="${USER_TYPE:-$Q_TYPE}: $*"
				set -- "$REC_OUT"
			fi

			#read hist file
			if [[ -s "$FILECHAT" ]]
			then 	((MAX_PREV=TKN_PREV+1)) ;unset HIST
				while IFS=$'\t' read -r time token string
				do 	[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
					[[ ${string//[$IFS\"]} ]] && ((token>0)) || continue
					if ((MAX_PREV+token+1<OPTMAX))
					then 	((MAX_PREV+=token+1))
						string="${string#[ :\"]}" string="${string%[ \"]}"
						HIST="${string#[ :]}\n\n$HIST"
					fi
				done < <(tac -- "$FILECHAT")
				((MAX_PREV-=TKN_PREV+1))
				unset REPLY time token string
			fi

			#text editor
			if ((OPTX))
			then 	edf "$@" || continue  #sig:200
				while :
				do 	new_prompt_confirmf
					case $? in
						201) 	break 2;;  #abort
						200) 	continue 2;;  #redo
						199) 	OPTC=-1 edf "$@" || break 2;;  #edit
						0) 	set -- "$(escapef "$(<"$FILETXT")")"
							break;;  #yes
						*) 	break;;  #no
					esac
				done
			fi

			#fallback prompt read
			if [[ ${*//[$IFS\"]} = *($TYPE_GLOB:) ]] \
				|| [[ ${REC_OUT//[$IFS\"]} = *($TYPE_GLOB:) ]]
			then 	while printf '\n%s[%s]: ' "Prompt" "${USER_TYPE:-$Q_TYPE}" >&2
				do 	if [[ $ZSH_VERSION ]]
					then 	printf '\n' >&2
						unset REPLY ;vared -h -c REPLY
						print -s "$REPLY"
					else 	read -r ${BASH_VERSION:+-e}
					fi
					if [[ $REPLY ]]
					then 	check_cmdf "$REPLY" && continue
						OPTX= new_prompt_confirmf
						case $? in
							201) 	break 2;;  #abort
							200|199) 	continue;;  #redo/edit
							0) 	:;;  #yes
							*) 	unset REPLY; set -- ;break;;  #no
						esac
						set_typef "$REPLY" && REC_OUT="$REPLY" \
							|| REC_OUT="${USER_TYPE:-$Q_TYPE}: $REPLY"
						set -- "$HIST$REC_OUT"
					else 	set --
					fi ;break
				done
			elif ((!OPTX))
			then 	set -- "$HIST${REC_OUT:-$*}"
			fi
		fi
		#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/

		BLOCK="{
			\"model\": \"$MOD\",
			\"prompt\": \"${*:?PROMPT ERR}\",
			\"temperature\": $OPTT,
			\"top_p\": $OPTP, $OPTA_OPT $OPTAA_OPT
			\"max_tokens\": $OPTMAX,
			\"n\": $OPTN
		}"
		promptf
		prompt_printf

		#record to hist file
		if [[ $OPTC ]] && {
		 	tkn=($(jq -r '.usage.prompt_tokens//empty,
				.usage.completion_tokens//empty,
				(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
			) )
			ans=$(jq '.choices[0].text' "$FILE")
			ans="${ans##*([$IFS]|\\[nt]|\")}" ans="${ans%\"}"
			((${#tkn[@]}>2)) && ((${#ans}))
			}
		then 	check_typef "$ans" || ans="$A_TYPE: $ans" OLD_TOTAL=$((OLD_TOTAL+1))
			REC_OUT="${REC_OUT%%*([$IFS:])}" REC_OUT="${REC_OUT##*([$IFS:])}"
			{	printf '%s\t%d\t"%s"\n' "${tkn[2]}" "$((tkn[0]-OLD_TOTAL))" "$(escapef "${REC_OUT:-$*}")"
				printf '%s\t%d\t"%s"\n' "${tkn[2]}" "${tkn[1]}" "$ans"
			} >> "$FILECHAT" ;OLD_TOTAL=$((tkn[0]+tkn[1]))
		fi; unset tkn ans

		set --  ;unset REPLY TKN_PREV MAX_PREV REC_OUT HIST PRE
		((OPTC)) || break
	done ;unset OLD_TOTAL
fi

