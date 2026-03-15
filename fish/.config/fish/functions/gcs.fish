# ~/.config/fish/functions/gcs.fish
# Clone GitHub repo by SSH
# Użycie: gcs trebuhw/.dotfiles.git

function gcs --description "Clone GitHub repo via SSH (shallow)"
    if test (count $argv) -ne 1
        echo "Użycie: gcs właściciel/repo.git"
        return 1
    end
    git clone --depth=1 git@github.com:$argv[1]
end
