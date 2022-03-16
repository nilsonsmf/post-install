#!/bin/bash

opts=(update tools dev)

# set-up logging
LOGFILE=$HOME/postinstall.txt
touch $LOGFILE
echod() {
  echo "" 2>&1 | tee -a $LOGFILE
  echo "" 2>&1 | tee -a $LOGFILE
  echo "==> $(date)" 2>&1 | tee -a $LOGFILE
  echo "==> $@" 2>&1 | tee -a $LOGFILE
  echo "" 2>&1 | tee -a $LOGFILE
}

wsl_update() {
  wsl_init
  wsl_packages
  wsl_conf
  wsl_yay
}
wsl_tools() {
  wsl_fonts
  wsl_zsh
  wsl_lunarvim
}
wsl_dev() {
  wsl_gitconfig
  wsl_asdf
}
wsl_init() {
  echod "Init"
  echod "Fix WSL Network"
  echo "[network]" | sudo tee /etc/wsl.conf
  echo "generateResolvConf = false" | sudo tee -a /etc/wsl.conf
  echo "nameserver 192.168.1.1" | sudo tee /etc/resolv.conf
  echod "Restart shell"
}
wsl_packages() {
  echod "Update packages"
  sudo pacman-key --init
  sudo pacman-key --populate
  sudo pacman -Syy archlinux-keyring --noconfirm
  sudo pacman -Syyuu --noconfirm wget yarn npm git rust cargo ssh-tools
  sudo pacman -S base-devel 
  sudo pacman -S --noconfirm neovim
}
wsl_conf() {
  git clone https://github.com/nilsonsmf/home ~/dotfiles
  rm -rf ~/.zshrc
  ln -s -f ~/dotfiles/.bash_aliases ~/.bash_aliases
  ln -s -f ~/dotfiles/.zshrc ~/.zshrc
}
wsl_lunarvim() {
  echod "Install Lunarvim"
  bash <(curl -s https://raw.githubusercontent.com/lunarvim/lunarvim/master/utils/installer/install.sh)
  export PATH=/home/nilson/.cargo/bin:/home/nilson/.local/bin:$PATH
}
wsl_yay() {
  echod "Install Yay"
  cd /tmp
  git clone https://aur.archlinux.org/yay-git.git
  cd yay-git
  makepkg -si
  sudo yay -Syu
}
wsl_zsh() {
  echod "Install Zsh"
  sudo yay -S zsh
  chsh -s /usr/bin/zsh
  source ~/.zshrc
  echod "Install powerlevel10k"
  yay -S --noconfirm zsh-theme-powerlevel10k-git
  echo 'source /usr/share/zsh-theme-powerlevel10k/powerlevel10k.zsh-theme' | tee -a ~/.zshrc
  git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
}
wsl_fonts() {
  echod "Install terminal Fonts..."
  yay -S ttf-meslo-nerd-font-powerlevel10k powerline-fonts awesome-terminal-fonts
}
wsl_asdf() {
  echod "Install asdf"
  yay -S asdf-vm re2c docker libxcrypt-compat ssh-tools
  asdf plugin add nodejs
  asdf plugin add php
  asdf plugin add python
  asdf install nodejs latest
}
wsl_gitconfig() {
  echod "Git config"
  git config --global user.email "nilsonsmf@live.com"
  git config --global user.name "Nilson Morais"
}

# now execute given options
for i in "${!opts[@]}"; do
  if [ -n "$(type -t wsl_${opts[$i]})" ] && [ "$(type -t wsl_${opts[$i]})" = function ]; then
    wsl_${opts[$i]}
  else
    echod "option ${opts[$i]} is invalid"
  fi
done
