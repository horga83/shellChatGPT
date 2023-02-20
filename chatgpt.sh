#!/usr/bin/env ksh
# chatgpt.sh -- Ksh93/Bash ChatGPT Shell Wrapper
# v0.4.1  2023  by mountaineerbr  GPL+3
[[ $BASH_VERSION ]] && shopt -s extglob
[[ $ZSH_VERSION  ]] && setopt NO_SH_GLOB KSH_GLOB KSH_ARRAYS SH_WORD_SPLIT GLOB_SUBST

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

# Cache files
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/chatgptsh"
FILE="${CACHEDIR}/chatgpt.json"
FILECHAT="${FILE%.*}.tsv"
FILECONF="${FILE%.*}.conf"
FILETXT="${FILE%.*}.txt"
FILEIN="${FILE%.*}_in.png"
FILEOUT="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}/chatgpt_out.png"

# Set user defaults
[[ -e ${CHATGPTRC:-$FILECONF} ]] && { 	. "${CHATGPTRC:-$FILECONF}" || exit ;}

HELP="NAME
	${0##*/} -- ChatGPT Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -e [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -i [opt] [256|512|1024|S|M|L] [PROMPT]
	${0##*/} -i [opt] [INPUT_PNG_PATH]
	${0##*/} -l [MODEL_NAME]

	A personal (free) OpenAI API is required, set it with -k or
	see ENVIRONMENT section.

	Local copy of the last	API response is stored at:
	${FILE/$HOME/\~}

	All positional arguments are read as a single PROMPT. If the
	chosen model require a INTRUCTION and INPUT prompts, first
	positional argument is taken as INSTRUCTIONS and the following
	ones as INPUT or PROMPT.

	Option -e sets the \`edits' endpoint. That endpoint requires
	both INSTRUCTIONS and INPUT prompts. This option requires
	setting an \`edits model'.

	Option -i generates images according to PROMPT. If first
	positional argument is a picture file, then generate variation
	of it.

	Stdin is supported when there is no positional arguments left
	after option parsing. Stdin input sets a single PROMPT.

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
	may be introduced as interlocutor. Setting \`:' will not add
	and interlocutor to the following text, this may be useful to
	set intructions, and completing a previous prompt.

	While in chat mode option -c, type in one of the following in
	the new prompt to set options on the go:

		-c  |  !new 	  Starts new session.
		-x  |  !editor 	  Set/unset text editor.
		-v  |  !verbose	  Set/unset verbose.
		-V  |  !block	  Print prompt.
		!q  |  !quit	  Exit.


	Prompt Design
	Make a good prompt. May use bullets for multiple questions in
	a single prompt. Write \`act as [technician]', add examples of
	expected results.

	For the chatbot, the only indication given is the initial \`Q:'
	interlocutor flag so the initial reply may vary considerably.
	You may try setting the bot identity and how it behaves as
	intructions at the first prompt, such as:

	prompt>	\": The following is a conversation with an AI assistant.
		   The assistant is helpful, creative, clever, and very
		   friendly.\"

	reply_> \"Assistant: Hello! How can I help you?\"

	prompt> \"Human: Hello, what is your name?\"


	For more on prompt design, see
	<https://platform.openai.com/docs/guides/completion/prompt-design>.


	Settings
	Temperature 	number 	Optional 	Defaults to $OPTT

	Lowering temperature means it will take fewer risks, and
	completions will be more accurate and deterministic. Increasing
	temperature will result in more diverse completions.
	Ex: low-temp:  We’re not asking the model to try to be creative
	with its responses – especially for yes or no questions.


	Top_p 	number 	Optional 	Defaults to $OPTP
	
	An alternative to sampling with temperature, called nucleus
	sampling, where the model considers the results of the tokens
	with top_p probability mass. So 0.1 means only the tokens
	comprising the top 10% probability mass are considered.
	They generally recommend altering this or temperature but both.

	
	Presence_penalty 	number 	Optional 	Defaults to 0
	Frequency_penalty 	number 	Optional 	Defaults to 0

	Number between -2.0 and 2.0. Positive values penalize new tokens
	based on whether they appear in the text so far.
	Presense penalty increases the model's likelihood to talk about
	new topics, while frequency penalty decreases the model's like-
	lihood to repeat the same line verbatim.


EDITS
	Given instruction and prompt/input, the model will return an
	edited version of the prompt. This endpoint is set with models
	with \`edit' in their name.


IMAGES
	The first positional parameter sets the output image size
	256x256/small, 512x512/medium or 1024x1024/large. Defaults=$OPTS.

	An image can be created given a prompt. A text description of
	the desired image(s). The maximum length is 1000 characters.

	Also, a variation of a given image can be generated. The image
	to use as the basis for the variation(s). Must be a valid PNG
	file, less than 4MB and square. If Imagemagick is available,
	input image will be converted to square before upload.


ENVIRONMENT
	CHATGPTRC 	Path to user ${0##*/} configuration.
			Defaults=${CHATGPTRC:-${FILECONF/$HOME/\~}}

	EDITOR
	VISUAL 		Text editor for external prompt editing.
			Defaults=vim
	
	OPENAI_KEY 	Set your personal (free) OpenAI API key.


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


REQUIREMENTS
	A free OpenAI GPTChat key. Ksh93 or Bash. cURL. JQ and
	ImageMagick are optionally required.


OPTIONS
	-NUM 		Set maximum tokens. Max=4096, defaults=$OPTMM.
	-a [VAL]	Set presence penalty  (completions; -2.0 - 2.0).
	-A [VAL]	Set frequency penalty (completions; -2.0 - 2.0).
	-cc 		Chat mode, new session (completions). Set twice
			to continue from last history session.
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
	read -r -n 1
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
	TKN_PREV=$(($(wc -c <<<"$*")/4))
	printf 'Prompt tokens: ~%d; Max tokens: %d\n' "$TKN_PREV" "$OPTMAX" >&2
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
		[+-][Cc]|!br|!break|!session)
			break_sessionf ;return 0
			;;
		-x|!ed|!editor)
			((OPTX)) && unset OPTX || OPTX=1 ;return 0
			;;
		-v|!ver|!verbose)
			((OPTV)) && unset OPTV || OPTV=1 ;return 0
			;;
		-V|!blk|!block)
			((OPTVV)) && unset OPTVV || OPTVV=1 ;return 0
			;;
		-VV|!!blk|!!block)
			OPTVV=2 ;return 0
			;;
		!q|!quit|!exit|!bye)
			exit
			;;
	esac
	return 1
}

function edf
{
	typeset ed_msg pre pos REPLY
	
	if ((OPTC))
	then 	ed_msg=",,,,,,(edit below this line),,,,,,"
		pre=$(unescapef "$HIST${HIST:+\\n$ed_msg}")
		printf "%s${pre:+\\n}" "$pre" >"$FILETXT"
		if (($#))
		then 	printf "${pre:+\\n}%s\n" "$*"
		else 	printf "${pre:+\\n}%s: \n" "${USER_TYPE:-Q}"
		fi >>"$FILETXT"
	fi
	
	${VISUAL:-${EDITOR:-vim}} "$FILETXT" </dev/tty >/dev/tty

	if ((OPTC)) && pos=$(<"$FILETXT") && [[ "$pos" != "$pre" ]]
	then 	if [[ "$pos" != "$pre"* ]]
		then
			printf 'Warning: %s \n' 'Bad edit. [R]edit, r[e]do or [c]ontinue?' >&2
			read -r
			case "$REPLY" in
				[CcNnQqAa]) 	:;;
				[Ee]*) return 200;;
				[Rr]|*) OPTC= edf "$@" || return ;pos=$(<"$FILETXT");;
			esac
			#case ${REPLY:-$1} in 	[!NnQq]*) return 200;; esac
		fi
		set -- "${pos#*"$pre"}"
		check_cmdf "$*" && return 200
		set_typef "$*" && REC_OUT="$*" || REC_OUT="${USER_TYPE:-Q}: $*"
	fi
	return 0
}

function escapef
{
 	set -- "${@//[\"]/\\\"}"          #double quote marks
	set -- "${@//[$'\t']/\\t}"        #tabs
	set -- "${@//[$'\n\r\v\f']/\\n}"  #new line/form feed
	printf '%s\n' "$@"
}

function unescapef
{
 	set -- "${@//\\\"/\"}"
	set -- "${@//\\t/$'\t'}"
	set -- "${@//\\n/$'\n'}"
	printf '%s\n' "$@"
}

function break_sessionf
{
	[[ -e "$FILECHAT" ]] || return
	[[ $(<"$FILECHAT") = *[Bb][Rr][Ee][Aa][Kk] ]] ||
	tee -a -- "$FILECHAT" >&2 <<<'SESSION BREAK'
}


#parse opts
while getopts a:A:cehiIjlm:n:kp:t:vxz0123456789 c
do 	[[ $OPTARG = .[0-9]* ]] && OPTARG=0$OPTARG
	case $c in
		[0-9]) 	OPTMAX=$OPTMAX$c;;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		c) 	((OPTC++));;
		e) 	OPTE=1;;
		h) 	printf '%s\n' "$HELP" ;exit ;;
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
		V) 	((++OPTVV));;
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
then 	: "${2:?EDIT MODE ERR}"
	BLOCK="{
		\"model\": \"$MOD\",
		\"instruction\": \"$1\",
		\"input\": \"${@:2}\",
		\"temperature\": $OPTT,
		\"top_p\": $OPTP,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
else               #completions
	((!OPTC)) || ((OPTC>1)) || break_sessionf
	while :
	do 	if [[ $OPTC ]]  #chat mode
		then 	if (($#))  #input from pos args, first pass
			then 	check_cmdf "$*" && continue
				set_typef "$*" && REC_OUT="$*" \
					|| REC_OUT="${USER_TYPE:-Q}: $*"
				set -- "$REC_OUT"
			fi

			#read hist file
			if [[ -s "${FILECHAT}" ]]
			then 	((max_prev=TKN_PREV+1))
				while IFS=$'\t' read -r time token string
				do 	[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
					[[ ${string//[$IFS\"]} ]] && ((token>0)) || continue
					if ((max_prev+token+1<OPTMAX))
					then 	((max_prev+=token+1))
						string="${string#[ \"]}" string="${string%[ \"]}"
						HIST="${string#[ :]}\n\n$HIST"
					fi
				done < <(tac -- "$FILECHAT")
				((max_prev-=TKN_PREV+1))
				unset REPLY time token string
			fi

			#text editor
			if ((OPTX))
			then 	edf "$@"
				while :
				do 	new_prompt_confirmf
					case $? in
						201) 	break 2;;  #abort
						200) 	continue 2;;  #redo
						199) 	OPTC= edf "$@" || break 2;;  #edit
						0) 	set -- "$(escapef "$(<"$FILETXT")")"
							break;;  #yes
						*) 	break;;  #no
					esac
				done
			fi

			#fallback prompt read
			if [[ ${*//[$IFS\"]} = *($TYPE_GLOB:) ]] \
				|| [[ ${REC_OUT//[$IFS\"]} = *($TYPE_GLOB:) ]]
			then 	while :
				do 	printf '\n%s[%s]: ' "Prompt" "${USER_TYPE:-Q}" >&2
					read -r ${BASH_VERSION:+-e}
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
							|| REC_OUT="${USER_TYPE:-Q}: $REPLY"
						set -- "$HIST$REC_OUT"
					else 	set --
					fi ;break
				done
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
		then 	check_typef "$ans" || ans="A: $ans"
			REC_OUT="${REC_OUT%%*([$IFS:])}" REC_OUT="${REC_OUT##*([$IFS:])}"
			{	printf '%s\t%d\t"%s"\n' "${tkn[2]}" "$((max_prev<=tkn[0]?tkn[0]-max_prev:-1))" "$(escapef "${REC_OUT:-$*}")"
				printf '%s\t%d\t"%s"\n' "${tkn[2]}" "${tkn[1]}" "$ans"
			} >> "$FILECHAT"
		fi; unset tkn ans

		set --  ;unset REPLY TKN_PREV REC_OUT HIST
		((OPTC)) || break
	done
fi

