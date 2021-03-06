## Tibia Bot Scripts

XenoBot cavebot scripts for botting on Tibia and some Open-Tibia servers.

### Dependencies
Before attempting to get started, please install the following depedencies if you do not already have them.

- [Install NodeJS](https://nodejs.org/en/)
- [Install Git](https://git-scm.com/download/win)

### Getting Started
Open the command prompt and navigate to the directory you wish to clone to and run the following:

```shell
$ git clone https://github.com/OXGaming/oxscripts.git
$ cd oxscripts
$ npm install                                # Install dependencies
$ npm run build                              # Build all scripts
```

### How to run a live reload server
This will start a build server that detects changes to source and reloads the script automatically.
You will need to install ZMQ `npm install zmq` for this feature to work.

```shell
$ npm start --script="Edron Demons (MS)"
```

### How to build a single script
Build a single script and copy it to your XenoBot settings folder.

```shell
$ npm run build --script="Edron Demons (MS)"
```
