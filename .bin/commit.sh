#!/bin/sh
TYPE=$(gum choose "fix" "feat" "docs" "style" "refactor" "test" "chore" "revert")
#SCOPE=$(gum input --placeholder "Scope")

SCOPE=$(gum choose "Major" "Minor" "Breaking" "Refactor")
# Since the scope is optional, wrap it in parentheses if it has a value.
test -n "$SCOPE" && SCOPE="($SCOPE)"

# Pre-populate the input with the type(scope): so that the user may change it
SUMMARY=$(gum input --value "$TYPE$SCOPE: " --placeholder "Summary of this change")
DESCRIPTION=$(gum write --placeholder "Details of this change (CTRL+D to finish)")

# Add changes
git add .

# Commit and push changes
gum confirm "Commit changes?" && git commit -m "$SUMMARY" -m "$DESCRIPTION" && gum confirm "Push Changes" && git push
