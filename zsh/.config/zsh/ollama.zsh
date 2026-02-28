#!/bin/zsh

# ZSH completion for ollama CLI.
#
# Install by placing this file in your fpath or source it in your .zshrc:
#   source /path/to/_ollama_completion.zsh
#
# Or copy to a directory in your fpath as _ollama:
#   cp _ollama_completion.zsh ~/.zsh/completions/_ollama
#   fpath=(~/.zsh/completions $fpath)
#   autoload -Uz compinit && compinit
#
# Needs `jq` and `curl`.
# Install `pup` [https://github.com/ericchiang/pup] to get ollama library completion.
#
# Environment variables:
#   _OLLAMA_MODEL_TTL       - Min seconds between model fetches from server. Default 300s.
#   _OLLAMA_LIBRARY_TTL     - Min seconds between model fetches from library. Default 3600s.
#   _OLLAMA_QUANTS_TTL      - Min seconds between quant fetches from library. Default 300s.
#   _OLLAMA_LIBRARY_LIMIT   - Max models to retrieve from library. Default 10.
#   _OLLAMA_LIBRARY_SORT    - Sort order: newest|popular|featured. Default newest.
#   _OLLAMA_QUANTS          - List of quantizations for `ollama create --quantize`.

if ! command -v jq >&/dev/null; then
  echo "${0}: Need jq for model completion"
  return 1
fi
if ! command -v curl >&/dev/null; then
  echo "${0}: Need curl for model completion"
  return 1
fi

# --- State variables ---
_OLLAMA_MODELS=""
_OLLAMA_LIBRARY=""
_OLLAMA_MODEL_TTL=${_OLLAMA_MODEL_TTL:-300}
_OLLAMA_LIBRARY_TTL=${_OLLAMA_LIBRARY_TTL:-3600}
_OLLAMA_QUANTS_TTL=${_OLLAMA_QUANTS_TTL:-300}
_OLLAMA_LIBRARY_LIMIT=${_OLLAMA_LIBRARY_LIMIT:-10}
_OLLAMA_LIBRARY_SORT=${_OLLAMA_LIBRARY_SORT:-newest}
_OLLAMA_MODELS_TIMESTAMP=0
_OLLAMA_LIBRARY_TIMESTAMP=0
_OLLAMA_QUANTS_ALL=(
    F32 F16 BF16
    Q2_K Q2_K_S
    Q3_K_S Q3_K_M Q3_K_L
    Q4_0 Q4_1 Q4_1_F16 Q4_K_S Q4_K_M
    Q5_0 Q5_1 Q5_K_S Q5_K_M
    Q6_K
    Q8_0
    IQ1_S IQ1_M
    IQ2_XXS IQ2_XS IQ2_S IQ2_M
    IQ3_XXS IQ3_XS IQ3_S
    IQ4_NL IQ4_XS
)
_OLLAMA_QUANTS=(${_OLLAMA_QUANTS:-Q4_0 Q4_1 Q4_1_F16 Q8_0 Q4_K_S Q4_K_M F16})

# --- Fetch functions ---

_ollama_fetch_models() {
  _OLLAMA_MODELS="$(curl -s ${OLLAMA_HOST:-localhost:11434}/api/tags | jq -r '.models[].name')"
}

_ollama_maybe_fetch_models() {
  local now=$(date +%s)
  (( now - ${_OLLAMA_MODELS_TIMESTAMP:-0} < _OLLAMA_MODEL_TTL )) && return 0
  _ollama_fetch_models
  _OLLAMA_MODELS_TIMESTAMP=$(date +%s)
}

_ollama_fetch_library_models() {
  command -v pup >&/dev/null || return 0
  local raw_models
  raw_models=$(curl -s "https://ollama.com/library?sort=${_OLLAMA_LIBRARY_SORT:-newest}" |
    pup '#repo ul li a' |
    sed -ne 's@^<a href="/library/\([^"]*\)".*@"\1:":{"base":"/library/\1"}@p' |
    head -${_OLLAMA_LIBRARY_LIMIT:-10})
  [[ -z "$raw_models" ]] && return 0
  _OLLAMA_LIBRARY="{$(echo $raw_models | tr ' ' ',')}"
}

_ollama_maybe_fetch_library_models() {
  local now=$(date +%s)
  (( now - ${_OLLAMA_LIBRARY_TIMESTAMP:-0} < _OLLAMA_LIBRARY_TTL )) && return 0
  _ollama_fetch_library_models
  _OLLAMA_LIBRARY_TIMESTAMP=$(date +%s)
}

_ollama_maybe_fetch_library() {
  local model completions_list timestamp library quants
  command -v pup >&/dev/null || return 0

  [[ -z "$_OLLAMA_LIBRARY" ]] && {
    _ollama_maybe_fetch_library_models
    [[ -z "$_OLLAMA_LIBRARY" ]] && return 0
  }

  # Extract current word being completed
  model="${words[CURRENT]}"
  if [[ "$model" == *:* ]]; then
    model="${model%%:*}:"
  else
    model="${model%%:*}"
  fi

  # Check if we can uniquely identify the model
  completions_list=( $(jq -rn "$_OLLAMA_LIBRARY|keys|.[]" | grep "^${model}") )
  (( ${#completions_list[@]} != 1 )) && return 0
  model="${completions_list[1]}"

  # Skip if quants were retrieved recently
  timestamp="$(jq -rn "$_OLLAMA_LIBRARY|.\"$model\".timestamp")"
  [[ -z "$timestamp" || "$timestamp" == "null" ]] && timestamp=0
  local now=$(date +%s)
  (( now - timestamp < _OLLAMA_QUANTS_TTL )) && return 0

  library="$(jq -rn "$_OLLAMA_LIBRARY|.\"$model\".base")"
  [[ -z "$library" || "$library" == "null" ]] && return 0

  quants="$(curl -s "https://ollama.com${library}/tags" | pup 'section div div div div div div text{}')"
  quants="$(echo $quants)"
  [[ -z "$quants" || "$quants" == "null" ]] && return 0

  # Build quants prefixed by model name
  local prefixed_quants=""
  for q in ${=quants}; do
    prefixed_quants="${prefixed_quants} ${model}${q}"
  done
  prefixed_quants="${prefixed_quants## }"

  _OLLAMA_LIBRARY=$(jq -cn "$_OLLAMA_LIBRARY*{\"$model\":{\"quants\":\"$prefixed_quants\",\"timestamp\":$(date +%s)}}")
}

# --- Completion helper functions ---

_ollama_complete_models() {
  [[ -z "$_OLLAMA_MODELS" ]] && return 1
  local -a models
  models=( ${(f)_OLLAMA_MODELS} )
  compadd -a models
}

_ollama_complete_library() {
  [[ -z "$_OLLAMA_LIBRARY" ]] && return 1
  local current="${words[CURRENT]}"

  if [[ -z "$current" || "$current" != *:* ]]; then
    # Complete model names
    local -a lib_models
    lib_models=( $(jq -rn "$_OLLAMA_LIBRARY|keys|.[]") )
    compadd -a lib_models
    return 0
  fi

  # Complete tags/quants for a specific model
  local model="${current%%:*}:"
  local -a quants_list
  local raw_quants="$(jq -rn "$_OLLAMA_LIBRARY|.\"$model\".quants")"
  [[ -z "$raw_quants" || "$raw_quants" == "null" ]] && return 1
  quants_list=( ${=raw_quants} )
  # Strip model prefix for display after ":"
  local -a stripped
  for q in "${quants_list[@]}"; do
    stripped+=( "${q#${model}}" )
  done
  compadd -p "${model}" -a stripped
}

_ollama_complete_models_and_library() {
  _ollama_complete_models
  _ollama_maybe_fetch_library
  _ollama_complete_library
}

# --- Post-command hook to flush caches ---

_ollama_precmd_hook() {
  if [[ "$_OLLAMA_FLUSH_MODELS_CACHE" == 1 ]]; then
    _OLLAMA_MODELS=""
    _OLLAMA_MODELS_TIMESTAMP=0
    _OLLAMA_FLUSH_MODELS_CACHE=0
  fi
  if [[ "$_OLLAMA_FLUSH_LIBRARY_CACHE" == 1 ]]; then
    _OLLAMA_LIBRARY=""
    _OLLAMA_LIBRARY_TIMESTAMP=0
    _OLLAMA_FLUSH_LIBRARY_CACHE=0
  fi
}

# Register precmd hook (zsh equivalent of PROMPT_COMMAND)
autoload -Uz add-zsh-hook
add-zsh-hook precmd _ollama_precmd_hook

# --- Main completion function ---

_ollama() {
  local -a subcommands
  subcommands=(
    'serve:Start ollama server'
    'start:Start ollama server'
    'create:Create a model from a Modelfile'
    'show:Show information for a model'
    'run:Run a model'
    'pull:Pull a model from a registry'
    'push:Push a model to a registry'
    'list:List models'
    'ls:List models'
    'ps:List running models'
    'cp:Copy a model'
    'rm:Remove a model'
    'help:Help about any command'
  )

  _ollama_maybe_fetch_models

  # If we're still completing the subcommand
  if (( CURRENT == 2 )); then
    _describe 'ollama command' subcommands
    return
  fi

  local subcmd="${words[2]}"

  case "$subcmd" in
    serve|start)
      compadd -- --help
      ;;
    create)
      case "${words[CURRENT-1]}" in
        --quantize)
          compadd -- ${_OLLAMA_QUANTS[@]}
          ;;
        --file|-f)
          _files
          ;;
        *)
          if [[ "${words[CURRENT]}" == -* ]]; then
            compadd -- --help --file --quantize
          else
            compadd -- --help --file --quantize
          fi
          ;;
      esac
      _OLLAMA_FLUSH_MODELS_CACHE=1
      ;;
    show)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help --license --template --modelfile --parameters --system
      else
        _ollama_complete_models
      fi
      ;;
    run)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help --format --insecure --keepalive --nowordwrap --verbose
      elif [[ "${words[CURRENT-1]}" == --format ]]; then
        compadd -- json
      else
        _ollama_complete_models_and_library
      fi
      ;;
    pull)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help --insecure
      else
        _ollama_maybe_fetch_library
        _ollama_complete_library
      fi
      _OLLAMA_FLUSH_MODELS_CACHE=1
      ;;
    push)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help --insecure
      else
        _ollama_complete_models
      fi
      ;;
    list|ls)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help
      else
        _ollama_complete_models
      fi
      ;;
    ps)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help
      else
        _ollama_complete_models
      fi
      ;;
    cp)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help
      else
        _ollama_complete_models
      fi
      _OLLAMA_FLUSH_MODELS_CACHE=1
      ;;
    rm)
      if [[ "${words[CURRENT]}" == -* ]]; then
        compadd -- --help
      else
        _ollama_complete_models
      fi
      _OLLAMA_FLUSH_MODELS_CACHE=1
      ;;
    help)
      compadd -- serve create show run pull push list ps cp rm
      ;;
    *)
      _describe 'ollama command' subcommands
      ;;
  esac
}

compdef _ollama ollama