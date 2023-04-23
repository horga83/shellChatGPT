#!/usr/bin/env bash
# chatgpt.sh -- ChatGPT/DALL-E/Whisper Shell Wrapper
# v0.12  april/2023  by mountaineerbr  GPL+3
shopt -s extglob
set -o pipefail

# OpenAI API key
#OPENAI_API_KEY=

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
# Maximum response tokens
OPTMAX=256
# Model capacity (auto)
#MODMAX=
# Presence penalty
#OPTA=
# Frequency penalty
#OPTAA=
# N responses of Best_of
#OPTB=
# Number of responses
OPTN=1
# Image size
OPTS=512x512
# Image format
OPTI_FMT=b64_json  #url
# Recorder command
#REC_CMD=
# Inject restart text
#RESTART=
# Inject   start text
#START=
# Text cmpls chat use "\\nQ: " and "\\nA:"
# Restart/Start seqs have priority

# INSTRUCTION
# Text and chat completions, and edits endpoints
#INSTRUCTION="The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly."

# CACHE AND OUTPUT DIRECTORIES
CONFFILE="$HOME/.chatgpt.conf"
CACHEDIR="${XDG_CACHE_HOME:-$HOME/.cache}/chatgptsh"
OUTDIR="${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"

# Load user defaults
((OPTF)) || { 	[[ -f "${CHATGPTRC:-$CONFFILE}" ]] && . "${CHATGPTRC:-$CONFFILE}" ;}

# Set file paths
FILE="${CACHEDIR%/}/chatgpt.json"
FILECHAT="${CACHEDIR%/}/chatgpt.tsv"
FILETXT="${CACHEDIR%/}/chatgpt.txt"
FILEOUT="${OUTDIR%/}/dalle_out.png"
FILEIN="${CACHEDIR%/}/dalle_in.png"
FILEINW="${CACHEDIR%/}/whisper_in.mp3"
FILEAWE="${CACHEDIR%/}/awesome-prompts.csv"
USRLOG="${OUTDIR%/}/${FILETXT##*/}"
HISTFILE="${CACHEDIR%/}/history_bash"
HISTCONTROL=erasedups:ignoredups
HISTSIZE=512

# Def hist, txt chat types
Q_TYPE="\\nQ: "
A_TYPE="\\nA:"

# Base API URL
APIURL="https://api.openai.com/v1"

# Globs
SPC="*([$IFS])"
SPC0="*(\\\\[ntrvf])?(\ )"
SPC1="*(\\\\[ntrvf]|[$IFS])"

HELP="Name
	${0##*/} -- ChatGPT / DALL-E / Whisper  Shell Wrapper


Synopsis
	${0##*/} [-m [MODEL_NAME|MODEL_INDEX]] [opt] [PROMPT|TXT_FILE]
	${0##*/} [-m [MODEL_NAME|MODEL_INDEX]] [opt] [INSTRUCTION] [INPUT]
	${0##*/} -e [opt] [INSTRUCTION] [INPUT]
	${0##*/} -i [opt] [S|M|L] [PROMPT]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE]
	${0##*/} -i [opt] [S|M|L] [PNG_FILE] [MASK_FILE] [PROPMT]
	${0##*/} -w [opt] [AUDIO_FILE] [LANG] [PROMPT-LANG]
	${0##*/} -W [opt] [AUDIO_FILE] [PROMPT-EN]
	${0##*/} -ccw [opt] [LANG]
	${0##*/} -ccW [opt]
	${0##*/} -l [MODEL_NAME]


Description
	Complete INPUT text when run without any options (single-turn). 
	
	Positional arguments are read as a single PROMPT. When INSTRUCTION
	is mandatory (such as for edits models), the first positional
	argument is taken as INSTRUCTION and the following ones as INPUT
	or PROMPT.

	Set option -c to start the chat mode via text completions or -cc
	for native chat completions. Combined with option -C, resumes from
	last history session.

	Option -CC (without -cc) starts a pure text completions session,
	and use restart and start sequences, if defined.

	Option -i generates or edits images. Option -w transcribes audio
	and option -W tarnslates audio to English.

	A personal (free) OpenAI API is required, set it with -K. Also
	see ENVIRONMENT section in man page.


See Also
	Check the man page for extended description of interface and
	settings. It is also available online at:

	<https://github.com/mountaineerbr/shellChatGPT#help-page>.


Chat Commands
	While in chat mode, the following commands can be typed in the
	new prompt to set a new parameter. The command operator may be
	either \`!', or \`/'.

	  ------    ----------    ---------------------------------------
	   !NUM      !max          Set response tokens / model capacity.
	     -a      !pre          Set presence pensalty.
	     -A      !freq         Set frequency penalty.
	     -c      !new          Start new session.
	     -H      !hist         Edit history in editor.
	     -L      !log          Save to log file.
	     -m      !mod          Set model (by index or name).
	     -o      !clip         Copy responses to clipboard.
	     -p      !top          Set top_p.
	     -r      !restart      Set restart sequence.
	     -R      !start        Set start sequence.
	     -s      !stop         Set stop sequences.
	     -t      !temp         Set temperature.
	     -u      !multi        Toggle multiline prompter.
	     -v      !ver          Toggle verbose.
	     -x      !ed           Toggle text editor interface.
	     -w      !rec          Start audio record chat.
	     !r      !regen        Renegerate last response.
	     !q      !quit         Exit.
	  ------    ----------    ---------------------------------------
	
	E.g.: \`!temp 0.7', \`!mod1', and \`-p 0.2'.

	Change chat context at run time with the \`!hist' command to edit
	the history file (delete or comment out entries).

	To preview a prompt completion, append a forward slash \`/' to it
	and press ENTER. Regenerate it again or press ENTER to accept it.

	After a response has been written to the history file, regenerate
	it with command \`!regen' or type in a single forward slash in
	the new empty prompt.

	To enable multiline input, type in a backslash \`\\' as the last
	character of the input line and press ENTER, or set option -u.
	Once enabled, press ENTER twice to confirm the prompt.


Long Options
	The following options can be set with an argument, or multiple
	times when appropriate.

	--alpha, --api-key, --best, --best-of, --chat, --clipboard,
	--clip, --cont, --continue, --edit, --editor, --frequency,
	--frequency-penalty, --help, --hist, --image, --instruction,
	--last, --list-model, --list-models, --log, --log-prob, --max,
	--max-tokens, --mod, --model, --no-colour, --no-config,
	--presence, --presence-penalty, --prob, --raw, --restart-seq,
	--restart-sequence, --results, --resume, --start-seq,
	--start-sequence, --stop, --temp, --temperature, --top, --top-p,
	--transcribe, --translate, --multi, --multiline, and --verbose.

	E.g.: \`--chat', \`--temp=0.9', \`--max=1024,128', and \`--presence-penalty 0.6'.


Options
	-@ [[VAL%]COLOUR]
		 Set transparent colour of image mask. Def=black.
		 Fuzz intensity can be set with [VAL%]. Def=0%.
	-NUM
	-M [NUM[-NUM]]
		 Set maximum number of \`response tokens'. Def=$OPTMAX.
		 \`Model capacity' can be set with a second number.
	-a [VAL] Set presence penalty  (cmpls/chat, -2.0 - 2.0).
	-A [VAL] Set frequency penalty (cmpls/chat, -2.0 - 2.0).
	-b [VAL] Set best of, must be greater than opt -n (cmpls). Def=1.
	-B 	 Print log probabilities to stderr (cmpls, 0 - 5).
	-c 	 Chat mode in text completions, new session.
	-cc 	 Chat mode in chat completions, new session.
	-C 	 Continue from last session (compls/chat).
	-CC 	 Start new session of pure text compls (without -cc).
	-e [INSTRUCTION] [INPUT]
		 Set Edit mode. Model def=text-davinci-edit-001.
	-f 	 Ignore user config file and environment.
	-h 	 Print this help page.
	-H 	 Edit history file with text editor or pipe to stdout.
	-HH 	 Pretty print last history session to stdout.
      		 With -C and -rR, prints the specified seqs.
	-i [PROMPT]
		 Generate images given a prompt.
	-i [PNG]
		 Create variations of a given image.
	-i [PNG] [MASK] [PROMPT]
		 Edit image with mask and prompt (required).
	-j 	 Print raw JSON response (debug with -jVV).
	-k 	 Disable colour output. Def=auto.
	-K [KEY] Set API key (free).
	-l [MOD] List models or print details of MODEL. Set twice
		 to print model indexes instead.
	-L [FILEPATH]
		 Set log file. FILEPATH is required.
	-m [MOD] Set model by NAME.
	-m [IND] Set model by INDEX:
		# COMPLETIONS             # EDITS
		0.  text-davinci-003      8.  text-davinci-edit-001
		1.  text-curie-001        9.  code-davinci-edit-001
		2.  text-babbage-001      # AUDIO
		3.  text-ada-001          11. whisper-1
		# CHAT                    # GPT-4 
		4. gpt-3.5-turbo          12. gpt-4
		# MODERATION              13. gpt-4-32k
		6.  text-moderation-latest
		7.  text-moderation-stable
	-n [NUM] Set number of results. Def=$OPTN.
	-o 	 Copy response to clipboard.
	-p [VAL] Set Top_p value, nucleus sampling (cmpls/chat, 0.0 - 1.0).
	-r [SEQ] Set restart sequence string (cmpls).
	-R [SEQ] Set start sequence string (cmpls).
	-s [SEQ] Set stop sequences, up to 4. Def=\"<|endoftext|>\".
	-S [INSTRUCTION|FILE]
		 Set an instruction prompt. It may be a text file.
	-S /[PROMPT_NAME]
		 Set/search prompt from awesome-chatgpt-prompts.
	-t [VAL] Set temperature value (cmpls/chat/edits/audio),
		 (0.0 - 2.0, whisper 0.0 - 1.0). Def=${OPTT:-0}.
	-u 	 Set multiline prompter.
	-v 	 Less verbose. May set multiple times.
	-V 	 Pretty-print request. Set twice to dump raw request.
	-x 	 Edit prompt in text editor.
	-w [AUD] [LANG]
		 Transcribe audio file into text. LANG is optional.
		 Set twice to get phrase-level timestamps. 
	-W [AUD] Translate audio file into English text.
		 Set twice to get phrase-level timestamps. 
	-z 	 Print last response JSON data."

MODELS=(
	#COMPLETIONS
	text-davinci-003          #  0
	text-curie-001            #  1
	text-babbage-001          #  2
	text-ada-001              #  3
	#CHAT                     #
	gpt-3.5-turbo             #  4
	gpt-3.5-turbo-0301        # -5
	#MODERATIONS              #
	text-moderation-latest    #  6
	text-moderation-stable    #  7
	#EDITS                    #
	text-davinci-edit-001     #  8
	code-davinci-edit-001     #  9
	#AUDIO                    #
	whisper-1                 #-10
	whisper-1                 # 11
	#GPT4                     #
	gpt-4                     # 12
	gpt-4-32k   #June 14      # 13
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
	#fine-tunes                #10
)


#set model endpoint based on its name
function set_model_epnf
{
	unset OPTE OPTEMBED
	case "$1" in
		*whisper*) 		((OPTWW)) && EPN=8 || EPN=7;;
		gpt-4*|*turbo*) 		EPN=6 ;((OPTC)) && OPTC=2 ;unset OPTB OPTBB;;
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

#make cmpls request
function promptf
{
	typeset silence
	((OPTV>2)) && silence=1

	json_minif
	if ((OPTVV)) && ((!OPTII))
	then 	block_printf || { 	printf '\n' >&2 ;return 1 ;}
	fi
	
	curl -\# ${silence:+-s} -L "$APIURL/${ENDPOINTS[EPN]}" \
		-H "Content-Type: application/json" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-d "$BLOCK" \
		-o "$FILE" \
	&& { 	((silence)) || __clr_lineupf ;}
}
function __clr_lineupf { 	printf '\e[A\e[K' >&2 ;} 

#pretty print request body or dump and exit
function block_printf
{
	if ((OPTVV>1))
	then 	printf '%s\n%s\n' "${ENDPOINTS[EPN]}" "$BLOCK"
		printf '%s ' '<CTRL-D> redo, <CTR-C> exit, or continue' >&2
		typeset REPLY ;read
	else	jq -r '.instruction//empty,
		.input//empty,
		.prompt//(.messages[]|.role+": "+.content)//empty' <<<"$BLOCK" \
		|| printf '%s\n' "$BLOCK"
	fi >&2
}

#prompt confirmation prompter
function new_prompt_confirmf
{
	typeset REPLY

	OPTV=  __sysmsgf 'Confirm prompt?' '[Y]es, [n]o, [e]dit, [r]edo or [a]bort ' ''
	REPLY=$(__read_charf) ;__clr_lineupf
	case "${REPLY}" in
		[AaQq]|$'\e') 	return 201;;  #break
		[Rr]) 	return 200;;  #continue
		[EeVv]) 	return 199;;  #edit
		[Nn]) 	unset REC_OUT ;return 1;;  #no
	esac  #yes
}

#read one char from user
function __read_charf
{
	typeset REPLY
	read -n 1 "$@"
	printf '%.1s\n' "$REPLY"
	[[ -z ${REPLY//[$IFS]} ]] || printf '\n' >&2
}

#print response
function prompt_printf
{
	if ((OPTJ)) #raw json
	then 	cat -- "$FILE"
	else 	((OPTV)) || jq -r '(.choices[].logprobs//empty),
			(.model//"'"$MOD"'"//"?")+" ("+(.object//"?")+") ["
			+(.usage.prompt_tokens//"?"|tostring)+" + "+(.usage.completion_tokens//"?"|tostring)+" = "
			+(.usage.total_tokens//"?"|tostring)+" tkns]"' "$FILE" >&2

		jq -r "def byellow: \"\"; def reset: \"\"; $JQCOL $JQCOL2
		  .choices[1] as \$sep | .choices[] |
		  (byellow + (
		  (.text//.message.content) | gsub(\"^[\\\\n\\\\t ]\"; \"\") |
		  if ${OPTC:-0} > 0 then gsub(\"[\\\\n\\\\t ]+$\"; \"\") else . end
		  ) + reset,
		  if \$sep != null then \"---\" else empty end)" "$FILE" 2>/dev/null | foldf ||

		jq -r '.choices[]|.text//.message.content' "$FILE" 2>/dev/null ||
		jq . "$FILE" 2>/dev/null || cat -- "$FILE"
	fi
}
#https://stackoverflow.com/questions/57298373/print-colored-raw-output-with-jq-on-terminal
#https://stackoverflow.com/questions/40321035/  #gsub(\"^[\\n\\t]\"; \"\")

#make request to image endpoint
function prompt_imgvarf
{
	curl -\# ${OPTV:+-s} -L "$APIURL/${ENDPOINTS[EPN]}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
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
	else 	false
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
	((OPTVV)) && echo "model=$MOD  temp=$OPTT  $*" >&2

	curl -\# ${OPTV:+-s} -L "$APIURL/${ENDPOINTS[EPN]}" \
		-X POST \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
		-H 'Content-Type: multipart/form-data' \
		-F file="@$1" \
		-F model="$MOD" \
		-F temperature="$OPTT" \
		-o "$FILE" \
		"${@:2}"
}

function list_modelsf
{
	if ((OPTL>1))
	then 	__sysmsgf "Index  Model"
		for ((i=0;i<${#MODELS[@]};i++))
		do 	printf '%2d  %s\n' "$i" "${MODELS[i]}"
		done
		return
	fi
	
	curl "$APIURL/models${1:+/}${1}" \
		-H "Authorization: Bearer $OPENAI_API_KEY" \
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
	TKN_PREV=$(__tiktokenf "$@")
	__sysmsgf "Prompt:" "~$TKN_PREV tokens"
}

#set up context from history file ($HIST and $HIST_C)
function set_histf
{
	typeset time token string max_prev q_type a_type role rest
	[[ -s "$FILECHAT" ]] || return
	unset HIST HIST_C
	(($#)) && OPTV=1 token_prevf "$*"
	q_type="${Q_TYPE##$SPC0}" a_type="${A_TYPE##$SPC0}"
	
	while IFS=$'\t' read -r time token string
	do 	[[ ${time//[$IFS]}${token//[$IFS]} = \#* ]] && continue
		[[ -z $time$token$string ]] && continue
		[[ ${time}${token} = *[Bb][Rr][Ee][Aa][Kk]* ]] && break
		if ((token<1))
		then 	((OPTVV>1||OPTJ)) &&
			__warmsgf "Warning:" "Zero/Neg token in history"
			token=$(__tiktokenf "${string}")
		fi

		if ((max_prev+token+TKN_PREV+( (max_prev*4)/100) < MODMAX-OPTMAX)) #4% for tkn count errs
		then 	((max_prev+=token))
			((N_LOOP)) || ((OLD_TOTAL+=token))
			H_TIME="${time}" MAX_PREV="${max_prev}"
			string="${string##[\"]}" string="${string%%[\"]}" string="${string##$SPC0}"
			stringc="${string##@("${q_type:-%#}"|"${a_type:-%#}"|":")}"

			unset role rest
			case "${string}" in
				:*) 	role=system
					rest=
					;;
				"${a_type:-%#}"*|"${START:-%#}"*)
					role=assistant
					if ((OPTC)) || [[ -n "${START}" ]]
					then 	rest="${START:-$A_TYPE}"
					fi
					;;
				*) #q_type, RESTART
					role=user
					if ((OPTC)) || [[ -n "${RESTART}" ]]
					then 	rest="${RESTART:-$Q_TYPE}"
					fi
					;;
			esac

			HIST="${rest}${stringc}${HIST}"
			((EPN==6)) && HIST_C="$(fmt_ccf "${stringc##$SPC0}" "${role}")${HIST_C:+,}${HIST_C}"
		else 	break
		fi
	done < <(tac -- "$FILECHAT")
	if [[ "$role" = system ]]  #1st sys/instruction msg extra newline 
	then 	HIST="${HIST##"$stringc"}" HIST="${HIST##\\n}" HIST="${stringc}\\n\\n${HIST}"
	fi ;HIST="${HIST##$SPC0}"
}
#https://thoughtblogger.com/continuing-a-conversation-with-a-chatbot-using-gpt/

#print to history file
#usage: push_tohistf [string] [tokens] [time]
function push_tohistf
{
	typeset string tkn_min tkn
	[[ -n $1 ]] || return
	string="$1" ;tkn_min=$(__tiktokenf "$string" "4")
	((tkn = ${2:-tkn_min}>0 ? ${2:-tkn_min} : tkn_min ))
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

	printf '%d\n' "${tkn:-0}" ;((tkn>0))
}

#set output image size
function set_sizef
{
	case "$1" in
		1024*|[Ll][Aa][Rr][Gg][Ee]|[Ll]) 	OPTS=1024x1024;;
		512*|[Mm][Ee][Dd][Ii][Uu][Mm]|[Mm]) 	OPTS=512x512;;
		256*|[Ss][Mm][Aa][Ll][Ll]|[Ss]) 	OPTS=256x256;;
		*) 	return 1;;
	esac ;return 0
}

function set_maxtknf
{
	typeset buff
	set -- "${*:-$OPTMAX}"
	set -- "${*##[+-]}" ;set -- "${*%%[+-]}"

	if [[ $* = *[0-9][!0-9][0-9]* ]]
	then 	OPTMAX="${*##${*%[!0-9]*}}" MODMAX="${*%%"$OPTMAX"}"
		OPTMAX="${OPTMAX##[!0-9]}"
	elif [[ -n ${*//[!0-9]} ]]
	then 	OPTMAX="${*//[!0-9]}"
	fi
	if ((OPTMAX>MODMAX))
	then 	buff="$MODMAX" MODMAX="$OPTMAX" OPTMAX="$buff" 
	fi
}

#check input and run a chat command
function check_cmdf
{
	typeset var
	[[ ${*//[$IFS:]} = [/!-]* ]] || return $?
	set -- "${*##*([$IFS:\/!])}"
	case "$*" in
		-[0-9]*|[0-9]*|max*)
			set -- "${*%.*}" ;OPTMM="${*:-$OPTMM}"
			set_maxtknf $OPTMM
			__cmdmsgf 'Max model / response' "$MODMAX / $OPTMAX tkns"
			;;
		-a*|presence*|pre*)
			set -- "${*//[!0-9.]}"
			OPTA="${*:-$OPTA}"
			fix_dotf OPTA
			__cmdmsgf 'Presence penalty' "$OPTA"
			;;
		-A*|frequency*|freq*)
			set -- "${*//[!0-9.]}"
			OPTAA="${*:-$OPTAA}"
			fix_dotf OPTAA
			__cmdmsgf 'Frequency penalty' "$OPTAA"
			;;
		-[Cc]|br|break|session)
			break_sessionf
			;;
		-[Hh]|history|hist)
			__edf "$FILECHAT"
			;;
		-L*|log*)
			((++OPTLOG)) ;((OPTLOG%=2))
			((OPTLOG)) || set --
			set -- "${*##@(-L|log)$SPC}"
			USRLOG="${*:-${USRLOG:-$HOME/chatgpt.log}}"
			__cmdmsgf $'\nLog file' "\`\`$USRLOG''"
			;;
		-m*|model*|mod*)
			set -- "${*##@(-m|model|mod)}"
			if [[ $* = *[a-zA-Z]* ]]
			then 	MOD="${*//[$IFS]}"  #by name
			else 	MOD="${MODELS[${*//[!0-9]}]}" #by index
			fi
			set_model_epnf "$MOD" ;__cmdmsgf 'Model' "$MOD"
			((EPN==6)) && OPTC=2 || OPTC=1
			;;
		-p*|top*)
			set -- "${*//[!0-9.]}"
			OPTP="${*:-$OPTP}"
			fix_dotf OPTP
			__cmdmsgf 'Top P' "$OPTP"
			;;
		-r*|restart*)
			((EPN==6)) || {
				set -- "${*##@(-r|restart)$SPC}"
				RESTART="$*"
				__cmdmsgf 'Restart Sequence' "$RESTART"
			}
			;;
		-R*|start*)
			((EPN==6)) || {
				set -- "${*##@(-R|start)$SPC}"
				START="$*"
				__cmdmsgf 'Start Sequence' "$START"
			}
			;;
		-s*|stop*)
			set -- "${*##@(-s|stop)$SPC}"
			STOPS=("${*}" "${STOPS[@]}")
			__cmdmsgf 'Stop Sequences' "${STOPS[*]}"
			;;
		-t*|temperature*|temp*)
			set -- "${*//[!0-9.]}"
			OPTT="${*:-$OPTT}"
			fix_dotf OPTT
			__cmdmsgf 'Temperature' "$OPTT"
			;;
		-o|clipboard|clip)
			((++OPTCLIP)) ;((OPTCLIP%=2))
			set_clipcmdf
			__cmdmsgf 'Clipboard' $( ((OPTCLIP)) && echo ON || echo OFF)
			;;
		-u|multiline|multi)
			((++OPTMULTI)) ;((OPTMULTI%=2))
			__cmdmsgf 'Multiline' $( ((OPTMULTI)) && echo ON || echo OFF)
			;;
		-v|verbose|ver)
			((++OPTV)) ;((OPTV%=4))
			case "$OPTV" in
				1) var='Less';;
				2) var='Much less';;
				3) var='OFF';;
				0) var='ON';;
			esac
			OPTV=  __cmdmsgf 'Verbose' "$var"
			;;
		-V|block|blk)
			((OPTVV==1)) && unset OPTVV || OPTVV=1
			;;
		-VV)  #debug
			((OPTVV==2)) && unset OPTVV || OPTVV=2
			;;
		-x|editor|ed|vim|vi)
			((++OPTX)) ;((OPTX%=2))
			;;
		-[wW]*|audio*|rec*)
			OPTW=1 ;[[ $* = -W* ]] && OPTW=2
			set -- "${*##@(-[wW][wW]|-[wW]|audio|rec)$SPC}"

			var="${*##*([$IFS])}"
			[[ $var = [a-z][a-z][$IFS]*[[:graph:]]* ]] \
			&& set -- "${var:0:2}" "${var:3}" ;unset var

			INPUT_ORIG=("${@:-${INPUT_ORIG[@]}}")
			;;
		q|quit|exit|bye)
			exit
			;;
		r|regenerate|regen|[$IFS]|'')  #regenerate last response
			REGEN=1 SKIP=1 EDIT=1
			if ((!BAD_RESPONSE)) && [[ -f "$FILECHAT" ]] &&
			[[ "$(tail -n 2 "$FILECHAT")"$'\n' != *[Bb][Rr][Ee][Aa][Kk]$'\n'* ]]
			then 	sed -i -e '$d' -- "$FILECHAT"
				sed -i -e '$d' -- "$FILECHAT"
			fi
			;;
		*) 	return 1
			;;
	esac ;return 0
}

#print msg to stderr
#usage: __sysmsgf [string_one] [string_two] ['']
function __sysmsgf
{
	((!OPTV)) || return
	col1="${col1:-${BWhite}}" col2="${col2}"
	printf "${col1}%s${NC}${2:+ }${col2}%s${NC}${3-\\n}" "$1" "$2" >&2
	unset col1 col2
}

function __warmsgf
{
	OPTV=  col1="${Red}" __sysmsgf "$*"
}

#command run feedback
function __cmdmsgf
{
	typeset c
	for ((c=${#1};c<13;c++))
	do 	set -- "$1 " "${@:2}"
	done
	col1="${White}" __sysmsgf "$1 => ${2:-unset}"
}

#main plain text editor
function __edf
{
	${VISUAL:-${EDITOR:-vim}} "$1" </dev/tty >/dev/tty
}

#text editor wrapper
function edf
{
	typeset ed_msg pre rest pos REPLY
	((OPTCMPL))|| ed_msg=$'\n\n'",,,,,,(edit below this line),,,,,,"
	((OPTC)) && rest="${RESTART:-$Q_TYPE}" || rest="${RESTART}"
	rest="$(unescapef "$rest")"

	if ((OPTC+OPTRESUME))
	then 	N_LOOP=1 set_histf "${rest}${*}"
		HIST="${HIST//\\n\\n/\\n}" HIST="${HIST//\\n\\n/\\n}"
		HIST="${HIST//\\n/\\n\\n}"
	fi

	pre="$(unescapef "${INSTRUCTION}")"${INSTRUCTION:+$'\n\n'}"$(unescapef "$HIST")""${ed_msg}"
	printf "%s\\n" "${pre}"$'\n\n'"${rest}${*}" > "$FILETXT"

	__edf "$FILETXT"

	pos="$(<"$FILETXT")"
	
	while [[ "$pos" != "${pre:-%#}"* ]] || [[ "$pos" = *"${rest:-%#}" ]]
	do 	__warmsgf "Warning:" "Bad edit: [E]dit, [r]edo, [c]ontinue or [a]bort? " ''
		REPLY=$(__read_charf)
		case "$REPLY" in
			[AaQq]|$'\e') return 201;; #abort	
			[CcNn]) break;;            #continue
			[Rr]*)  return 200;;       #redo
			[Ee]|*) __edf "$FILETXT"   #edit
				pos=$(<"$FILETXT");;
		esac
	done
	
	if ((OPTCMPL))
	then 	set -- "${pos##*"${pre}"?($SPC"${rest}")}"
	else 	set -- "${pos##*"${pre}"$SPC?("${rest}")$SPC}"
	fi
	printf "%s\\n" "$*" > "$FILETXT"

	if ((OPTC+OPTRESUME))
	then 	check_cmdf "${*#*:}" && return 200
	fi ;return 0
}

#special json chars
JSON_CHARS=(\" / b f n r t u)  #\\ uHEX
#unescape / escape text to json format
function unescapef { 	printf "${*//\%/%%}" ;}
function escapef
{
	typeset var b c
	var="$*" b='@#'

	#special chars
 	for c in "${JSON_CHARS[@]}" " "
	do 	var="${var//"\\\\$c"/$b$b$c}"
		var="${var//"\\$c"/$b$c}"
	done
 		var="${var//"\\"/\\\\}"  #slash proper
	for c in "${JSON_CHARS[@]}"
	do 	var="${var//"$b$b$c"/\\\\$c}"
		var="${var//"$b$c"/\\$c}"
	done
		var="${var//"$b$b "/\\\\ }"  #space
		var="${var//"$b "/ }"

	var="${var//[$'\t']/\\t}"    #tabs
	var="${var//[$'\n']/\\n}"    #new line
	var="${var//[$'\b\f\r\v']}"  #rm literal form-feed, v-tab, ret
	var="${var//"\\\""/\"}"      #rm excess double quote escapes
 	var="${var//"\""/\\\"}"      #double quote marks

	printf '%s\n' "$var"
}

function break_sessionf
{
	[[ -f "$FILECHAT" ]] || return
	[[ BREAK"$(tail -n 20 "$FILECHAT")" = *[Bb][Rr][Ee][Aa][Kk] ]] \
	|| tee -a -- "$FILECHAT" >&2 <<<'SESSION BREAK'
}

#fix variable value, add zero before/after dot.
function fix_dotf
{
	eval "[[ \$$1 = [0-9.] ]] || return"
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
#usage: fmt_ccf [prompt] [role]
function fmt_ccf
{
	[[ -n ${1//[$IFS]} ]] || return
	printf '{"role": "%s", "content": "%s"}\n' "${2:-user}" "$1"
}

#create user log
function usr_logf
{
	[[ -d $USRLOG ]] && USRLOG="$USRLOG/${FILETXT##*/}"
	[[ "$USRLOG" = '~'* ]] && USRLOG="${HOME}${USRLOG##\~}"
	set -- "${*//$NL$NL/$NL}"
	set -- "${*//$NL$NL/$NL}"
	set -- "${*//$NL/$NL$NL}"
	printf '%s%s\n\n%s\n' "${H_TIME:-$(date -R 2>/dev/null||date)}" "${MAX_PREV:+  Tokens: $MAX_PREV}" "${*##$SPC}"
}

#wrap text at spaces rather than mid-word
function foldf
{
	if ((COLUMNS>16)) && [[ -t 1 ]]
	then 	fold -s -w $COLUMNS 2>/dev/null || cat
	else 	cat
	fi
}

#check if a value if within a fp range
#usage: check_optrangef [val] [min] [max]
function check_optrangef
{
	typeset val min max prop ret
	val="${1:-0}" min="${2:-0}" max="${3:-0}" prop="${4:-property}"

	if ${OK_BC} command -v bc >/dev/null 2>&1 && OK_BC=:
	then 	ret=$(bc <<<"($val < $min) || ($val > $max)")
	fi
	
	if [[ $val = *[!0-9.,+-]* ]] || ((ret))
	then 	printf "${Red}Warning: Bad %s -- ${BRed}%s${NC}  ${Yellow}(%s - %s)${NC}\\n" "$prop" "$val" "$min" "$max" >&2
		return 1
	fi ;return ${ret:-0}
}

#check and set settings
function set_optsf
{
	typeset s n
	check_optrangef "$OPTA"   -2.0 2.0 'Presence Penalty'
	check_optrangef "$OPTAA"  -2.0 2.0 'Frequency Penalty'
	check_optrangef "${OPTB:-$OPTN}"  "$OPTN" 50 'Best Of'
	check_optrangef "$OPTBB" 0   5 'Log Probs'
	check_optrangef "$OPTP"  0.0 1.0 'Top_p'
	check_optrangef "$OPTT"  0.0 2.0 'Temperature'  #whisper max=1
	check_optrangef "$OPTMAX"  1 "$MODMAX" 'Response Max Tokens'
	((OPTI)) && check_optrangef "$OPTN"  1 10 'Number of Results'
	#[[ -n ${OPTT#0} ]] && [[ -n ${OPTP#1} ]] \
	#&& __warmsgf "Warning:" "Temperature and Top_P are both set"

	[[ -n $OPTA ]] && OPTA_OPT="\"presence_penalty\": $OPTA," || unset OPTA_OPT
	[[ -n $OPTAA ]] && OPTAA_OPT="\"frequency_penalty\": $OPTAA," || unset OPTAA_OPT
	[[ -n $OPTB ]] && OPTB_OPT="\"best_of\": $OPTB," || unset OPTB_OPT
	[[ -n $OPTBB ]] && OPTBB_OPT="\"logprobs\": $OPTBB," || unset OPTBB_OPT
	[[ -n $OPTP ]] && OPTP_OPT="\"top_p\": $OPTP," || unset OPTP_OPT
	((OPTV<1)) && unset OPTV
	
	if ((${#STOPS[@]}))
	then  #compile stop sequences  #def: <|endoftext|>
		unset OPTSTOP
		for s in "${STOPS[@]}"
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
	[[ "$RESTART" = "$OLD_RST" ]] || RESTART="$(escapef "$RESTART")" OLD_RST="$RESTART"
	[[ "$START" = "$OLD_ST" ]] || START="$(escapef "$START")" OLD_ST="$START"
}

#record mic
#usage: recordf [filename]
function recordf
{
	typeset termux pid sig REPLY

	[[ -e $1 ]] && rm -- "$1"  #remove file before writing to it
	if { 	((OPTV<2)) && ((!WSKIP)) ;} || [[ ! -t 1 ]]
	then 	printf "\\r${BWhite}${On_Purple}%s${NC} " ' * Press ENTER to START record * ' >&2
		REPLY=$(__read_charf)
		case "$REPLY" in [AaNnQq]|$'\e') 	return 201;; esac
	fi ;printf "\\r${BWhite}${On_Purple}%s${NC}\\n\\n" ' * Press ENTER to STOP record * ' >&2

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
	
	sig="INT HUP TERM EXIT"
	trap "rec_killf $pid $termux; trap - $sig" $sig
	read ;rec_killf $pid $termux
	trap "-" $sig
	wait
}
#avfoundation for macos: <https://apple.stackexchange.com/questions/326388/>
function rec_killf
{
	typeset pid termux
	pid=$1 termux=$2
	((termux)) && termux-microphone-record -q >&2 || kill -INT $pid;
}

#set whisper language
function __set_langf
{
	if [[ $1 = [a-z][a-z] ]]
	then 	if ((!OPTWW))
		then 	LANGW="-F language=$1"
			((OPTV)) || __sysmsgf 'Language:' "$1" >&2
		fi ;return 0
	fi ;return 1
}

#whisper
function whisperf
{
	typeset file REPLY
	check_optrangef "$OPTT" 0 1.0 Temperature
	__sysmsgf 'Temperature:' "$OPTT"

	#set language ISO-639-1 (two letters)
	if __set_langf "$1"
	then 	shift
	elif __set_langf "$2"
	then 	set -- "${@:1:1}" "${@:3}"
	fi
	
	if [[ ! -e $1 ]] && ((!OPTC))
	then 	printf "${Purple}%s${NC} " 'Record mic input? [Y/n] ' >&2
		REPLY=$(__read_charf)
		case "$REPLY" in
			[AaNnQq]|$'\e') 	:;;
			*) 	WSKIP=1 recordf "$FILEINW"
				set -- "$FILEINW" "$@";;
		esac
	fi
	
	if [[ ! -e $1 ]] || [[ $1 != *@(mp3|mp4|mpeg|mpga|m4a|wav|webm) ]]
	then 	printf "${BRed}Err: %s -- %s${NC}\\n" 'Unknown audio format' "$1" >&2
		return 1
	else 	file="$1" ;shift
	fi ;[[ -e $1 ]] && shift  #get rid of eventual second filename
	
	#set a prompt
	[[ -z ${*//[$IFS]} ]] || set -- -F prompt="$(escapef "$*")"

	#response_format (timestamps) - testing
	if ((OPTW>1||OPTWW>1)) && ((!OPTC))
	then
		OPTW_FMT=verbose_json   #json, text, srt, verbose_json, or vtt.
		[[ -n $OPTW_FMT ]] && set -- -F response_format="$OPTW_FMT" "$@"

		prompt_audiof "$file" $LANGW "$@"
		jq -r "def yellow: \"\"; def bpurple: \"\"; def reset: \"\"; $JQCOL
			def pad(x): tostring | (length | if . >= x then \"\" else \"0\" * (x - .) end) as \$padding | \"\(\$padding)\(.)\";
			def seconds_to_time_string:
			def nonzero: floor | if . > 0 then . else empty end;
			if . == 0 then \"00\"
			else
			[(./60/60         | nonzero),
			 (./60       % 60 | pad(2)),
			 (.          % 60 | pad(2))]
			| join(\":\")
			end;
			\"Task: \(.task)\" +
			\"\\t\" + \"Lang: \(.language)\" +
			\"\\t\" + \"Dur: \(.duration|seconds_to_time_string)\" +
			\"\\n\", (.segments[]| \"[\" + yellow + \"\(.start|seconds_to_time_string)\" + reset + \"]\" +
			bpurple + .text + reset)" "$FILE" \
			|| jq -r '.text' "$FILE" || cat -- "$FILE"
			#https://rosettacode.org/wiki/Convert_seconds_to_compound_duration#jq
			#https://stackoverflow.com/questions/64957982/how-to-pad-numbers-with-jq
	else
		prompt_audiof "$file" $LANGW "$@"
		jq -r "def bpurple: \"\"; def reset: \"\"; $JQCOL
		bpurple + .text + reset" "$FILE" || cat -- "$FILE"
	fi
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
			img_convf "$1" $ARGS "${PNG32}${FILEIN}" &&
				set -- "${FILEIN}" "${@:2}"  #adjusted
		else 	((OPTV)) ||
			printf '%s\n' 'No adjustment needed in image file' >&2
		fi ;unset ARGS PNG32
						
		if [[ -e $2 ]]  #edits + mask file
		then 	size=$(print_imgsizef "$1") 
			if ! __is_pngf "$2" || {
				[[ $(print_imgsizef "$2") != "$size" ]] &&
				{ 	((OPTV)) || printf '%s\n' 'Mask size differs' >&2 ;}
			} || __is_opaquef "$2" || [[ -n ${OPT_AT+true} ]]
			then 	mask="${FILEIN%.*}_mask.png" PNG32="png32:" ARGS=""
				__set_alphaf "$2"
				img_convf "$2" -scale "$size" $ARGS "${PNG32}${mask}" &&
					set  -- "$1" "$mask" "${@:3}"  #adjusted
			else 	((OPTV)) ||
				printf '%s\n' 'No adjustment needed in mask file' >&2
			fi
		fi
	fi ;unset ARGS PNG32
	
	__chk_imgsizef "$1" || return 2

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
	then 	((OPTV)) || printf '%s\n' 'Not a PNG image' >&2
		return 1
	fi ;return 0
}
#convert image
#usage: img_convf [in_file] [opt..] [out_file]
function img_convf
{
	typeset REPLY
	if ((!OPTV))
	then 	[[ $ARGS = *-transparent* ]] &&
		printf "${BWhite}%-12s -- %s${NC}\\n" "Alpha colour" "${OPT_AT:-black}" "Fuzz" "${OPT_AT_PC:-2}%" >&2
		__sysmsgf 'Edit with ImageMagick?' '[Y/n] ' ''
		REPLY=$(__read_charf) ;case "$REPLY" in [AaNnQq]|$'\e') 	return 2;; esac
	fi

	if magick convert "$1" -background none -gravity center -extent 1:1 "${@:2}"
	then 	if ((!OPTV))
		then 	set -- "${@##png32:}" ;__openf "${@:$#}"
			__sysmsgf 'Confirm edit?' '[Y/n] ' ''
			REPLY=$(__read_charf) ;case "$REPLY" in [AaNnQq]|$'\e') 	return 2;; esac
		fi
	else 	false
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
	fi
}
#print image size
function print_imgsizef
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

# awesome-chatgpt-prompts / custom prompts
function awesomef
{
	typeset act_keys act a l n
	set -- "${INSTRUCTION##/}"
	set -- "${1// /_}"

	if [[ ! -s $FILEAWE ]] || [[ $1 = /* ]]  #second slash
	then 	set -- "${1##/}"
		if ! curl -\#L "https://raw.githubusercontent.com/f/awesome-chatgpt-prompts/main/prompts.csv" -o "$FILEAWE"
		then 	[[ -f $FILEAWE ]] && rm -- "$FILEAWE"
			return 1
		fi
	fi ;set -- "${1:-%#}" 

	#map prompts to indexes and get user selection
	act_keys=$(sed -e '1d; s/,.*//; s/^"//; s/"$//; s/""/\\"/g; s/[][()`*_]//g; s/ /_/g' "$FILEAWE")
	if ! act=$(grep -n -i -e "${1//[ _-]/[ _-]}" <<<"${act_keys}")
	then 	select act in ${act_keys}
		do 	break
		done ;act="$REPLY"
	elif act="$(cut -f1 -d: <<<"$act")"
		[[ ${act} = *$'\n'?* ]]
	then 	while read l;
		do 	((++n));
			for a in ${act};
			do 	((n==a)) && printf '%d) %s\n' "$n" "$l" >&2;
			done;
		done <<<"${act_keys}"
		printf '#? ' >&2 ;read -r act
	fi

	INSTRUCTION="$(sed -n -e 's/^[^,]*,//; s/""/"/g; s/^"//; s/"$//' -e "$((act+1))p" "$FILEAWE")"
	read -r -e -i "$INSTRUCTION" INSTRUCTION
	if [[ -z $INSTRUCTION ]]
	then 	__warmsgf 'Err:' 'awesome-chatgpt-prompts fail'
		return 1
	fi ;return 0
}

# Set the clipboard command
function set_clipcmdf
{
	if command -v termux-clipboard-set
	then 	CLIP_CMD='termux-clipboard-set'
	elif command -v pbcopy
	then 	CLIP_CMD='pbcopy'
	elif command -v xsel
	then 	CLIP_CMD='xsel -b'
	elif command -v xclip
	then 	CLIP_CMD='xclip -selection clipboard'
	fi >/dev/null 2>&1
}


#parse opts
optstring="a:A:b:B:cCefhHijlL:m:M:n:kK:p:r:R:s:S:t:ouvVxwWz0123456789@:/,.+-:"
while getopts "$optstring" opt
do
	if [[ $opt = - ]]  #long options
	then 	for opt in   @:alpha  M:max-tokens  M:max \
			a:presence-penalty      a:presence \
			A:frequency-penalty     A:frequency \
			b:best-of   b:best      B:log-prob  B:prob \
			c:chat      C:resume  C:continue  C:cont \
			e:edit      f:no-config  h:help  H:hist \
			i:image     j:raw       k:no-colo?r \
			K:api-key   l:list-model   l:list-models \
			L:log       m:model        m:mod \
			n:results  o:clipboard  o:clip  p:top-p \
			p:top  r:restart-sequence  r:restart-seq \
			R:start-sequence           R:start-seq \
			s:stop      S:instruction  t:temperature \
			t:temp       u:multiline   u:multi  v:verbose \
			x:editor  w:transcribe  W:translate  z:last
			#opt:cmd_name
		do
			name="${opt##*:}"  name="${name/[_-]/[_-]}"
			opt="${opt%%:*}"
			case "$OPTARG" in $name*) 	break;; esac
		done

		case "$OPTARG" in
			$name|$name=)
				if [[ $optstring = *"$opt":* ]]
				then 	OPTARG="${@:$OPTIND:1}"
					OPTIND=$((OPTIND+1))
				fi
				;;
			$name=*)
				OPTARG="${OPTARG##$name=}"
				;;
			[0-9]*)
				OPTARG="$OPTMM-$OPTARG" opt=M 
				;;
			*) 	__warmsgf "Unkown option:" "--$OPTARG"
				exit 2;;
		esac ;unset name
	fi
	fix_dotf OPTARG

	case "$opt" in
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
		[0-9/,.+-]) 	OPTMM="$OPTMM$opt";;
		M) 	OPTMM="$OPTARG";;
		a) 	OPTA="$OPTARG";;
		A) 	OPTAA="$OPTARG";;
		b) 	OPTB="$OPTARG";;
		B) 	OPTBB="$OPTARG";;
		c) 	((++OPTC));;
		C) 	((++OPTRESUME));;
		e) 	OPTE=1 EPN=2;;
		f$OPTF) unset EPN MOD MOD_CHAT MOD_EDIT MOD_AUDIO MODMAX INSTRUCTION CHATINSTR OPTC OPTE OPTI OPTJ OPTLOG USRLOG OPTRESUME OPTHH OPTL OPTMARG OPTM OPTMM OPTMAX OPTA OPTAA OPTB OPTBB OPTN OPTP OPTT OPTV OPTVV OPTW OPTWW OPTZ OPTCLIP OPTMULTI MULTI OPT_AT_PC OPT_AT Q_TYPE A_TYPE RESTART START STOPS
			OPTF=1 OPTIND=1 OPTARG= ;. "$0" "$@" ;exit;;
		h) 	while read
			do 	[[ $REPLY = \#\ v* ]] && break
			done <"$0"
			printf '%s\n' "$REPLY" "$HELP"
			exit;;
		H) 	((++OPTHH));;
		i) 	OPTI=1 EPN=3 MOD=image;;
		j) 	OPTJ=1;;
		l) 	((++OPTL));;
		L) 	OPTLOG=1 USRLOG="$OPTARG"
			__cmdmsgf 'Log file' "\`\`$USRLOG''";;
		m) 	OPTMARG="${OPTARG:-0}"
			if [[ $OPTARG = *[a-zA-Z]* ]]
			then 	MOD="$OPTARG"  #model name
			else 	MOD="${MODELS[OPTARG]}" #pre-defined model index
			fi;;
		n) 	OPTN="$OPTARG" ;;
		k) 	OPTK=1;;
		K) 	OPENAI_API_KEY="$OPTARG";;
		o) 	OPTCLIP=1;;
		p) 	OPTP="$OPTARG";;
		r) 	RESTART="$OPTARG";;
		R) 	START="$OPTARG";;
		s) 	((${#STOPS[@]})) && STOPS=("$OPTARG" "${STOPS[@]}") \
			|| STOPS=("$OPTARG");;
		S) 	if [[ -f "$OPTARG" ]]
			then 	INSTRUCTION=$(<"$OPTARG")
			else 	INSTRUCTION="$OPTARG"
			fi;;
		t) 	OPTT="$OPTARG";;
		u) 	OPTMULTI=1;;
		v) 	((++OPTV));;
		V) 	((++OPTVV));;  #debug
		x) 	OPTX=1;;
		w) 	((++OPTW));;
		W) 	((OPTW)) || OPTW=1 ;((++OPTWW));;
		z) 	OPTZ=1;;
		\?) 	exit 1;;
	esac ;OPTARG=
done ;unset LANGW CMPLOK N_LOOP optstring opt col1 col2 role rest
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
Alert=$BWhite$On_Red  NC='\e[m'  JQCOL='def red: "\u001b[31m"; def bgreen: "\u001b[1;32m";
def purple: "\u001b[0;35m"; def bpurple: "\u001b[1;35m"; def bwhite: "\u001b[1;37m";
def yellow: "\u001b[33m"; def byellow: "\u001b[1;33m"; def reset: "\u001b[0m";'
NL=$'\n'

OPENAI_API_KEY="${OPENAI_API_KEY:-${OPENAI_KEY:-${GPTCHATKEY:-${BEARER:?API key required}}}}"
((OPTL+OPTZ)) && unset OPTX
((OPTE+OPTI)) && unset OPTC
((OPTCLIP)) && set_clipcmdf
((OPTC)) || OPTT="${OPTT:-0}"  #!#
((!OPTC)) && ((OPTRESUME)) && OPTCMPL=1

#invert -v logic for chat
if ((OPTC+OPTRESUME))
then 	((++OPTV)) ;((OPTV%=4))
fi

if ((OPTI+OPTII))
then 	command -v base64 >/dev/null 2>&1 || OPTI_FMT=url
	if set_sizef "${OPTS:-$1}"
	then 	[[ -n $OPTS ]] || shift
	elif set_sizef "${OPTS:-$2}"
	then 	[[ -n $OPTS ]] || set -- "$1" "${@:3}"
	fi
	[[ -e $1 ]] && OPTII=1  #img edits and vars
fi

[[ -n $OPTMARG ]] ||
if ((OPTE))  #edits
then 	OPTM=8 MOD="$MOD_EDIT"
elif ((OPTC>1))  #chat
then 	OPTM=4 MOD="$MOD_CHAT"
elif ((OPTW)) && ((!OPTC))  #audio
then 	OPTM=11 MOD="$MOD_AUDIO"
fi

MOD="${MOD:-${MODELS[OPTM]}}"
[[ -n $EPN ]] || set_model_epnf "$MOD"
[[ -n ${INSTRUCTION//[$IFS]} ]] || unset INSTRUCTION

#auto set ``model capacity''
((MODMAX)) ||
case "$MOD" in  #set model max tokens
	davinci|curie|babbage|ada) 	MODMAX=2049;;
	code-davinci-002) MODMAX=8001;;
	gpt4-*32k) 	MODMAX=32768;; 
	gpt4-*) 	MODMAX=8192;;
	*turbo*|*davinci*) 	MODMAX=4096;;
	*) 	MODMAX=2048;;
esac

#set ``max response tkns''
set_maxtknf "${OPTMM:-$OPTMAX}"

#set other options
set_optsf

#load stdin
(($#)) || [[ -t 0 ]] || set -- "$(</dev/stdin)"

((OPTX)) && ((OPTE+OPTEMBED+OPTI+OPTII)) &&
edf "$@" && set -- "$(<"$FILETXT")"  #editor

if ((!(OPTHH+OPTI+OPTL+OPTZ+OPTW) ))
then 	__sysmsgf 'Language Model' "$MOD"
	__sysmsgf "Max Input / Response:" "$MODMAX / $OPTMAX tokens"
     	((!$#)) || token_prevf "$*"
fi

for arg  #escape input
do 	((init++)) || set --
	set -- "$@" "$(escapef "$arg")"
done ;unset arg init

mkdir -p "$CACHEDIR" || exit
command -v jq >/dev/null 2>&1 || function jq { 	false ;}

if ((OPTHH))  #edit history/pretty print last session
then 	if ((OPTHH>1))
	then 	((!OPTRESUME)) && OPTC=1
		MODMAX=65536 set_histf
		usr_logf "$(unescapef "$HIST")"
	elif [[ -t 1 ]]
	then 	__edf "$FILECHAT"
	else 	cat -- "$FILECHAT"
	fi
elif ((OPTZ))      #last response json
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
then 	[[ $MOD = *embed* ]] || __warmsgf "Warning:" "Not an embedding model -- $MOD"
	unset Q_TYPE A_TYPE OPTC
	embedf "$@"
elif ((OPTE))      #edits
then 	__sysmsgf 'Text Edits'
	[[ $MOD = *edit* ]] || __warmsgf "Warning:" "Not an edits model -- $MOD"
	[[ -f $1 ]] && set -- "$(<"$1")" "${@:2}"
	if (($# == 1)) && ((${#INSTRUCTION}))
	then 	set -- "$INSTRUCTION" "$@"
		__sysmsgf 'INSTRUCTION:' "$INSTRUCTION" 
	fi
	editf "$@"
else               #text/chat completions
	[[ -f $1 ]] && set -- "$(<"$1")" "${@:2}"  #load file as 1st arg
	((OPTW)) && { 	INPUT_ORIG=("$@") ;unset OPTX ;set -- ;}  #whisper input
	if ((OPTC))
	then 	__sysmsgf 'Chat Completions'
		#chatbot must sound like a human, shouldn't be lobotomised
		#presencePenalty:0.6 temp:0.9 maxTkns:150 :The following is a conversation with an AI assistant. The assistant is helpful, creative, clever, and very friendly.
		#frequencyPenalty:0.5 temp:0.5 top_p:03 maxTkns:60 :Marv is a chatbot that reluctantly answers questions with sarcastic responses:
		OPTA="${OPTA:-0.4}" OPTT="${OPTT:-0.6}"  #!#
		((EPN==6)) || STOPS+=("${Q_TYPE//$SPC0}" "${A_TYPE//$SPC0}")
	else 	((EPN==6)) || __sysmsgf 'Text Completions'
	fi
	if ((OPTCMPL))
	then 	OPTMULTI=1 ;OPTV= __cmdmsgf 'Multiline' 'ON'
	fi
	((EPN!=6)) || unset RESTART START

	#awesome prompts
	if [[ $INSTRUCTION = /* ]] && ((!OPTW))
	then 	OPTAWE=1 ;((OPTC)) || OPTC=1
		awesomef || exit
	fi
	#model instruction
	if ((OPTC+OPTRESUME))
	then 	{ 	((OPTC)) && ((OPTRESUME)) ;} || ((OPTRESUME==1)) || {
		  break_sessionf
		  INSTRUCTION="${INSTRUCTION:-Be a helpful assistant.}"
		  push_tohistf "$(escapef ":${INSTRUCTION##:$SPC}")"
		  __sysmsgf 'INSTRUCTION:' "${INSTRUCTION##:$SPC}" 2>&1 | foldf >&2
		} ;unset INSTRUCTION
	elif [[ -n $INSTRUCTION ]]
	then 	  __sysmsgf 'INSTRUCTION:' "${INSTRUCTION##:}" 2>&1 | foldf >&2
	fi

	#load history
	history -c ;history -r
	if ((OPTC+OPTRESUME))  #chat mode
	then 	if check_cmdf "$*"
		then 	set --
		else 	history -s -- "$*"
		fi
	fi

	WSKIP=1 ;unset REPLY N_LOOP SKIP EDIT input arg
	while :
	do 	((REGEN)) && { 	set -- "${PROMPT_LAST:-$*}" ;unset REGEN ;}
		((OPTAWE)) || {  #awesome 1st pass skip

		#text editor prompter
		if ((OPTX))
		then 	edf "$@" || case $? in 200) 	continue;; 201) 	break;; esac
			while P="$(<"$FILETXT")" P="${P##$SPC1}"
				printf "${BRed}${P:+${BCyan}}%s${NC}\\n" "${P:-(EMPTY)}"
			do 	((OPTV>1)) || new_prompt_confirmf
				case $? in
					201) 	break 2;;  #abort
					200) 	continue 2;;  #redo
					199) 	edf "${P:-$*}" || break 2;;  #edit
					0) 	set -- "$P" ; break;;  #yes
					*) 	set -- ; break;;  #no
				esac
			done ;unset P
		fi

		#defaults prompter
		if [[ "$* " = @("${Q_TYPE##$SPC0}"|"${RESTART##$SPC1}")$SPC ]] || [[ "$*" = $SPC ]]
		then 	((OPTC)) && Q="${RESTART:-${Q_TYPE}}" || Q="${RESTART}"
			Q="$(unescapef "${Q}")" ;[[ -n "${Q//[$IFS]}" ]] || Q=">"
			while { 	((SKIP)) && { 	((OPTK)) || printf "${BCyan}" >&2 ;} ;} ||
				printf "${Cyan}%s${NC}${Purple}%s${NC}\\r${BCyan}" "${Q}" "${OPTW:+VOICE}" >&2
			do
				if ((OPTW)) && ((!EDIT))
				then 	((OPTV)) && ((!WSKIP)) && [[ -t 1 ]] \
					&& __read_charf -t $((SLEEP/4))  #3-6 (words/tokens)/sec

					if recordf "$FILEINW"
					then 	REPLY=$(
						MOD="${MOD_AUDIO:-${MODELS[11]}}" JQCOL= OPTT=0
						set_model_epnf "$MOD"
						whisperf "$FILEINW" "${INPUT_ORIG[@]}"
					)
					else 	unset OPTW
					fi ;printf "${BPurple}%s${NC}\\n" "${REPLY:-"(EMPTY)"}" >&2
				else
					if ((OPTCMPL)) && ((N_LOOP)) && [[ -z "${RESTART}${REPLY}" ]]
					then 	REPLY="\\ " EDIT=1 CMPLOK=1
					fi ;unset ex
					while ((EDIT)) || unset REPLY  #!#
						((OPTMULTI+MULTI)) && printf "> \\r" >&2
						read -r -e ${REPLY:+-i "$REPLY"} REPLY
					do 	unset EDIT
						case "$REPLY" in
							*\\) 	MULTI=1 ex=1
								REPLY="${REPLY%%?(\\)\\}"
								if [[ -z $REPLY ]]
								then 	input="${input}${input:+\\n}"
									continue
								fi;;
							[:/!-]*)
								if check_cmdf "$REPLY"
								then 	continue
								fi;;
						esac
						[[ -n "$REPLY" ]] || break ;unset ex
						input="${input}${input:+\\n}${REPLY}"
						((MULTI+OPTMULTI)) || break
					done
					REPLY="${input:-$REPLY}"
					((ex)) || REPLY="${REPLY%%\\n}"
					unset MULTI CMPLOK arg input ex
				fi
				((OPTK)) || printf "${NC}" >&2
				
				if check_cmdf "$REPLY"
				then 	unset EDIT
					REPLY="${REPLY_OLD:-$REPLY}"  #regen cmd integration
					set --
					continue 2
				elif [[ ${REPLY//[$IFS]} = */ ]] && ((!OPTW)) #regen cmd
				then
					[[ $REPLY = /* ]] && REPLY="${REPLY_OLD:-$REPLY}"  #regen cmd integration
					REPLY="${REPLY%/*}" REPLY_OLD="$REPLY"
					optv_save=${OPTV:-0} OPTV=2 RETRY=1
					((OPTK)) || BCyan='\e[0;36m' 
				elif [[ -n $REPLY ]]
				then
					((RETRY)) || ((OPTV>1)) \
					|| new_prompt_confirmf 
					case $? in
						201) 	break 2;;  #abort
						200) 	WSKIP=1 ;continue;;  #redo
						199) 	WSKIP=1 EDIT=1 ;continue;;  #edit
						0) 	:;;  #yes
						*) 	unset REPLY; set -- ;break;;  #no
					esac

					if ((RETRY))
					then 	if [[ "$REPLY" = "$REPLY_OLD" ]]
						then 	RETRY=2 REPLY_OLD= 
							((OPTK)) || BCyan='\e[1;36m'
						fi ;REPLY_OLD="$REPLY"
					fi ;OPTV=${optv_save:-$OPTV}
					unset optv_save
				else
					set --
				fi ; set -- "$REPLY"
				unset WSKIP SKIP EDIT arg
				break
			done
		fi

		if ((!OPTCMPL)) && [[ -z "${INSTRUCTION}${*}" ]]
		then 	__warmsgf "Err:" "PROMPT is empty!"
			__read_charf -t 1 ;set -- ; continue
		fi
		if ((!OPTCMPL))
		then 	set -- "${*##$SPC1}" #!#
			set -- "${*%%$SPC1}"
		fi
		
		}  #awesome 1st pass skip end

		if ((OPTC+OPTRESUME)) && [[ -n "${*}" ]]
		then
			((RETRY==1)) ||
			{ 	history -s -- "${*//$NL/\\n}" ;history -a ;}

			#system/instruction?
			if [[ ${*} = $SPC:* ]]
			then 	push_tohistf "$(escapef ":${*##$SPC:}")"
				if ((OPTV<3)) && ((EPN==6))
				then 	OPTV=  __sysmsgf "System message added"
				elif ((OPTV<3))
				then 	OPTV=  __sysmsgf "Text appended"
				fi
				set -- ;continue
			fi
			REC_OUT="${Q_TYPE}${*}" PROMPT_LAST="${*}"
		fi

		if ((RETRY<2))
		then 	((OPTC+OPTRESUME)) && set_histf "${@}"
			if ((OPTC)) || [[ -n "${RESTART}" ]]
			then 	rest="${RESTART:-$Q_TYPE}"
			else 	unset rest
			fi
			ESC="$(escapef "${INSTRUCTION}")${INSTRUCTION:+\\n\\n}${HIST}$(escapef "${rest}${*}")"
			
			if ((EPN==6))
			then 	#chat cmpls
				[[ ${*//[$IFS]} = :* ]] && role=system || role=user
				set -- "$(fmt_ccf "$(escapef "$INSTRUCTION")" system)${INSTRUCTION:+,}${HIST_C}${HIST_C:+,}$(fmt_ccf "$(escapef "$*")" "$role")"
			else 	#text compls
				if ((OPTC)) || [[ -n "${START}" ]]
				then 	set -- "${ESC}${START:-$A_TYPE}"
				else 	set -- "${ESC}"
				fi
			fi ;unset rest role
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
		((RETRY>1)) || promptf || { 	EDIT=1 SKIP=1 ;set -- ;continue ;} #opt -VV
		((OPTC)) && printf '\n' >&2 

		#response colours for jq
		if ((RETRY>1)) ;then 	unset JQCOL2
		elif ((RETRY)) ;then 	((OPTK)) || JQCOL2='def byellow: yellow;'
		fi
		#response prompt
		prompt_printf
		if ((OPTCLIP)) || [[ ! -t 1 ]]
		then 	out=$(JQCOL2='def byellow:"";def reset:""' OPTV=1 prompt_printf)
			((OPTCLIP)) && ${CLIP_CMD:-false} <<<"$out" &
			[[ ! -t 1 ]] && printf "%s\\n" "$out" >&2
		fi
		
		((RETRY==1)) && { 	SKIP=1 EDIT=1 ;set -- ;continue ;}

		#record to hist file
		if ((OPTC+OPTRESUME)) && {
		 	tkn=($(jq -r '.usage.prompt_tokens//"0",
				.usage.completion_tokens//"0",
				(.created//empty|strflocaltime("%Y-%m-%dT%H:%M:%S%Z"))' "$FILE"
			) )
			ans=$(jq '.choices[0]|.text//.message.content' "$FILE")
			ans="${ans##[\"]}" ans="${ans%%[\"]}"
			((${#tkn[@]}>2)) && ((${#ans}))
		}
		then
			ans="${A_TYPE##$SPC0}${ans}"
			((OPTB>1)) && tkn[1]=$(__tiktokenf "$(unescapef "$ans" "4")") #tkn sum will compensate later
			((OPTAWE)) || push_tohistf "$(escapef "${REC_OUT:-$*}")" "$((tkn[0]-OLD_TOTAL))" "${tkn[2]}"
			push_tohistf "$ans" "${tkn[1]}" "${tkn[2]}"
			((OLD_TOTAL=tkn[0]+tkn[1])) ;MAX_PREV="$OLD_TOTAL" H_TIME=
		elif ((OPTC+OPTRESUME))
		then 	BAD_RESPONSE=1 SKIP=1 EDIT=1 ;set -- ;continue
		fi
		((OPTLOG)) && usr_logf "$(unescapef "$ESC\\n${ans}")" > "$USRLOG" &
		SLEEP="${tkn[1]}"

		((++N_LOOP)) ;set --
		unset INSTRUCTION TKN_PREV REC_OUT HIST HIST_C WSIP SKIP EDIT REPLY REPLY_OLD OPTA_OPT OPTAA_OPT OPTP_OPT OPTB_OPT OPTBB_OPT OPTSTOP OPTAWE RETRY BAD_RESPONSE ESC CMPLOK Q P optv_save role rest tkn arg ans glob out s n
		((OPTC+OPTRESUME)) || break
	done ;unset OLD_TOTAL SLEEP N_LOOP SPC SPC0 SPC1 TYPE_GLOB
fi
