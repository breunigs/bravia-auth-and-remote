## Setup

You need to set your TV to use a pre-shared key.

1. Navigate to: [Settings] → [Network] → [Home Network Setup] → [IP Control]
2. Set [Authentication] to [Normal and Pre-Shared Key]
3. There should be a new menu entry [Pre-Shared Key]. Set it to a 4 digit value (e.g. **0000**).

## Usage

1. Run `print_ircc_codes.sh TV_IP_HERE` to get an overview of the commands possible.
2. Run `send_command.sh TV_IP_HERE TC_PIN_HERE ONE_COMMAND_HERE`. A command looks like `AAAAAQAAAAEAAABgAw==`.
3. The TV will execute the command and immediately return. If you want to navigate through menus, you'll have to manually `sleep` until the TV has finished the command/animation.

See `example_goto_media_player.sh` on how to build your automations.

You can also use `send_name.sh` to execute a list of commands with a short delay in between each. This script requires that `BRAVIA_IP` and `BRAVIA_PSK` be set.

```
BRAVIA_IP=1.2.3.4 BRAVIA_PSK=0.0.0.0 send_name.sh WakeUp Hdmi1
```

This will wake the TV up and switch the input to HDMI 1. (Tested on Sony A80J.)

Note: The `send_name.sh` script adds a 200ms delay between each command, which might not be sufficient for opening apps like YouTube. Also, because of the limitations of emulating a remote control, not all operations are possible (such as opening a given URL using a specific app.)

Have fun!

### More detailed explanation

The original blog post describes how to figure this out in general:
https://blog.yrden.de/2014/11/14/remote-control-bravia-tvs-with-authentication.html

StefanPuntNL figured out how to use it with a Pre-Shared-Key, which is much simpler:
https://www.domoticz.com/forum/viewtopic.php?t=8301
