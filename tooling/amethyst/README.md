# Amethyst

Amethyst is a fast, efficient and lightweight AUR helper and Pacman wrapper.

Made for Crystal, compatible with any Arch-based Linux distribution.

## 💡 Features

- Fast and efficient!
- Asynchronus!
- Customizable!
- Parallel package building
- Install packages from the AUR and any added repositories
- Search for packages in the AUR and any added repositories

## 📚 Documentation

Documentation for this project is available [here](https://getcryst.al/site/docs/amethyst/getting-started)!
## 💾 Installation

### 💽 From Binary

**Install amethyst using `cargo`**
```bash
  $ cargo install --path .
  $ ame help
```

    
### 🏗 From Source

**Install amethyst from source using `cargo`**

 Debug/development builds

 ```bash
  $ git clone https://git.getcryst.al/crystal/software/amethyst.git && cd amethyst
  $ cargo build
  $ cargo run
 ```

Optimised/release builds

 ```bash 
  $ git clone https://git.getcryst.al/crystal/software/amethyst.git && cd amethyst
  $ cargo install --path .
 ```


 Install on non-Crystal distros
```bash
sudo pacman -S --needed base-devel pacman-contrib cargo
git clone https://git.getcryst.al/crystal/pkgbuilds/ame
cd ame && makepkg -si
```  
  
Amethyst is also available as an [AUR package](https://aur.archlinux.org/packages/ame)!

## 📸 Screenshots

![App Screenshot](/screenshot.png)

## 🙌 Contributing

If you'd like to contribute to **amethyst**, please follow the [Crystal Linux contributing guidelines](https://git.getcryst.al/crystal/info/-/blob/main/CONTRIBUTING.md)!

This project uses This project uses `rustup`, to set up `rust` for **amethyst** development, please follow the guidelines below:

```bash
$ curl https://sh.rustup.rs -sSf | sh
$ rustup default stable
```

(Via [rustup.rs](https://rustup.rs/))

We are also constantly looking for translators for our i18n-enabled projects! If you speak more than one language, consider helping out on our [Weblate](https://i18n.getcryst.al)!

![https://i18n.getcryst.al/engage/crystal-linux/](https://i18n.getcryst.al/widgets/crystal-linux/-/287x66-black.png)


## 📜 License

[GPLv3-only](https://choosealicense.com/licenses/gpl-3.0/)

![](https://git.getcryst.al/crystal/misc/branding/-/raw/main/banners/README-banner.png)


<!--

echo "AME_UWU=true" >> ~/.zshrc
echo "AME_UWU=true" >> ~/.bashrc
set -Ux AME_UWU true

:)

-->
