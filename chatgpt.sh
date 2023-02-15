#!/usr/bin/env ksh
# chatgpt.sh -- Ksh/Bash ChatGPT Shell Wrapper
# v0.2.15  2023  by mountaineerbr  GPL+3

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

	Make a good prompt. May use bullets for multiple questions in
	a single prompt. Write \`act as [technician]', add examples of
	expected results.

	To keep a history of the latest context in the chat, set option
	-c. This keeps a record of the latest prompts and replies and
	sends some history context with new questions. This option
	respects max tokens setting. Set -C to break from previous
	session.

	The chat format is \`Q: [prompt]' and \`A: [reply]', but a single
	letter such as \`I:' or simply \`:' may be set to mark the initial
	instruction prompt.


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

	CREATE IMAGE
	Creates an image given a prompt. A text description of the
	desired image(s). The maximum length is 1000 characters.

	IMAGE VARIATION
	Creates a variation of a given image. The image to use as
	the basis for the variation(s). Must be a valid PNG file,
	less than 4MB and square. If Imagemagick is available,
	input image will be converted to square before upload.


ENVIRONMENT
	CHATGPTRC 	Path to user ${0##*/} configuration.
			Defaults=${CHATGPTRC:-${FILECONF/$HOME/\~}}

	EDITOR
	VISUAL 		Text editor for external prompt editing.
			Defaults=vim
	
	OPENAI_KEY 	Set your personal (free) OpenAI API key.


REQUIREMENTS
	A free OpenAI GPTChat key. Ksh or Bash. cURL. JQ and
	ImageMagick are optionally required.


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
	White spaces or newlines at the end of PROMPT may return an
	empty response. Try removing/adding ending spaces or resetting
	temperature.


OPTIONS
	-NUM 		Set maximum tokens. Max=4096, defaults=$OPTMM.
	-a [VAL]	Set presence penalty  (completions; -2.0 - 2.0).
	-A [VAL]	Set frequency penalty (completions; -2.0 - 2.0).
	-c 		Set chat mode, read history file (completions).
	-C 		Set new session in history file.
	-e [INSTRUCT] [INPUT]
			Set Edit mode, defaults to text-davinci-edit-001.
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
	-vv 		Print request body, set twice to dump and exit.
	-xx 		Edit current prompt in text editor, set twice
			to edit previous prompt buffer.
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
	


function prompt_mainf
{
	curl -\# -L https://api.openai.com/v1/${ENDPOINTS[$EPN]} \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$BLOCK" \
		-o "$FILE"
}

function promptf
{
	if ((OPTV>1))
	then 	echo "$BLOCK" ;exit
	elif ((OPTV))
	then	jq -r '.instruction//empty, .input//empty, .prompt//empty' <<<"$BLOCK" || echo "$BLOCK"
	fi
	prompt_mainf "$@"
}

function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$FILE"
	else 	jq -r '"Model_: \(.model//"?") (\(.object//"?"))",
			"Usage_: \(.usage.prompt_tokens) + \(.usage.completion_tokens) = \(.usage.total_tokens//empty) tokens"' "$FILE" >&2
		jq -r '.choices[1] as $sep | .choices[] | (.text, if $sep != null then "---" else empty end)' "$FILE" \
		|| jq -r '.choices[].text' "$FILE" \
		|| cat -- "$FILE"
	fi
}

function prompt_imgvarf
{
	curl -\# -L https://api.openai.com/v1/${ENDPOINTS[$EPN]} \
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
			echo "File: ${fout/$HOME/\~}" >&2
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

function edf
{
	typeset REPLY
	
	((OPTX<2)) && (($#)) && unquotef "$@" >"$FILETXT"
	
	${VISUAL:-${EDITOR:-vim}} "$FILETXT" </dev/tty >/dev/tty
	
	echo "Confirm new prompt? [Y]es, [n]o or [a]bort" >&2
	read -n1 ;[[ $REPLY = [AaEeQq] ]] && exit ;[[ $REPLY = [!Nn] ]]
}

function quotef
{
 	set -- "${@//[\"]/\\\"}"          #double quote marks
	set -- "${@//[$'\t']/\\t}"        #tabs
	set -- "${@//[$'\n\r\v\f']/\\n}"  #new line/form feed
	echo "$@"
}

function unquotef
{
 	set -- "${@//\\\"/\"}"
	set -- "${@//\\t/$'\t'}"
	set -- "${@//\\n/$'\n'}"
	echo "$@"
}


#parse opts
while getopts a:A:cCehiIjlm:n:kp:t:vxz0123456789 c
do 	[[ $OPTARG = .[0-9]* ]] && OPTARG=0$OPTARG
	case $c in
		[0-9]) 	OPTMAX=$OPTMAX$c;;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		c) 	OPTC=1;;
		C) 	((OPTCC++)) || tee -a -- "${FILECHAT}" >&2 <<<'SESSION BREAK';;
		e) 	OPTE=1;;
		h) 	echo "$HELP" ;exit ;;
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
			then 	echo "err: illegal top_p -- $OPTARG" >&2
			else 	OPTP=$OPTARG
			fi;;
		t) 	if ((OPTARG>2))
			then 	echo "err: illegal temperature -- $OPTARG" >&2
			else 	OPTT=$OPTARG
			fi;;
		v) 	((++OPTV));;
		x) 	((++OPTX));;
		z) 	OPTZ=1;;
	esac
done ; unset c
shift $((OPTIND -1))

OPTMAX=${OPTMAX:-$OPTMM}
OPENAI_KEY="${OPENAI_KEY:-${OPENAI_API_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTC)) && ((OPTE+OPTI)) && OPTC=  ;((OPTL+OPTZ)) && OPTX= 
[[ ${OPTT#0} ]] && [[ ${OPTP#1} ]] && echo "warning: temperature and top_p both set" >&2
[[ $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA,"
[[ $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA,"
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

(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"
((OPTX)) && ((!OPTC)) && edf "$@" && set -- "$(<"$FILETXT")"  #editor
((OPTI+OPTII+OPTL+OPTZ)) || {
	TKN_PREV=$(($(wc -c <<<"$*")/4))
	echo "Prompt tokens: ~$TKN_PREV; Max tokens: $OPTMAX" >&2
}
for arg  #quote input
do 	((init++)) || set --
	set -- "$@" "$(quotef "$arg")"
done ;unset arg init

mkdir -p "$CACHEDIR" || exit
command -v jq >/dev/null 2>&1 || function jq { 	false ;}

if ((OPTZ))
then 	lastjsonf
elif ((OPTL))
then 	list_modelsf "$@"
elif ((OPTII))
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
elif ((OPTI))      #image
then 	BLOCK="{
		\"prompt\": \"${*:?IMG PROMPT ERR}\",
		\"size\": \"$OPTS\",
		\"n\": $OPTN,
		\"response_format\": \"$OPTI_FMT\"
	}"
	promptf
	prompt_imgprintf
elif ((OPTEMBED))  #embed
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
elif ((OPTE))      #edit
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
else               #completion
	if [[ $OPTC ]]  #chat
	then 	if [[ ${*# } = [A-Z]:* ]] || [[ ${*# } = :* ]]
		then 	ORIG_INPUT="$*" ORIG_INPUT="${ORIG_INPUT#[ :]}"
			ORIG_TYPE="$*" ORIG_TYPE="${ORIG_TYPE%%:*}"
			set -- "${ORIG_INPUT#[ :]}"
		else 	ORIG_INPUT="$*"
			set -- "Q: $*"
		fi
		if [[ -s "${FILECHAT}" ]]
		then 	((max_prev=TKN_PREV))
			while IFS=$'\t' read -r time token type string
			do 	[[ $time$token = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
				[[ $time ]] && ((token>0)) || continue
				if ((max_prev+token<OPTMAX))
				then 	((max_prev+=token)); ((max_hist+=token+1))
					string="${string#\"}" string="${string%\"}"
					string="${string/\\n\\n[A-Z]\:/ }"
					while [[ $string != "$buf" ]]
					do 	buf="$string"
						for glob in '\\n' '[A-Z]:' '[ "]'
						do 	string="${string#$glob}"
						done
					done ;unset buf glob
					set -- "$type: ${string# }\n\n$*"
				fi
			done < <(tac -- "${FILECHAT}")
			unset max_prev time token type string
		fi
		((OPTX)) && OPTX=1 edf "$@" && set -- "$(quotef "$(<"$FILETXT")")"
		[[ $* = Q:\  ]] && set --  #err on empty input
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

	if [[ $OPTC ]] && {
	 	tkn=($(jq -r '.usage.prompt_tokens//empty,
			.usage.completion_tokens//empty,
			(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
		))
		ans=$(jq '.choices[0].text' "$FILE") ans="${ans/\\n\\n[A-Z]\:/ }"
		((${#tkn[@]}==3)) && ((${#ans}))
		}
	then 	{ 	printf '%s\t%d\t%s\t%s\n' "${tkn[2]}" "$((tkn[0]-max_hist))" "${ORIG_TYPE-Q}" "\"${ORIG_INPUT:-$*}\""
			printf '%s\t%d\t%s\t%s\n' "${tkn[2]}" "${tkn[1]}" "A" "${ans# }"
		} >> "${FILECHAT}"
	fi; unset tkn ans
fi

