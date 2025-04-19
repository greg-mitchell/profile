# Why Not X?

This documents my reasons for the particular tech choices.

## Bash, Fish, etc

Bash is a fine default, but it's hard to go back to Bash's completions after
using Zsh. The richness of the prompt is also quite nice in Zsh.

Fish is a weird shell I have no experience with.

## ZInit

Et alia plugin managers (or none) for Zsh

Oh My Zsh seems to have by far the most robust community, and has been active
for a very long time, which bodes well for continued support.

No plugin manager is tempting, and seems not tooooo different from manually
cloning plugin repos. Worth further exploration.

## Pathogen Plugins

I have a very minimal set of plugins for Vim, and mostly copied a basic .vimrc.
Why? I just don't use Vim as my daily driver editor, so my top need is init
speed and being unobtrusive for Git commits and editing over SSH.

Whitespace highlighting is the one plugin that clearly offers a lot of value,
since I don't want to have to manually fix that crap which definitely gets
highlighted on code reviews.
