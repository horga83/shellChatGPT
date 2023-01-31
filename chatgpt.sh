#!/usr/bin/env ksh
# chatgpt.sh -- ChatGPT Shell Wrapper
# v0.1.17  2023  by mountaineerbr  GPL+3

#Set OpenAI key (may be set from enviroment)
#OPENAI_KEY=

#DEFAULTS
#Model
OPTM=0
#Temperature
OPTT=0
#Maximum tokens
OPTMM=1024
#Number of responses
OPTN=1
#Endpoint
EPN=0
#JSON backup from API
TMPFILE="${HOME}/Downloads/chatgpt.json"
#Image size
OPTS=512x512
#Image format
OPTI_FMT=b64_json  #url

HELP="NAME
	${0##*/} -- ChatGPT Shell Wrapper


SYNOPSIS
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [PROMPT]
	${0##*/} [-m [MODEL_NAME|NUMBER]] [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -e [opt] [INSTRUCTIONS] [INPUT]
	${0##*/} -i [opt] [256|512|1024] [PROMPT]
	${0##*/} -i [opt] [INPUT_PNG_PATH]
	${0##*/} -l [MODEL_NAME]

	A personal (free) OpenAI API is required, set it with -k or
	see ENVIRONMENT section.

	Local copy of the last	API response is stored at:
	\"$TMPFILE\".


COMPLETIONS
	Given a prompt, the model will return one or more predicted
	completions, and can also return the probabilities of
	alternative tokens at each position.

	Make a good prompt. May use bullets for multiple questions
	in a single prompt. Write \`act as [technician]', add
	examples of expected results.

	Lowering temperature means it will take fewer risks, and
	completions will be more accurate and deterministic.
	Increasing temperature will result in more diverse completions.
	
	Ex: low-temp:  We’re not asking the model to try to be
	creative with its responses – especially for yes or no
	questions.


EDITS
	Given instruction and prompt/input, the model will
	return an edited version of the prompt. This endpoint
	is set with models with \`edit' in their name.


IMAGES
	The first positional parameter sets the output image size
	256x256, 512x512 or 1024x1024. Defaults=$OPTS.

	CREATE IMAGE
	Creates an image given a prompt. A text description of the
	desired image(s). The maximum length is 1000 characters.

	IMAGE VARIATION
	Creates a variation of a given image. The image to use as
	the basis for the variation(s). Must be a valid PNG file,
	less than 4MB and square. If Imagemagick is available,
	input image will be converted to square before upload.


ENVIRONMENT
	OPENAI_KEY 	Set your personal (free) OpenAI API key.


REQUIREMENTS
	A free OpenAI GPTChat key.

	Ksh or bash. cURL.

	JQ and Imagemagick are optionally required.


LIMITS
	For most models this is 2048 tokens, or about 1500 words).
	Davici model limit is 4000 tokens.

	Free trial users
	Text & Embedding        Codex          Edit        Image
                  20 RPM       20 RPM        20 RPM
             150,000 TPM   40,000 TPM   150,000 TPM   50 img/min

	RPM 	(requests per minute)
	TPM 	(tokens per minute)


MODELS
	DAVINCI
	Good at: Complex intent, cause and effect, summarization
	for audience.
	
	CURIE
	Good at: Language translation, complex classification,
	text sentiment, summarization.
	
	BABBAGE
	Good at: Moderate classification, semantic search classification.
	Idea iteration, Sentence completion, Plot generation.
	
	ADA
	Good at: Parsing text, simple classification,
	address correction, keywords.
	Random data, Character descriptions.


OPTIONS
	-NUM 		Set maximum tokens. Defaults=$OPTMM.
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
			  #completions
			  0. 	text-davinci-003
			  1. 	text-curie-001
			  2. 	text-babbage-001
			  3. 	text-ada-001
			  #codex
			  4. 	code-davinci-002
			  5. 	code-cushman-001
			  #moderation
			  6. 	text-moderation-latest
			  7. 	text-moderation-stable
			  #edits
			  8. 	text-davinci-edit-001
			  9. 	code-davinci-edit-001
	-n [NUM] 	Set number of results. Defaults=$OPTN.
	-t [VAL] 	Set temperature value (0.0 - 2.0). Defaults=$OPTT.
	-z 		Print last call JSON file backup."

#API docs: <https://beta.openai.com/docs/guides>

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
	curl -\# -L https://api.openai.com/v1/${ENDPOINTS[$EPN]} \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-d "$BLOCK" \
		-o "$TMPFILE"
}

function prompt_printf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$TMPFILE"
	else 	jq -r '"Object: \(.object)",
			"Model: \(.model//empty)",
			"Usage: \(.usage.prompt_tokens)+\(.usage.completion_tokens)=\(.usage.total_tokens//empty) tokens",
			.choices[].text' "$TMPFILE" \
		|| cat -- "$TMPFILE"
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
		-o "$TMPFILE"
}

function prompt_imgprintf
{
	if ((OPTJ)) #print raw json
	then 	cat -- "$TMPFILE"
	elif [[ $OPTI_FMT = b64_json ]]
	then 	n=0
		while jq -e ".data[${n}]" "$TMPFILE" >/dev/null 2>&1
		do 	jq -r ".data[${n}].b64_json" "$TMPFILE" | base64 -d > "${TMPFILE%.json}${n}.png"
			echo "File: ${TMPFILE%.json}${n}.png" >&2
			((n++)) ;((n<50)) || break
		done
		((n)) || { 	cat -- "$TMPFILE" ;false ;}
	else 	jq -r '.data[].url' "$TMPFILE" || cat -- "$TMPFILE"
	fi
}

function list_modelsf
{
	curl https://api.openai.com/v1/models${1:+/}${1} \
		-H "Authorization: Bearer $OPENAI_KEY" \
		-o "$TMPFILE"
	if [[ $1 ]]
	then  	jq . "$TMPFILE" || cat -- "$TMPFILE"
	else 	jq -r '.data[].id' "$TMPFILE" | sort
	fi
}

function lastjsonf
{
	if [[ -e $TMPFILE ]]
	then 	jq . "$TMPFILE" || cat -- "$TMPFILE"
	fi
}


#parse opts
while getopts ehiIjlm:a:n:kt:z0123456789 c
do 	case $c in
		[0-9]) 	OPTMAX=$OPTMAX$c;;
		e) 	OPTE=1;;
		h) 	echo "$HELP" ;exit ;;
		i|I) 	OPTI=1;;
		j) 	OPTJ=1;;
		l) 	OPTL=1 ;;
		m|a) 	OPTMSET=1
			if [[ $OPTARG = *[a-zA-Z] ]]
			then 	MOD=$OPTARG  #set model name
			else 	OPTM=$OPTARG #set one pre defined model number
			fi;;
		n) 	OPTN=$OPTARG ;;
		k) 	OPENAI_KEY=$OPTARG;;
		t) 	OPTT=$OPTARG ;[[ $OPTT = .* ]] && OPTT=0$OPTT;;
		z) 	OPTZ=1;;
	esac
done ; unset c
shift $((OPTIND -1))

trk=sK-gDD7IQwrq1bxiyVVDL9XT3BlbKFJrVIFauUfJFU32bqzrWAB
OPENAI_KEY="${OPENAI_KEY:-${BEARER:-${OPENAI_API_KEY:-${GPTCHATKEY:-${trk//K/k}}}}}"
: ${OPENAI_KEY:?API key required}
command -v jq >/dev/null 2>&1 || function jq { 	false ;}
command -v base64 >/dev/null 2>&1 || OPTI_FMT=url
OPTMAX=${OPTMAX:-$OPTMM}
((OPTI+OPTII+OPTL+OPTZ)) || echo "Prompt: $(wc -w <<<"$*") words; Max tokens: $OPTMAX" >&2
set -- "${@//[\"]/\\\"}"            #quote double quote marks
set -- "${@//[$'\n\r\v\f']/\\n}"  #quote new line/formfeed characters
set -- "${@//[$'\t']/    }"         #tabs

if ((OPTI))
then 	case "${1}" in 	#set image size
		1024*) 	OPTS=1024x1024 ;shift;;
		512*) 	OPTS=512x512 ;shift;;
		256*) 	OPTS=256x256 ;shift;;
	esac ;MOD=image
	#set upload image instead
	[[ -e "$1" ]] && OPTII=1 MOD=image-var
fi
#set model
((OPTE)) && ((!OPTMSET)) && OPTM=8
MOD="${MOD:-${MODELS[$OPTM]}}"
#set model endpoint
case "$MOD" in
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

if ((OPTL))
then 	list_modelsf "$1"
elif ((OPTZ))
then 	lastjsonf
elif ((OPTII))
then 	[[ -e ${1:?input PNG path required} ]] || exit
	if command -v magick >/dev/null 2>&1  #convert img to 'square png'
	then 	if [[ $1 != *.[Pp][Nn][Gg] ]] ||
			((! $(magick identify -format '%[fx:(h == w)]' "$1") ))
		then 	magick convert "${1}" -gravity Center -extent 1:1 "${TMPFILE%.*}_in.png" &&
			set  -- "${TMPFILE%.*}_in.png"
		fi
	fi
	prompt_imgvarf "$1"
	prompt_imgprintf
elif ((OPTI))
then 	BLOCK="{
		\"prompt\": \"${*:?ERR}\",
		\"size\": \"$OPTS\",
		\"n\": $OPTN,
		\"response_format\": \"$OPTI_FMT\"
	}"
	promptf
	prompt_imgprintf
elif ((OPTEMBED))
then 	BLOCK="{
		\"model\": \"$MOD\",
		\"input\": \"${*:?ERR}\",
		\"temperature\": $OPTT,
		\"max_tokens\": $OPTMAX,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
elif ((OPTE))
then 	BLOCK="{
		\"model\": \"$MOD\",
		\"instruction\": \"$1\",
		\"input\": \"${2:?ERR}\",
		\"temperature\": $OPTT,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
else 	BLOCK="{
		\"model\": \"$MOD\",
		\"prompt\": \"${*:?ERR}\",
		\"temperature\": $OPTT,
		\"max_tokens\": $OPTMAX,
		\"n\": $OPTN
	}"
	promptf
	prompt_printf
fi

