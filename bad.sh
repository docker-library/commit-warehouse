#!/bin/bash
set -e

cd "$(dirname "$(readlink -f "$BASH_SOURCE")")"

repos=( "$@" )

if [ "${#repos[@]}" -eq 0 ]; then
	{
		echo 'error: no repos specified'
	} >&2
	exit 1
fi

# globals for handling the repo queue and repo info parsed from library
queue=()
declare -A repoGitRepo=()
declare -A repoGitRef=()
declare -A repoGitDir=()
declare -A repoUniq=()

didFail=

# gather all the `repo:tag` combos to build
for repoTag in "${repos[@]}"; do
	repo="${repoTag%%:*}"
	tag="${repoTag#*:}"
	[ "$repo" != "$tag" ] || tag=
	
	if [ "$repo" = 'http' -o "$repo" = 'https' ] && [[ "$tag" == //* ]]; then
		# IT'S A URL!
		repoUrl="$repo:${tag%:*}"
		repo="$(basename "$repoUrl")"
		if [ "${tag##*:}" != "$tag" ]; then
			tag="${tag##*:}"
		else
			tag=
		fi
		repoTag="${repo}${tag:+:$tag}"
		
		cmd=( curl -fsSL --compressed "$repoUrl" )
	else
		if [ -f "$repo" ]; then
			repoFile="$repo"
			repo="$(basename "$repoFile")"
			repoTag="${repo}${tag:+:$tag}"
		else
			repoFile="$library/$repo"
		fi
		
		if [ ! -f "$repoFile" ]; then
			echo >&2 "error: '$repoFile' does not exist!"
			didFail=1
			continue
		fi
		
		repoFile="$(readlink -f "$repoFile")"
		
		cmd=( cat "$repoFile" )
	fi
	
	if [ "${repoGitRepo[$repoTag]}" ]; then
		if [ "$onlyUniq" ]; then
			uniqLine="${repoGitRepo[$repoTag]}@${repoGitRef[$repoTag]} ${repoGitDir[$repoTag]}"
			if [ -z "${repoUniq[$uniqLine]}" ]; then
				queue+=( "$repoTag" )
				repoUniq[$uniqLine]=$repoTag
			fi
		else
			queue+=( "$repoTag" )
		fi
		continue
	fi
	
	if ! manifest="$("${cmd[@]}")"; then
		echo >&2 "error: failed to fetch $repoTag (${cmd[*]})"
		exit 1
	fi
	
	# parse the repo manifest file
	IFS=$'\n'
	repoTagLines=( $(echo "$manifest" | grep -vE '^#|^\s*$') )
	unset IFS
	
	tags=()
	for line in "${repoTagLines[@]}"; do
		tag="$(echo "$line" | awk -F ': +' '{ print $1 }')"
		for parsedRepoTag in "${tags[@]}"; do
			if [ "$repo:$tag" = "$parsedRepoTag" ]; then
				echo >&2 "error: tag '$tag' is duplicated in '${cmd[@]}'"
				exit 1
			fi
		done
		
		repoDir="$(echo "$line" | awk -F ': +' '{ print $2 }')"
		
		gitUrl="${repoDir%%@*}"
		commitDir="${repoDir#*@}"
		gitRef="${commitDir%% *}"
		gitDir="${commitDir#* }"
		if [ "$gitDir" = "$commitDir" ]; then
			gitDir=
		fi
		
		gitRepo="${gitUrl#*://}"
		gitRepo="${gitRepo%/}"
		gitRepo="${gitRepo%.git}"
		gitRepo="${gitRepo%/}"
		#gitRepo="$src/$gitRepo"
		
		repoGitRepo[$repo:$tag]="$gitRepo"
		repoGitRef[$repo:$tag]="$gitRef"
		repoGitDir[$repo:$tag]="$gitDir"
		tags+=( "$repo:$tag" )
	done
	
	if [ "$repo" != "$repoTag" ]; then
		tags=( "$repoTag" )
	fi
	
	if [ "$onlyUniq" ]; then
		for rt in "${tags[@]}"; do
			uniqLine="${repoGitRepo[$rt]}@${repoGitRef[$rt]} ${repoGitDir[$rt]}"
			if [ -z "${repoUniq[$uniqLine]}" ]; then
				queue+=( "$rt" )
				repoUniq[$uniqLine]=$rt
			fi
		done
	else
		# add all tags we just parsed
		queue+=( "${tags[@]}" )
	fi
done

set -- "${queue[@]}"
while [ "$#" -gt 0 ]; do
	repoTag="$1"
	gitRepo="${repoGitRepo[$repoTag]}"
	gitRef="${repoGitRef[$repoTag]}"
	gitDir="${repoGitDir[$repoTag]}"
	shift
	if [ -z "$gitRepo" ]; then
		echo >&2 'Unknown repo:tag:' "$repoTag"
		didFail=1
		continue
	fi
	
	echo "Processing $repoTag ..."
	
	#git fetch -f --no-tags "https://$gitRepo.git" "refs/heads/*:refs/heads/$gitRepo/*"
	#git tag -f "${repoTag/:/'/'}" "$gitRef"
	if ! git fetch -qf --no-tags "https://$gitRepo.git" "$gitRef:refs/tags/${repoTag/:/'/'}"; then
		# if it fails, fetch all the remote's refs and try again
		git fetch -qf --no-tags "https://$gitRepo.git" "refs/heads/*:refs/heads/$gitRepo/*"
		git fetch -qf --no-tags "https://$gitRepo.git" "$gitRef:refs/tags/${repoTag/:/'/'}"
	fi
done

[ -z "$didFail" ]
